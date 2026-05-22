# ==========================================
# Título: Exporta las áreas naturales protegidas a GeoPackage
#
# Contexto (Por qué):
# Las Áreas Naturales Protegidas (ANP) provienen de un shapefile con
# múltiples polígonos. Unirlas en una sola geometría facilita las
# operaciones de diferencia espacial para calcular las áreas marinas
# protegidas en pasos posteriores del pipeline.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de ANP, aplica st_make_valid() para corregir
# geometrías inválidas, genera la unión de todas las geometrías
# mediante st_union() y exporta el resultado como GeoPackage con una
# capa nombrada para consumir en otros scripts.
#
# Entradas:
# data/external/232_ANP-ITRF08_04072025.shp
#
# Salida:
# data/processed/mexico_pna.gpkg (capa: mexico_pna)
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - st_make_valid() se aplica antes de st_union() para evitar errores topológicos
# - El CRS original se conserva sin transformaciones innecesarias
# - El shapefile contiene 232 áreas naturales protegidas
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar shapefiles y st_union para disolver geometrías
library(tidyverse) # Proporciona summarize() para colapsar múltiples geometrías en una sola

# Ruta del shapefile con las 232 Áreas Naturales Protegidas de México
input_shapefile_path <- "data/external/232_ANP-ITRF08_04072025.shp"
# Ruta del GeoPackage que almacenará la geometría unificada de las ANP
output_gpkg_path <- "data/processed/mexico_pna.gpkg"
# Nombre de la capa dentro del GeoPackage para identificar la geometría
output_layer_name <- "mexico_pna"


# ==== ENTRADAS ====
# Importa el shapefile de ANP como objeto sf manteniendo el CRS original
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
