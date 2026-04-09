# ==========================================
# Propósito: Cargar un shapefile de Áreas Naturales Protegidas (ANP),
#            generar la unión (disolución) de todas las geometrías
#            y exportarla a un archivo GeoPackage (.gpkg) sin graficar.
# Entradas:  data/external/232_ANP-ITRF08_04072025.shp
# Salidas:   data/processed/mexico_pna.gpkg (capa: "mexico_pna")
# Dependencias: sf, tidyverse
# Notas:     Se aplica st_make_valid() antes de st_union() para evitar errores
#            por geometrías inválidas. Se mantiene el CRS original (YAGNI).
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para manejar datos espaciales (lectura/escritura y operaciones geométricas)
library(tidyverse)  # Para una sintaxis de manipulación de datos clara y encadenada

# ==== CONFIGURACIÓN ====
# -- Centralizar valores fijos facilita cambios futuros sin tocar el resto del script
input_shapefile_path <- "data/external/232_ANP-ITRF08_04072025.shp" # Ruta al shapefile de entrada
output_gpkg_path <- "data/processed/mexico_pna.gpkg" # Ruta del GeoPackage de salida
output_layer_name <- "mexico_pna" # Nombre de la capa dentro del GPKG

# ==== IMPORTAR Y PREPARAR DATOS ====
# Se lee el shapefile como objeto sf; quiet = TRUE minimiza el ruido en consola
# Mantener el CRS original evita transformaciones innecesarias (YAGNI)
shape_data <- st_read(input_shapefile_path, quiet = TRUE)

# ==== CREAR GEOMETRÍA UNIDA (DISOLUCIÓN) ====
# Se corrigen geometrías potencialmente inválidas para que st_union() no falle
# summarize() sin agrupación colapsa todas las filas en una sola geometría
shape_union <- shape_data |>
  st_make_valid() |> # Evita problemas topológicos (p. ej., auto-intersecciones)
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
