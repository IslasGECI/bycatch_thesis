# ==========================================
# Título: Agrega las áreas de distribución individuales en una rejilla de solapamiento
#
# Contexto (Por qué):
# Necesitamos una superficie continua de cuántos individuos usan cada celda
# para identificar zonas de agregación y generar mapas de calor. La metodología
# de findSite cuenta las superposiciones de áreas de distribución individuales.
#
# Descripción (Qué / Cómo):
# Lee el RDS del assessment de representatividad que contiene el estUDm con
# las densidades de utilización de cada individuo. Extrae la representatividad
# de la población calculada por bootstrap. Llama a track2KBA::findSite para
# binarizar cada UD individual al contorno del 50 %, contar cuántos individuos
# se superponen por celda (N_IND) y convertir el resultado a polígonos.
# Escribe solo la columna N_IND como GeoPackage para su uso en mapas de calor.
#
# Entradas:
# data/processed/representative_assessment_all.rds
#
# Salida:
# data/processed/ud_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# sf
# tidyverse
# track2KBA
#
# Notas:
# - El RDS contiene el KDE de todas las colonias (121 individuos)
# - levelUD fijo en 50 % como en el resto del pipeline
# - La columna N_IND cuenta individuos, no puntos
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos y gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta adehabitatHR para extraer la rejilla del estUDm
library(adehabitatHR)

# Adjunta track2KBA para usar findSite que cuenta el solapamiento
# de áreas de distribución individuales en una rejilla común
library(track2KBA)

# Ruta del archivo RDS con el assessment de representatividad que
# contiene el KDE de todas las colonias y la representatividad
input_rds_path <- "data/processed/representative_assessment_all.rds"

# Ruta del archivo GeoPackage de salida con el conteo de individuos
# que se superponen en cada celda de la rejilla del KDE
output_gpkg_path <- "data/processed/ud_in_grid.gpkg"

# Porcentaje del UD que define el área de distribución de cada
# individuo; consistente con el resto del pipeline que usa 50 %
level_ud_percent <- 50


# ==== ENTRADAS ====

# Carga el archivo RDS que contiene el assessment de representatividad
# con la superficie KDE de todos los individuos de las tres colonias
kde_cache <- readRDS(input_rds_path)

# Extrae la superficie KDE que es un objeto estUDm con la rejilla
# de densidad de utilización para cada uno de los 121 individuos
kde_surface_estUDm <- kde_cache$KDE_surface

# Extrae el porcentaje de representatividad de la muestra calculado
# por el bootstrap de repAssess para escalar el conteo de individuos
represent_value <- kde_cache$assessment_summary$out


# ==== PROCESAMIENTO / ANÁLISIS ====

# Llama a findSite con polyOut = FALSE para obtener un
# SpatialPixelsDataFrame donde cada celda tiene el número de
# individuos (N_IND) cuya área de distribución incluye esa celda
result_pixels_spdf <- findSite(
  KDE = kde_surface_estUDm,
  represent = represent_value,
  levelUD = level_ud_percent,
  polyOut = FALSE
)

# Convierte cada píxel de la rejilla en un polígono cuadrado
# para poder escribir el resultado como GeoPackage con sf
result_polygons_spdf <- as(result_pixels_spdf, "SpatialPolygonsDataFrame")

# Convierte los polígonos espaciales a un objeto sf para
# trabajar con el ecosistema tidyverse de datos espaciales
result_sf <- st_as_sf(result_polygons_spdf)

# Descarta las columnas ID_IND, N_animals y potentialSite que
# findSite calcula internamente pero no necesitamos para el mapa
# de calor; conservamos solo N_IND con la geometría de cada celda
n_individuals_per_cell_sf <- result_sf |>
  select(N_IND)


# ==== SALIDA ====

# Escribe el GeoPackage con el conteo de individuos por celda
# de la rejilla para su uso en mapas de calor de solapamiento
st_write(n_individuals_per_cell_sf, output_gpkg_path, delete_dsn = TRUE)
