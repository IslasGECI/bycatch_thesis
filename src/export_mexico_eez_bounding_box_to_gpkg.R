# ==========================================
# Título: Calcular Intersección entre EEZ de México y Bounding Box del Pacífico Norte
#
# Contexto (Por qué):
# Para muchos análisis oceánicos se necesita limitar la extensión espacial
# de los datos para reducir volumen de procesamiento y enfocarse en una
# región de interés. En este caso se recorta la Zona Económica Exclusiva
# (EEZ) de México utilizando un bounding box que cubre parte del Pacífico
# Norte.
#
# Descripción (Qué / Cómo):
# El script carga el shapefile de la EEZ de México, transforma la geometría
# a coordenadas geográficas WGS84, crea un polígono rectangular a partir de
# coordenadas definidas por el usuario y calcula la intersección espacial
# entre ambos objetos.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
# config_bounding_box.json
#
# Salidas:
# data/processed/mexico_eez_bounding_box_intersection.gpkg (capa: mexico_eez_bbox)
#
# Dependencias:
# sf
# tidyverse
# jsonlite
#
# Notas:
# El bounding box está definido en coordenadas geográficas (lon/lat),
# por lo que la EEZ se transforma explícitamente a EPSG:4326 para
# garantizar compatibilidad espacial
# Se utiliza st_make_valid() para asegurar geometrías válidas antes de
# realizar operaciones topológicas
# ==========================================


# ==== HEADER ====
library(jsonlite)   # Permite leer archivos JSON de configuración para centralizar parámetros
library(sf)         # Permite operaciones espaciales vectoriales
library(tidyverse)  # Facilita manipulación declarativa de datos


# ==== CONFIGURATION ====
# Centralizar constantes evita números mágicos en el código
config_path <- "config_bounding_box.json"
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
output_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
output_layer_name <- "mexico_eez_bbox"

bbox_config <- fromJSON(config_path)
bbox_lat_min <- bbox_config$bbox$lat_min
bbox_lat_max <- bbox_config$bbox$lat_max
bbox_lon_min <- bbox_config$bbox$lon_min
bbox_lon_max <- bbox_config$bbox$lon_max

# ==== INPUTS ====
# Se importa la EEZ como objeto sf para habilitar operaciones geométricas
# quiet = TRUE reduce ruido en consola durante ejecución automática
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)


# ==== PROCESS / ANALYSIS ====
# Se transforma la EEZ a coordenadas geográficas WGS84 para que los límites
# del bounding box definidos en grados coincidan correctamente con la geometría
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(4326)

# Se construye el bounding box en coordenadas geográficas
bounding_box_polygon <- st_bbox(
  c(
    xmin = bbox_lon_min,
    xmax = bbox_lon_max,
    ymin = bbox_lat_min,
    ymax = bbox_lat_max
  ),
  crs = 4326
) |>
  st_as_sfc()  # Convierte el bbox en una geometría sf para permitir intersección

# Se asegura que las geometrías sean válidas antes de operaciones topológicas
mexico_eez_valid <- mexico_eez_wgs84 |>
  st_make_valid()

# La intersección espacial recorta la EEZ usando el bounding box
mexico_eez_bbox <- st_intersection(
  mexico_eez_valid,
  bounding_box_polygon
)


# ==== OUTPUT ====
# Se exporta el resultado a GeoPackage para mantener consistencia
# con el resto del pipeline espacial
st_write(
  obj = mexico_eez_bbox,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  quiet = TRUE
)
