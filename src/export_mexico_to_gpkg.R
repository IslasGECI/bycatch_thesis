# ==========================================
# Propósito: Cargar un shapefile de México, generar la unión (disolución)
#            de todas las geometrías y exportarla a un archivo GeoPackage (.gpkg)
# Entradas:  data/external/Mexico_e_islas_wgs84.shp
# Salidas:   data/processed/mexico_map.gpkg (capa: "mexico_map")
# Dependencias: sf, tidyverse, glue
# Notas:     Se aplica st_make_valid() antes de st_union() para evitar errores
#            por geometrías inválidas.
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
