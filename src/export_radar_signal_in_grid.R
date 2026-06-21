# ==========================================
# Título: Suma señal de radar por celda de la rejilla del KDE
#
# Contexto (Por qué):
# Necesitamos una partición espacial común para comparar la
# intensidad de señal de radar de los albatros con las áreas de
# congestión de embarcaciones. La rejilla del KDE individual
# proporciona esa partición.
#
# Descripción (Qué / Cómo):
# Extrae la rejilla vacía del estUDm guardado en el RDS del
# KDE individual. Convierte cada píxel de la rejilla a un
# polígono usando el paquete sp. Lee los puntos de señal de
# radar, los reproyecta al CRS de la rejilla y suma los valores
# de radar_signal dentro de cada celda. Las celdas sin puntos
# reciben un valor de cero. Escribe el resultado como GeoPackage
# con una columna de suma por celda.
#
# Entradas:
# data/processed/radar_signal_geographic_points_in_eez.csv
# data/processed/individual_kde_all.rds
#
# Salida:
# data/processed/radar_signal_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# purrr
# sf
# tidyverse
#
# Notas:
# - La rejilla se hereda del KDE individual de 95 albatros
# - Cada celda contiene la suma total de señal de radar observada
# - Las celdas sin puntos de radar reciben valor cero
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

# Ruta del archivo CSV con los puntos de señal de radar de
# albatros dentro de la ZEE del Pacífico mexicano
input_radar_signal_csv_path <- "data/processed/radar_signal_geographic_points_in_eez.csv"

# Ruta del archivo RDS con el KDE individual de todas las colonias
input_kde_rds_path <- "data/processed/individual_kde_all.rds"

# Ruta del archivo GeoPackage de salida con las sumas por celda
output_gpkg_path <- "data/processed/radar_signal_in_grid.gpkg"

# CRS geográfico WGS84 en el que están los puntos de señal crudos
crs_radar_signal_wgs84 <- 4326

# Vector con los nombres de las columnas del CSV que necesitamos
# para evitar leer todo el archivo y reducir el consumo de memoria
selected_columns <- c("radar_signal", "longitude", "latitude")


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
# puntos de señal de radar para reducir el uso de memoria
radar_signal_points_table <- read_csv(
  input_radar_signal_csv_path,
  col_select = all_of(selected_columns),
  show_col_types = FALSE
)

# Filtra las filas que tienen coordenadas completas para evitar
# errores de georreferenciación por valores ausentes en latitud
# o longitud
radar_signal_points_clean <- radar_signal_points_table |>
  filter(!is.na(longitude) & !is.na(latitude))

# Extrae la columna de señal de radar como vector numérico para
# poder indexarla directamente al sumar por celda más adelante
radar_signal_values <- radar_signal_points_clean$radar_signal

# Convierte la tabla de puntos de señal de radar a un objeto sf
# geográfico en WGS84 usando las columnas longitude y latitude
# como coordenadas de cada detección de radar
radar_signal_points_sf <- st_as_sf(
  radar_signal_points_clean,
  coords = c("longitude", "latitude"),
  crs = crs_radar_signal_wgs84
)

# Obtiene el CRS proyectado de la rejilla del KDE para poder
# transformar los puntos de señal al mismo sistema de referencia
grid_crs <- st_crs(grid_cells)

# Reproyecta los puntos de señal de radar del CRS geográfico
# WGS84 al CRS de la rejilla para que las intersecciones sean
# correctas entre ambas geometrías
radar_signal_points_projected <- st_transform(
  radar_signal_points_sf,
  crs = grid_crs
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Identifica qué puntos de señal de radar caen dentro de cada
# celda de la rejilla usando intersección espacial entre ambas
# geometrías. El resultado es una lista donde cada elemento
# contiene los índices de los puntos en esa celda
point_indices_per_cell <- st_intersects(grid_cells, radar_signal_points_projected)

# Suma los valores de señal de radar por celda aplicando la
# función sum sobre el subconjunto de valores indicado por los
# índices de cada celda. sum() devuelve cero para vectores
# vacíos, lo que asigna automáticamente cero a las celdas sin
# puntos de señal de radar
sum_radar_signal_per_cell <- map_dbl(
  point_indices_per_cell,
  ~ sum(radar_signal_values[.x])
)

# Agrega la suma de señal de radar como una nueva columna en
# la rejilla para tener ambos datos en un solo objeto espacial
grid_with_sums <- grid_cells |>
  mutate(sum_radar_signal = sum_radar_signal_per_cell)


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla y las sumas de señal
# de radar por celda para su uso en el análisis THS posterior
# de identificación de zonas de alta intensidad de señal
st_write(grid_with_sums, output_gpkg_path, delete_dsn = TRUE)
