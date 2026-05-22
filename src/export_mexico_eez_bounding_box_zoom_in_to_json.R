# ==========================================
# Título: Calcula el bounding box redondeado a partir del subconjunto de la EEZ
#
# Contexto (Por qué):
# Mantener la consistencia espacial entre scripts requiere centralizar
# los límites geográficos en un archivo de configuración. Calcular el
# bounding box automáticamente a partir de la geometría de la EEZ
# evita definir manualmente las coordenadas de la región de interés.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con la intersección de la EEZ de México y el bounding
# box previo, calcula el bounding box mínimo de esa geometría con
# st_bbox(), redondea los límites al múltiplo de 5 grados más cercano
# y exporta el resultado como JSON de configuración para otros scripts.
#
# Entradas:
# data/processed/mexico_eez_bounding_box_intersection.gpkg
#
# Salida:
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Dependencias:
# sf
# jsonlite
#
# Notas:
# - El redondeo usa floor() para límites inferiores y ceiling() para superiores
# - El múltiplo de 5 produce coordenadas cartográficas limpias y legibles
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf)         # Proporciona st_read para importar geometrías y st_bbox para bounding boxes
library(jsonlite)   # Proporciona write_json para exportar el resultado como JSON

# Ruta del GeoPackage con la intersección EEZ-bounding box del paso anterior
input_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
# Ruta del archivo JSON que almacenará el bounding box recortado
output_json_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

# Múltiplo de redondeo para obtener límites cartográficos limpios
rounding_multiple <- 5


# ==== ENTRADAS ====
# Importa la geometría de la intersección EEZ-bounding box desde el GeoPackage
mexico_eez_bounding_box_sf <- st_read(input_gpkg_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Calcula el bounding box mínimo que contiene toda la geometría de la EEZ
bbox_raw <- st_bbox(mexico_eez_bounding_box_sf)

# Redondea los límites al múltiplo de 5 grados más cercano para obtener
# coordenadas cartográficas limpias y fáciles de interpretar en mapas
bbox_lon_min <- floor(bbox_raw["xmin"] / rounding_multiple) * rounding_multiple
bbox_lon_max <- ceiling(bbox_raw["xmax"] / rounding_multiple) * rounding_multiple
bbox_lat_min <- floor(bbox_raw["ymin"] / rounding_multiple) * rounding_multiple
bbox_lat_max <- ceiling(bbox_raw["ymax"] / rounding_multiple) * rounding_multiple

# Convierte los límites calculados en una lista anidada con la estructura
# JSON que esperan los scripts de visualización del proyecto
bbox_config <- list(
  bbox = list(
    lon_min = bbox_lon_min,
    lon_max = bbox_lon_max,
    lat_min = bbox_lat_min,
    lat_max = bbox_lat_max
  )
)


# ==== SALIDA ====
# Exporta el bounding box redondeado como JSON de configuración para
# mantener la consistencia espacial entre todos los scripts del pipeline
write_json(
  bbox_config,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE
)
