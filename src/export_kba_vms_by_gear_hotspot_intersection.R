# ==========================================
# Título: Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de congestión VMS
#
# Contexto (Por qué):
# El polígono del KBA (potentialSite = TRUE) delimita la zona de
# alimentación relevante del albatros de Laysan. Las celdas hot
# spot de congestión VMS (z-score >= 1.96) indican agrupación
# significativa de tráfico de embarcaciones. Su intersección
# revela las celdas con congestión significativa dentro del área
# de alimentación del albatros.
#
# Descripción (Qué / Cómo):
# Recibe el nombre del arte de pesca como argumento (longline,
# trawler, purse_seine, other). Lee los polígonos KBA y las
# celdas con z-scores de Getis-Ord Gi* para los puntos VMS de
# ese arte. Filtra el KBA a potentialSite = TRUE. Filtra las
# celdas a aquellas con z-score >= 1.96 y al menos un punto VMS.
# Transforma las celdas del CRS proyectado del KDE a WGS84 para
# que coincida con el CRS del KBA. Calcula la intersección
# espacial entre el polígono KBA fusionado y las celdas hot spot.
# Escribe el resultado como GeoPackage.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/processed/vms_{gear}_hotspot.gpkg
#
# Salida:
# data/processed/kba_vms_{gear}_hotspot_intersection.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - El KBA se filtra a potentialSite = TRUE
# - El hot spot se define como z-score >= 1.96 (p < 0.05 bilateral)
# - summarise() fusiona las celdas del sitio potencial en un solo contorno
# - La intersección usa st_intersection para recortar las celdas al límite del KBA
# ==========================================


# ==== CONFIGURACIÓN ====

library(sf)
# Proporciona st_read para importar geometrías y st_intersection
# para calcular la intersección espacial entre el KBA y las
# celdas hot spot

library(tidyverse)
# Proporciona dplyr para filtrar filas con filter() y summarise()

# Lee el nombre del arte de pesca desde el primer argumento de la línea
# de comandos (por ejemplo, "trawler", "purse_seine", "other") para
# construir las rutas de los archivos de entrada y salida
gear <- commandArgs(trailingOnly = TRUE)[1]

# Ruta del GeoPackage con los polígonos KBA originales para
# extraer el contorno del sitio potencial (potentialSite = TRUE)
input_kba_path <- "data/processed/kba_polygons_all.gpkg"

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para
# los puntos VMS del arte de pesca especificado en la rejilla
input_hotspot_path <- paste0("data/processed/vms_", gear, "_hotspot.gpkg")

# Ruta del GeoPackage que almacenará la intersección entre el
# polígono KBA y las celdas hot spot de congestión VMS
output_intersection_path <- paste0(
  "data/processed/kba_vms_", gear, "_hotspot_intersection.gpkg"
)

# Nombre de la columna de conteo de puntos VMS del arte de pesca
# especificado, usada para filtrar celdas sin puntos
n_points_column <- paste0("n_points_vms_", gear)

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96


# ==== ENTRADAS ====

# Importa los polígonos KBA originales para extraer el contorno
# del sitio potencial (potentialSite = TRUE) como referencia del
# área de alimentación
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)

# Importa la rejilla con los z-scores de Getis-Ord Gi* desde el
# GeoPackage generado por src/compute_vms_by_gear_hotspot.R
vms_hotspot_sf <- st_read(input_hotspot_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas en los polígonos KBA durante el filtrado y la fusión
# espacial
sf_use_s2(FALSE)

# Filtra los polígonos KBA para conservar solo las celdas
# identificadas como sitio potencial (potentialSite = TRUE) que
# corresponden al área de alimentación relevante del albatros,
# y las fusiona en un solo contorno para calcular la intersección
# con las celdas hot spot
kba_union_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # summarise() sin argumentos disuelve la geometría automáticamente
  summarise()

# Filtra la rejilla para conservar solo las celdas con al menos
# un punto VMS del arte de pesca especificado y con z-score
# >= 1.96, que corresponden a las celdas clasificadas como hot
# spot significativo de congestión de embarcaciones
hotspot_cells_sf <- vms_hotspot_sf |>
  filter(.data[[n_points_column]] > 0) |>
  filter(gi_star_z_score >= hot_spot_z_threshold) |>
  # Transforma las celdas del CRS proyectado del KDE a coordenadas
  # geográficas WGS84 (EPSG:4326) para que coincida con el sistema
  # de referencia del polígono KBA
  st_transform(st_crs(kba_union_sf))

# Calcula la intersección espacial entre el polígono KBA fusionado
# y las celdas hot spot para obtener la porción del área de
# alimentación del albatros que coincide con congestión
# significativa de embarcaciones
kba_hotspot_intersection_sf <- st_intersection(kba_union_sf, hotspot_cells_sf)


# ==== SALIDA ====

# Escribe la intersección KBA ∩ hot spot VMS como GeoPackage para
# que el script de graficado pueda leerla sin recalcular la
# operación espacial
st_write(kba_hotspot_intersection_sf, output_intersection_path, delete_dsn = TRUE, quiet = TRUE)
