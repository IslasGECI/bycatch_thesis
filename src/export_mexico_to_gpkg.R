# ==========================================
# Título: Exportar Shapefile de México a GeoPackage
#
# Contexto (Por qué):
# El formato GeoPackage (.gpkg) es un estándar abierto que permite
# almacenar datos geoespaciales vectoriales de manera interoperable.
# Unir las geometrías del shapefile de México facilita las operaciones
# espaciales subsecuentes.
#
# Descripción (Qué / Cómo):
# El script carga el shapefile de México e islas, aplica st_make_valid()
# para corregir geometrías inválidas, genera la unión de todas las
# geometrías mediante st_union() y exporta el resultado como GeoPackage.
#
# Entradas:
# data/external/Mexico_e_islas_wgs84.shp
#
# Salidas:
# data/processed/mexico_map.gpkg (capa: mexico_map)
#
# Dependencias:
# sf
# tidyverse
# glue
#
# Notas:
# Se aplica st_make_valid() antes de st_union() para evitar errores
# por geometrías inválidas.
# Se mantiene el CRS original (YAGNI).
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para manejar datos espaciales (lectura/escritura y operaciones geométricas)
library(tidyverse)  # Para una sintaxis de manipulación de datos clara y encadenada

# ==== CONFIGURACIÓN ====
# -- Variables centralizadas para facilitar cambios sin tocar el resto del código
input_shapefile_path <- "data/external/Mexico_e_islas_wgs84.shp" # Ruta al shapefile de entrada
output_gpkg_path <- "data/processed/mexico_map.gpkg" # Ruta del GeoPackage de salida
output_layer_name <- "mexico_map" # Nombre de la capa dentro del GPKG

# ==== IMPORTAR Y PREPARAR DATOS ====
# Se lee el shapefile como objeto sf; quiet = TRUE reduce ruido en consola
# Mantener el CRS original evita transformaciones innecesarias (YAGNI)
shape_data <- st_read(input_shapefile_path, quiet = TRUE)

# ==== CREAR GEOMETRÍA UNIDA (DISOLUCIÓN) ====
# Se corrigen geometrías potencialmente inválidas para que st_union() no falle
# summarize() sin agrupación colapsa todas las filas en una sola geometría
shape_union <- shape_data |>
  st_make_valid() |>                       # Evita problemas topológicos
  summarize(geometry = st_union(geometry)) # Disuelve límites internos en una única geometría

# ==== EXPORTAR A GEOPACKAGE ====
# Se escribe la geometría resultante en un archivo .gpkg con nombre versionado por fecha
# Usar un nombre único por fecha evita sobreescrituras y facilita trazabilidad
st_write(
  obj = shape_union,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  quiet = TRUE
)
