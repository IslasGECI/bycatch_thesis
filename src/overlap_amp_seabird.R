# ==========================================
# Propósito: Superponer (intersecar) las geometrías de amp_mexico y
#            key_seabird_area para identificar áreas en común.
# Entradas:  data/processed/amp_mexico.gpkg (capa: "amp_mexico")
#            data/processed/seabird_kernel_union_{percent}.gpkg
# Salidas:   data/processed/overlap_amp_mexico_seabird_kernel_union_{percent}.gpkg
# Dependencias: sf, tidyverse, glue
# Notas:     Se usa st_make_valid() antes de st_intersection() para evitar fallos por geometrías inválidas.
#            Se iguala el CRS de seabird al de amp_mexico para garantizar compatibilidad espacial.
#            Se supone que el archivo de ANP está en formato .gpkg (el fragmento decía .dpkg, se corrige aquí).
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para operaciones y E/S de datos espaciales (Simple Features)
library(tidyverse)  # Para una sintaxis clara y encadenada
library(glue)       # Para construir rutas y nombres de archivo legibles

# ==== CONFIGURACIÓN ====
# -- Centralizar parámetros facilita reproducibilidad y cambios mínimos
percent <- 25                                                            # Porcentaje del kernel de aves marinas
input_dir <- "data/processed"                                            # Directorio de entrada
output_dir <- "data/processed"                                           # Directorio de salida

input_amp_path <- glue("{input_dir}/amp_mexico.gpkg")                    # Ruta amp_mexico (corrigiendo .gpkg)
input_amp_layer <- "amp_mexico"                                          # Capa amp_mexico

input_seabird_path <- glue("{input_dir}/seabird_kernel_union_{percent}.gpkg") # Ruta seabird por porcentaje

output_path <- glue("{output_dir}/overlap_amp_seabird_{percent}.gpkg")
output_layer <- "overlap_amp_seabird"

# ==== IMPORTAR Y PREPARAR DATOS ====
# Se leen ambas capas desde sus respectivos GeoPackage; quiet = TRUE reduce ruido en consola
amp_mexico_sf <- st_read(dsn = input_amp_path, layer = input_amp_layer, quiet = TRUE)
seabird_sf <- st_read(dsn = input_seabird_path, quiet = TRUE)

# ==== ARMONIZAR CRS Y VALIDAR GEOMETRÍAS ====
# Se asegura que ambas capas compartan el mismo CRS transformando seabird al CRS de amp_mexico
# Además se validan las geometrías para prevenir errores topológicos en la intersección
amp_mexico_valid <- amp_mexico_sf |>
  st_make_valid()

seabird_valid <- seabird_sf |>
  st_transform(st_crs(amp_mexico_valid)) |>
  st_make_valid()

# ==== INTERSECCIÓN ESPACIAL ====
# Se calcula la intersección para obtener únicamente las zonas donde ambas capas se superponen
overlap_sf <- st_intersection(amp_mexico_valid, seabird_valid)

# ==== EXPORTAR RESULTADO ====
# Se escribe el resultado en un GeoPackage con nombre informativo que incluye porcentaje y fecha
st_write(
  obj = overlap_sf,
  dsn = output_path,
  layer = output_layer,
  driver = "GPKG",
  quiet = TRUE
)
