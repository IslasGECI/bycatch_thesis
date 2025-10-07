# ==========================================
# Propósito: Calcular la diferencia espacial entre las Áreas Naturales Protegidas (ANP)
#            y el territorio nacional de México, exportando el resultado como GeoPackage.
# Entradas:  data/processed/anp_union.gpkg
#             data/processed/mexico_union.gpkg
# Salidas:   data/processed/anp_difference_mexico_YYYY-MM-DD.gpkg (capa: "anp_difference_mexico")
# Dependencias: sf, tidyverse, glue
# Notas:     La diferencia espacial se calcula con st_difference().
#            Se asume que ambas capas están en el mismo CRS.
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para operaciones espaciales y manejo de archivos geográficos
library(tidyverse)  # Para manipulación de datos y encadenamiento funcional

# ==== CONFIGURACIÓN ====
# -- Centralizar variables fijas para facilitar mantenimiento
anp_union_path <- "data/processed/anp_union.gpkg" # Ruta de entrada ANP
mexico_union_path <- "data/processed/mexico_union.gpkg" # Ruta de entrada México
output_gpkg_path <- "data/processed/amp_mexico.gpkg" # Nombre del archivo de salida
output_layer_name <- "amp_mexico" # Nombre de la capa resultante

# ==== IMPORTAR DATOS ====
# Se leen las geometrías unidas previamente generadas
# El uso de quiet = TRUE evita mensajes innecesarios
anp_union <- st_read(anp_union_path, quiet = TRUE)
mexico_union <- st_read(mexico_union_path, quiet = TRUE)

# ==== ASEGURAR COMPATIBILIDAD DE CRS ====
# Se verifica que ambas capas usen el mismo sistema de referencia espacial
# En caso contrario, se transforma ANP para igualar el CRS de México
anp_union <- st_transform(anp_union, st_crs(mexico_union))

# ==== CALCULAR DIFERENCIA ESPACIAL ====
# Se usa st_difference() para obtener las zonas de ANP fuera del polígono de México
# Este paso identifica geometrías que no se solapan con el territorio nacional
anp_difference <- st_difference(anp_union, mexico_union)

# ==== EXPORTAR RESULTADO A GEOPACKAGE ====
# Se guarda el resultado en un archivo GeoPackage con nombre versionado por fecha
# Esto facilita la trazabilidad y evita sobreescrituras
st_write(
  obj = anp_difference,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  quiet = TRUE
)

