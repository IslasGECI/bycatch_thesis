# ==========================================
# Título: Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de palangre de GFW
#
# Contexto (Por qué):
# El polígono del KBA (potentialSite = TRUE) delimita la zona de alimentación
# relevante del albatros de Laysan. Las celdas hot spot de palangre de GFW
# (z-score >= 1.96) indican agrupación significativa de presión pesquera.
# Su intersección revela las celdas con presión pesquera significativa dentro
# del área de alimentación del albatros.
#
# Descripción (Qué / Cómo):
# Lee los polígonos KBA y las celdas con z-scores de Getis-Ord Gi* para los
# puntos de palangre de GFW. Filtra el KBA a potentialSite = TRUE. Filtra
# las celdas a aquellas con z-score >= 1.96 y al menos un punto de palangre.
# Calcula la intersección espacial entre el polígono KBA fusionado y las
# celdas hot spot. Escribe el resultado como GeoPackage.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/processed/gfw_longline_hotspot_all.gpkg
#
# Salida:
# data/processed/kba_hotspot_intersection.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - El KBA se filtra a potentialSite = TRUE
# - El hot spot se define como z-score >= 1.96 (p < 0.05 bilateral)
# - st_union() fusiona las celdas del sitio potencial en un solo contorno
# - La intersección usa st_intersection para recortar las celdas al límite del KBA
# ==========================================


# ==== CONFIGURACIÓN ====

library(sf)
# Proporciona st_read para importar geometrías y st_intersection para
# calcular la intersección espacial entre el KBA y las celdas hot spot

library(tidyverse)
# Proporciona dplyr para filtrar filas con filter() y summarise()

# Ruta del GeoPackage con los polígonos KBA originales para extraer el
# contorno del sitio potencial (potentialSite = TRUE)
input_kba_path <- "data/processed/kba_polygons_all.gpkg"

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para los puntos
# de palangre de GFW en la rejilla del KDE
input_hotspot_path <- "data/processed/gfw_longline_hotspot_all.gpkg"

# Ruta del GeoPackage que almacenará la intersección entre el polígono
# KBA y las celdas hot spot de palangre de GFW
output_intersection_path <- "data/processed/kba_hotspot_intersection.gpkg"

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96


# ==== ENTRADAS ====

# Importa los polígonos KBA originales para extraer el contorno del sitio
# potencial (potentialSite = TRUE) como referencia del área de alimentación
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)

# Importa la rejilla con los z-scores de Getis-Ord Gi* desde el GeoPackage
# generado por src/compute_gfw_longline_hotspot.R
longline_hotspot_sf <- st_read(input_hotspot_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la fusión espacial
sf_use_s2(FALSE)

# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# rojo que renderiza mapSite(), y las fusiona en un solo contorno para
# calcular la intersección con las celdas hot spot
kba_union_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # summarise() sin argumentos disuelve la geometría automáticamente en sf
  summarise()

# Filtra la rejilla para conservar solo las celdas con al menos un punto
# de palangre de GFW y con z-score >= 1.96, que corresponden a las celdas
# clasificadas como hot spot significativo
hotspot_cells_sf <- longline_hotspot_sf |>
  filter(n_points_gfw_longline > 0) |>
  filter(gi_star_z_score >= hot_spot_z_threshold) |>
  # Transforma las celdas de LAEA (proyección original del hotspot) a
  # coordenadas geográficas WGS84 (EPSG:4326) para que coincida con el
  # sistema de referencia del polígono KBA
  st_transform(st_crs(kba_union_sf))

# Calcula la intersección espacial entre el polígono KBA fusionado y las
# celdas hot spot para obtener la porción del área de alimentación del
# albatros que coincide con presión pesquera significativa
kba_hotspot_intersection_sf <- st_intersection(kba_union_sf, hotspot_cells_sf)


# ==== SALIDA ====

# Escribe la intersección KBA ∩ hot spot como GeoPackage para que el script
# de graficado pueda leerla sin recalcular la operación espacial
st_write(kba_hotspot_intersection_sf, output_intersection_path, quiet = TRUE)
