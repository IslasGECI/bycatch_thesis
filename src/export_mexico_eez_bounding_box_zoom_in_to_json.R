# ==========================================
# Título: Calcular Bounding Box Redondeado a Partir de Subconjunto de EEZ
#
# Contexto (Por qué):
# Para mantener consistencia entre scripts de análisis y visualización,
# es útil definir los límites espaciales de trabajo mediante un archivo
# de configuración. En lugar de definir manualmente el bounding box,
# este script lo calcula automáticamente a partir de la geometría
# espacial de la EEZ recortada.
#
# Descripción (Qué / Cómo):
# El script lee el archivo GeoPackage que contiene la intersección entre
# la Zona Económica Exclusiva (EEZ) de México y un bounding box previo.
# Posteriormente calcula el bounding box mínimo de esa geometría usando
# st_bbox(), redondea los límites al múltiplo de 5 grados más cercano y
# exporta el resultado como archivo JSON de configuración.
#
# Entradas:
# data/processed/mexico_eez_bounding_box_intersection.gpkg
#
# Salidas:
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Dependencias:
# sf
# jsonlite
#
# Notas:
# El redondeo garantiza límites cartográficos limpios:
#   - oeste y sur → floor() (hacia abajo)
#   - este y norte → ceiling() (hacia arriba)
# ==========================================


# ==== HEADER ====
library(sf)        # Manejo de geometrías espaciales
library(jsonlite)  # Exportación de archivos JSON


# ==== CONFIGURATION ====
input_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
output_json_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

rounding_multiple <- 5


# ==== INPUTS ====
# Se importa la geometría espacial desde el GeoPackage
mexico_eez_bounding_box_sf <- st_read(input_gpkg_path, quiet = TRUE)


# ==== PROCESS / ANALYSIS ====
# Se calcula el bounding box mínimo de la geometría
bbox_raw <- st_bbox(mexico_eez_bounding_box_sf)

# Se redondean los límites al múltiplo de 5 grados más cercano
bbox_lon_min <- floor(bbox_raw["xmin"] / rounding_multiple) * rounding_multiple
bbox_lon_max <- ceiling(bbox_raw["xmax"] / rounding_multiple) * rounding_multiple
bbox_lat_min <- floor(bbox_raw["ymin"] / rounding_multiple) * rounding_multiple
bbox_lat_max <- ceiling(bbox_raw["ymax"] / rounding_multiple) * rounding_multiple


# ==== CREATE JSON STRUCTURE ====
bbox_config <- list(
  bbox = list(
    lon_min = bbox_lon_min,
    lon_max = bbox_lon_max,
    lat_min = bbox_lat_min,
    lat_max = bbox_lat_max
  )
)


# ==== OUTPUT ====
# Se exporta el bounding box redondeado como archivo JSON
write_json(
  bbox_config,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE
)
