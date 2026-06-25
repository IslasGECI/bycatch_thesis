# ==========================================
# Título: Cuenta puntos VMS por celda de la rejilla del KDE
#
# Contexto (Por qué):
# Necesitamos una partición espacial común para comparar la
# congestión de embarcaciones pesqueras con las áreas de
# distribución de aves marinas. La rejilla del KDE individual
# proporciona esa partición.
#
# Descripción (Qué / Cómo):
# Recibe el nombre del arte de pesca como argumento (longline,
# trawler, purse_seine, other). Lee el CSV de trayectorias VMS
# filtradas por ese arte. Extrae la rejilla vacía del estUDm
# guardado en el RDS del KDE individual. Convierte cada píxel
# de la rejilla a un polígono usando el paquete sp. Lee los
# puntos VMS, los reproyecta al CRS de la rejilla y cuenta
# cuántos puntos caen dentro de cada celda. Escribe el resultado
# como GeoPackage con una columna de conteo por celda.
#
# Entradas:
# data/processed/vessel_trajectories_{gear}.csv
# data/processed/individual_kde_all.rds
#
# Salida:
# data/processed/vms_{gear}_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# tidyverse
# sf
#
# Notas:
# - La rejilla se hereda del KDE individual de 95 albatros
# - Cada punto VMS cuenta como una observación sin ponderar
# - Los puntos VMS fuera de la extensión de la rejilla se ignoran
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos y gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta adehabitatHR para extraer la rejilla del estUDm
library(adehabitatHR)

# Lee el nombre del arte de pesca desde el primer argumento de la línea
# de comandos (por ejemplo, "trawler", "purse_seine", "other") para
# construir las rutas de los archivos de entrada y salida
gear <- commandArgs(trailingOnly = TRUE)[1]

# Ruta del archivo CSV con las trayectorias VMS de embarcaciones del
# arte de pesca especificado, filtradas por ZEE del Pacífico mexicano
input_vms_csv_path <- paste0(
  "data/processed/vessel_trajectories_", gear, ".csv"
)

# Ruta del archivo RDS con el KDE individuales
input_kde_rds_path <- "data/processed/individual_kde_all.rds"

# Ruta del archivo GeoPackage de salida con los conteos por celda
output_gpkg_path <- paste0("data/processed/vms_", gear, "_in_grid.gpkg")

# CRS geográfico WGS84 en el que están los puntos VMS crudos
crs_vms_wgs84 <- 4326

# Vector con los nombres de las columnas del CSV que necesitamos
# para evitar leer todo el archivo y reducir el consumo de memoria
selected_columns <- c("lat", "lon", "seg_id", "datetime")

# Nombre de la columna de conteo que se agregará a la rejilla,
# construido a partir del arte de pesca (ej. n_points_vms_trawler)
n_points_column <- paste0("n_points_vms_", gear)


# ==== ENTRADAS ====

# Carga el archivo RDS que contiene el KDE individual de 95 aves
kde_cache <- readRDS(input_kde_rds_path)

# Extrae la superficie KDE que es un objeto estUDm con la rejilla
# de densidad de utilización para cada individuo
kde_surface_estUDm <- kde_cache$KDE_surface

# Convierte el estUDm a un SpatialPixelsDataFrame donde cada
# columna representa la densidad de un individuo en cada píxel
kde_pixels_spdf <- estUDm2spixdf(kde_surface_estUDm)

# Convierte cada píxel de la rejilla en un polígono cuadrado
# para poder contar puntos dentro de cada celda con sf
kde_polygons_spdf <- as(kde_pixels_spdf, "SpatialPolygonsDataFrame")

# Convierte los polígonos espaciales a un objeto sf para
# trabajar con el ecosistema tidyverse de datos espaciales
grid_sf <- st_as_sf(kde_polygons_spdf)

# Descarta todas las columnas de densidad de los 95 individuos
# y solo conserva la geometría de la rejilla como partición vacía
grid_geometry <- st_geometry(grid_sf)

# Construye un sf limpio con solo la geometría y un identificador
# de celda para poder referenciar cada fila unívocamente
grid_cells <- st_sf(
  cell_id = seq_along(grid_geometry),
  geometry = grid_geometry
)

# Lee únicamente las columnas necesarias del archivo CSV de VMS
# para reducir el uso de memoria con 1.4 millones de filas
vms_points_table <- read_csv(
  input_vms_csv_path,
  col_select = all_of(selected_columns),
  show_col_types = FALSE
)

# Filtra las filas que tienen coordenadas completas para evitar
# errores de georreferenciación por valores ausentes
vms_points_clean <- vms_points_table |>
  filter(!is.na(lat) & !is.na(lon))

# Convierte la tabla de puntos VMS a un objeto sf geográfico en
# WGS84 usando las columnas lon y lat como coordenadas
vms_points_sf <- st_as_sf(
  vms_points_clean,
  coords = c("lon", "lat"),
  crs = crs_vms_wgs84
)

# Obtiene el CRS proyectado de la rejilla del KDE para poder
# transformar los puntos VMS al mismo sistema de referencia
grid_crs <- st_crs(grid_cells)

# Reproyecta los puntos VMS del CRS geográfico WGS84 al CRS
# de la rejilla para que las intersecciones sean correctas
vms_points_projected <- st_transform(vms_points_sf, crs = grid_crs)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Identifica qué puntos VMS caen dentro de cada celda de la
# rejilla usando intersección espacial entre ambas geometrías
n_points_per_cell <- st_intersects(grid_cells, vms_points_projected)

# Calcula el número de puntos VMS por celda aplicando la función
# lengths a la lista de intersecciones que devuelve st_intersects
n_points_count <- lengths(n_points_per_cell)

# Agrega el conteo de puntos VMS como una nueva columna en la
# rejilla usando el nombre dinámico construido a partir del arte
# de pesca, para tener ambos datos en un solo objeto espacial
grid_with_counts <- grid_cells |>
  mutate(!!n_points_column := n_points_count)


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla y los conteos de puntos
# VMS por celda para su uso en el análisis THS posterior
st_write(grid_with_counts, output_gpkg_path, delete_dsn = TRUE)
