# ==========================================
# Título: Suma horas de pesca aparente de GFW por celda de la rejilla del KDE
#
# Contexto (Por qué):
# Necesitamos una partición espacial común para comparar la
# presión pesquera (horas de pesca aparente) con las áreas de
# distribución de aves marinas. La rejilla del KDE individual
# proporciona esa partición para las tres colonias de albatros.
#
# Descripción (Qué / Cómo):
# Extrae la rejilla vacía del estUDm guardado en el RDS del
# KDE individual de todas las colonias. Convierte cada píxel
# de la rejilla a un polígono usando el paquete sp. Lee las
# horas de pesca aparente de GFW en formato CSV, reproyecta
# los puntos al CRS de la rejilla y suma las horas de pesca
# dentro de cada celda. Las celdas sin puntos reciben valor
# cero. Escribe el resultado como GeoPackage con una columna
# de suma por celda.
#
# Entradas:
# data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv
# data/processed/individual_kde_all.rds
#
# Salida:
# data/processed/gfw_apparent_fishing_hours_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# purrr
# sf
# tidyverse
#
# Notas:
# - La rejilla se hereda del KDE individual de las tres colonias
# - Cada fila representa un evento de pesca con sus horas acumuladas
# - Los puntos fuera de la extensión de la rejilla se ignoran
# - Las celdas sin eventos de pesca reciben valor cero
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos y gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta adehabitatHR para extraer la rejilla del estUDm
library(adehabitatHR)

# Adjunta purrr para aplicar funciones sobre listas de forma
# vectorizada sin escribir ciclos explícitos
library(purrr)

# Ruta del archivo CSV con las horas de pesca aparente de GFW
# dentro de la ZEE del Pacífico mexicano
input_gfw_csv_path <- "data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv"

# Ruta del archivo RDS con el KDE individual de todas las colonias
input_kde_rds_path <- "data/processed/individual_kde_all.rds"

# Ruta del archivo GeoPackage de salida con las sumas por celda
output_gpkg_path <- "data/processed/gfw_apparent_fishing_hours_in_grid.gpkg"

# CRS geográfico WGS84 en el que están los puntos de pesca crudos
crs_gfw_wgs84 <- 4326

# Vector con los nombres de las columnas del CSV que necesitamos
# para evitar leer todo el archivo y reducir el consumo de memoria
selected_columns <- c("Lat", "Lon", "Apparent Fishing Hours")


# ==== ENTRADAS ====

# Carga el archivo RDS que contiene el KDE individual de las
# tres colonias de albatros generado por bycatch::create_individual_kde
kde_cache <- readRDS(input_kde_rds_path)

# Extrae la superficie KDE que es un objeto estUDm con la rejilla
# de densidad de utilización para cada individuo de todas las colonias
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

# Descarta todas las columnas de densidad de los individuos
# y solo conserva la geometría de la rejilla como partición vacía
grid_geometry <- st_geometry(grid_sf)

# Construye un sf limpio con solo la geometría y un identificador
# de celda para poder referenciar cada fila unívocamente
grid_cells <- st_sf(
  cell_id = seq_along(grid_geometry),
  geometry = grid_geometry
)

# Lee únicamente las columnas necesarias del archivo CSV de
# horas de pesca aparente de GFW para reducir el uso de memoria
gfw_points_table <- read_csv(
  input_gfw_csv_path,
  col_select = all_of(selected_columns),
  show_col_types = FALSE
)

# Filtra las filas que tienen coordenadas completas para evitar
# errores de georreferenciación por valores ausentes en latitud
# o longitud
gfw_points_clean <- gfw_points_table |>
  filter(!is.na(Lat) & !is.na(Lon))

# Extrae la columna de horas de pesca aparente como vector numérico
# para poder indexarla directamente al sumar por celda más adelante
gfw_fishing_hours_values <- gfw_points_clean[["Apparent Fishing Hours"]]

# Convierte la tabla de puntos de pesca a un objeto sf
# geográfico en WGS84 usando las columnas Lon y Lat como
# coordenadas de cada evento de pesca
gfw_points_sf <- st_as_sf(
  gfw_points_clean,
  coords = c("Lon", "Lat"),
  crs = crs_gfw_wgs84
)

# Obtiene el CRS proyectado de la rejilla del KDE para poder
# transformar los puntos de pesca al mismo sistema de referencia
grid_crs <- st_crs(grid_cells)

# Reproyecta los puntos de pesca del CRS geográfico WGS84 al
# CRS de la rejilla para que las intersecciones sean correctas
gfw_points_projected <- st_transform(gfw_points_sf, crs = grid_crs)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Identifica qué puntos de pesca caen dentro de cada celda
# de la rejilla usando intersección espacial entre ambas geometrías
point_indices_per_cell <- st_intersects(grid_cells, gfw_points_projected)

# Suma las horas de pesca aparente por celda aplicando la
# función sum sobre el subconjunto de valores indicado por los
# índices de cada celda. sum() devuelve cero para vectores
# vacíos, lo que asigna automáticamente cero a las celdas sin
# eventos de pesca
sum_fishing_hours_per_cell <- map_dbl(
  point_indices_per_cell,
  ~ sum(gfw_fishing_hours_values[.x])
)

# Agrega la suma de horas de pesca aparente como una nueva
# columna en la rejilla para tener ambos datos en un solo
# objeto espacial
grid_with_sums <- grid_cells |>
  mutate(sum_gfw_apparent_fishing_hours = sum_fishing_hours_per_cell)


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla y las sumas de horas
# de pesca aparente de GFW por celda para su uso en el análisis
# THS posterior de identificación de zonas de alta presión pesquera
st_write(grid_with_sums, output_gpkg_path, delete_dsn = TRUE)
