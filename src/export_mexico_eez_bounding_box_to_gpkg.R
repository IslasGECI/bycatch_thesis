# ==========================================
# Título: Calcula la intersección entre la EEZ de México y el bounding box del Pacífico Norte
#
# Contexto (Por qué):
# Limitar la extensión espacial de los datos oceánicos reduce el volumen
# de procesamiento y enfoca el análisis en la región de interés. La Zona
# Económica Exclusiva de México se recorta con un bounding box que cubre
# el Pacífico Norte donde forrajean los albatros.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de la EEZ de México, transforma la geometría a
# coordenadas geográficas WGS84, crea un polígono rectangular a partir
# del bounding box de configuración y calcula la intersección espacial.
# Exporta el resultado como GeoPackage para consumirlo en otros scripts.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/bounding_box.json
#
# Salida:
# data/processed/mexico_eez_bounding_box_intersection.gpkg (capa: mexico_eez_bbox)
#
# Dependencias:
# jsonlite
# sf
# tidyverse
#
# Notas:
# - El bounding box está en coordenadas geográficas, por lo que la EEZ se transforma a EPSG:4326
# - st_make_valid() garantiza geometrías válidas antes de la intersección
# ==========================================


# ==== CONFIGURACIÓN ====
library(jsonlite)   # Proporciona fromJSON para leer el bounding box de configuración
library(sf)         # Proporciona st_read y operaciones espaciales vectoriales
library(tidyverse)  # Proporciona el operador pipe |> para flujos de datos lineales

# Ruta del archivo JSON con los límites del bounding box de la región de estudio
config_path <- "data/processed/bounding_box.json"
# Ruta del shapefile de la Zona Económica Exclusiva de México
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
# Ruta del GeoPackage que almacenará la intersección espacial
output_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
# Nombre de la capa dentro del GeoPackage para identificar la geometría
output_layer_name <- "mexico_eez_bbox"

# Carga los límites del bounding box desde el archivo JSON de configuración
bbox_config <- fromJSON(config_path)
# Extrae las coordenadas del bounding box para construir el polígono de recorte
bbox_lat_min <- bbox_config$bbox$lat_min
bbox_lat_max <- bbox_config$bbox$lat_max
bbox_lon_min <- bbox_config$bbox$lon_min
bbox_lon_max <- bbox_config$bbox$lon_max


# ==== ENTRADAS ====
# Importa la EEZ de México como objeto sf para habilitar operaciones geométricas
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Transforma la EEZ a coordenadas geográficas WGS84 para que los límites
# del bounding box definidos en grados coincidan con la geometría
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(4326)

# Construye el bounding box como polígono sf en coordenadas geográficas
bounding_box_polygon <- st_bbox(
  c(
    xmin = bbox_lon_min,
    xmax = bbox_lon_max,
    ymin = bbox_lat_min,
    ymax = bbox_lat_max
  ),
  crs = 4326
) |>
  st_as_sfc()

# Valida las geometrías de la EEZ antes de la intersección para evitar
# errores topológicos por polígonos mal formados
mexico_eez_valid <- mexico_eez_wgs84 |>
  st_make_valid()

# Calcula la intersección espacial que recorta la EEZ usando el bounding box
# como máscara geográfica para limitar el área de estudio
mexico_eez_bbox <- st_intersection(
  mexico_eez_valid,
  bounding_box_polygon
)


# ==== SALIDA ====
# Exporta el resultado de la intersección como GeoPackage con una capa
# nombrada para facilitar su lectura por otros scripts del pipeline
st_write(
  obj = mexico_eez_bbox,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  delete_layer = TRUE,
  quiet = TRUE
)
