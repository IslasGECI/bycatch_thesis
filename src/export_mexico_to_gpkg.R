# ==========================================
# Título: Exporta el shapefile de México a GeoPackage
#
# Contexto (Por qué):
# El formato GeoPackage es un estándar abierto que permite almacenar
# datos geoespaciales vectoriales de manera interoperable. Convertir
# el shapefile de México a GeoPackage unifica las geometrías para
# facilitar las operaciones espaciales subsecuentes del pipeline.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de México e islas, aplica st_make_valid() para
# corregir geometrías inválidas, genera la unión de todas las geometrías
# mediante st_union() y exporta el resultado como GeoPackage con una
# capa nombrada para consumir en otros scripts.
#
# Entradas:
# data/external/Mexico_e_islas_wgs84.shp
#
# Salida:
# data/processed/mexico_map.gpkg (capa: mexico_map)
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - st_make_valid() se aplica antes de st_union() para evitar errores topológicos
# - El CRS original se conserva sin transformaciones innecesarias
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf)         # Proporciona st_read para importar shapefiles y st_union para disolver geometrías
library(tidyverse)  # Proporciona summarize() para colapsar múltiples geometrías en una sola

# Ruta del shapefile de México e islas en coordenadas geográficas
input_shapefile_path <- "data/external/Mexico_e_islas_wgs84.shp"
# Ruta del GeoPackage que almacenará la geometría unificada de México
output_gpkg_path <- "data/processed/mexico_map.gpkg"
# Nombre de la capa dentro del GeoPackage para identificar la geometría
output_layer_name <- "mexico_map"


# ==== ENTRADAS ====
# Importa el shapefile de México como objeto sf manteniendo el CRS original
shape_data <- st_read(input_shapefile_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Corrige geometrías potencialmente inválidas para que st_union() no falle
# y disuelve los límites internos colapsando todas las filas en una sola
shape_union <- shape_data |>
  st_make_valid() |>
  summarize(geometry = st_union(geometry))


# ==== SALIDA ====
# Exporta la geometría unificada como GeoPackage con una capa nombrada
# para facilitar su lectura por otros scripts del pipeline de análisis
st_write(
  obj = shape_union,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  quiet = TRUE
)
