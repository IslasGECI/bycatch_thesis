# ==========================================
# Título: Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de esfuerzo pesquero de GFW
#
# Contexto (Por qué):
# El polígono del KBA (potentialSite = TRUE) delimita la zona de
# alimentación relevante del albatros de Laysan. Las celdas hot
# spot de esfuerzo pesquero de GFW (z-score >= 1.96) indican
# agrupación significativa de presión pesquera medida en horas
# de pesca aparente. Su intersección revela las celdas con alta
# presión pesquera dentro del área de alimentación del albatros.
#
# Descripción (Qué / Cómo):
# Lee los polígonos KBA y las celdas con z-scores de Getis-Ord
# Gi* para las sumas de horas de pesca aparente de GFW. Filtra
# el KBA a potentialSite = TRUE. Filtra las celdas a aquellas con
# z-score >= 1.96 y suma de horas de pesca positiva. Transforma
# las celdas del CRS proyectado del KDE a WGS84 para que coincida
# con el CRS del KBA. Calcula la intersección espacial entre el
# polígono KBA fusionado y las celdas hot spot. Escribe el
# resultado como GeoPackage.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/processed/gfw_apparent_fishing_effort_hotspot.gpkg
#
# Salida:
# data/processed/kba_gfw_apparent_fishing_effort_hotspot_intersection.gpkg
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

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos del ecosistema tidyverse
library(tidyverse)

# Ruta del GeoPackage con los polígonos KBA originales para extraer el
# contorno del sitio potencial (potentialSite = TRUE)
input_kba_path <- "data/processed/kba_polygons_all.gpkg"

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para las sumas
# de horas de pesca aparente de GFW en la rejilla del KDE
input_hotspot_path <- "data/processed/gfw_apparent_fishing_effort_hotspot.gpkg"

# Ruta del GeoPackage que almacenará la intersección entre el polígono
# KBA y las celdas hot spot de esfuerzo pesquero de GFW
output_intersection_path <- "data/processed/kba_gfw_apparent_fishing_effort_hotspot_intersection.gpkg"

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96


# ==== ENTRADAS ====

# Importa los polígonos KBA originales para extraer el contorno del sitio
# potencial (potentialSite = TRUE) como referencia del área de alimentación
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)

# Importa la rejilla con los z-scores de Getis-Ord Gi* desde el GeoPackage
# generado por src/compute_gfw_apparent_fishing_effort_hotspot.R
fishing_effort_hotspot_sf <- st_read(input_hotspot_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la fusión espacial
sf_use_s2(FALSE)

# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# que renderiza mapSite(), y las fusiona en un solo contorno para calcular
# la intersección con las celdas hot spot
kba_union_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # summarise() sin argumentos disuelve la geometría automáticamente en sf
  summarise()

# Filtra la rejilla para conservar solo las celdas con suma de horas de
# pesca aparente positiva y con z-score >= 1.96, que corresponden a las
# celdas clasificadas como hot spot significativo de esfuerzo pesquero
hotspot_cells_sf <- fishing_effort_hotspot_sf |>
  filter(sum_gfw_apparent_fishing_hours > 0) |>
  filter(gi_star_z_score >= hot_spot_z_threshold) |>
  # Transforma las celdas del CRS proyectado del KDE a coordenadas
  # geográficas WGS84 (EPSG:4326) para que coincida con el sistema
  # de referencia del polígono KBA
  st_transform(st_crs(kba_union_sf))

# Calcula la intersección espacial entre el polígono KBA fusionado y las
# celdas hot spot para obtener la porción del área de alimentación del
# albatros que coincide con presión pesquera significativa
kba_fishing_effort_hotspot_intersection_sf <- st_intersection(kba_union_sf, hotspot_cells_sf)


# ==== SALIDA ====

# Escribe la intersección KBA ∩ hot spot de esfuerzo pesquero de GFW como
# GeoPackage para que el script de graficado pueda leerla sin recalcular
# la operación espacial
st_write(kba_fishing_effort_hotspot_intersection_sf, output_intersection_path, delete_dsn = TRUE, quiet = TRUE)
