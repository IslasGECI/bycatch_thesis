# ==========================================
# Título: Cuenta puntos de palangre de GFW por celda de la rejilla del KDE
#
# Contexto (Por qué):
# Necesitamos una partición espacial común para comparar la
# presión pesquera de palangre con las áreas de distribución
# de aves marinas. La rejilla del KDE individual proporciona
# esa partición para las tres colonias de albatros.
#
# Descripción (Qué / Cómo):
# Extrae la rejilla vacía del estUDm guardado en el RDS del
# KDE individual de todas las colonias. Convierte cada píxel
# de la rejilla a un polígono usando el paquete sp. Lee los
# puntos de palangre en formato largo, los reproyecta al CRS
# de la rejilla y cuenta cuántos puntos caen dentro de cada
# celda. Escribe el resultado como GeoPackage con una columna
# de conteo por celda.
#
# Entradas:
# data/processed/longline_events_without_gulf_of_california.csv
# data/processed/individual_kde_all.rds
#
# Salida:
# data/processed/gfw_longline_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# sf
# tidyverse
#
# Notas:
# - La rejilla se hereda del KDE individual de las tres colonias
# - Cada punto extremo (inicio o fin) cuenta como una observación
# - Los puntos fuera de la extensión de la rejilla se ignoran
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos y gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta adehabitatHR para extraer la rejilla del estUDm
library(adehabitatHR)

# Ruta del archivo CSV con los eventos de palangre en formato largo
input_longline_csv_path <- "data/processed/longline_events_without_gulf_of_california.csv"

# Ruta del archivo RDS con el KDE individual de todas las colonias
input_kde_rds_path <- "data/processed/individual_kde_all.rds"

# Ruta del archivo GeoPackage de salida con los conteos por celda
output_gpkg_path <- "data/processed/gfw_longline_in_grid.gpkg"

# CRS geográfico WGS84 en el que están los puntos de palangre crudos
crs_longline_wgs84 <- 4326

# Vector con los nombres de las columnas del CSV que necesitamos
# para evitar leer todo el archivo y reducir el consumo de memoria
selected_columns <- c("lat", "lon", "set_id", "ssvid", "label", "start_end")


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
# eventos de palangre en formato largo para reducir memoria
longline_points_table <- read_csv(
  input_longline_csv_path,
  col_select = all_of(selected_columns),
  show_col_types = FALSE
)

# Filtra las filas que tienen coordenadas completas para evitar
# errores de georreferenciación por valores ausentes en latitud
# o longitud
longline_points_clean <- longline_points_table |>
  filter(!is.na(lat) & !is.na(lon))

# Convierte la tabla de puntos de palangre a un objeto sf
# geográfico en WGS84 usando las columnas lon y lat como
# coordenadas de cada punto extremo de evento
longline_points_sf <- st_as_sf(
  longline_points_clean,
  coords = c("lon", "lat"),
  crs = crs_longline_wgs84
)

# Obtiene el CRS proyectado de la rejilla del KDE para poder
# transformar los puntos de palangre al mismo sistema de referencia
grid_crs <- st_crs(grid_cells)

# Reproyecta los puntos de palangre del CRS geográfico WGS84 al
# CRS de la rejilla para que las intersecciones sean correctas
longline_points_projected <- st_transform(longline_points_sf, crs = grid_crs)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Identifica qué puntos de palangre caen dentro de cada celda
# de la rejilla usando intersección espacial entre ambas geometrías
n_points_per_cell <- st_intersects(grid_cells, longline_points_projected)

# Calcula el número de puntos de palangre por celda aplicando
# la función lengths a la lista de intersecciones que devuelve
# st_intersects
n_points_count <- lengths(n_points_per_cell)

# Agrega el conteo de puntos de palangre como una nueva columna
# en la rejilla para tener ambos datos en un solo objeto espacial
grid_with_counts <- grid_cells |>
  mutate(n_points_gfw_longline = n_points_count)


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla y los conteos de puntos
# de palangre de GFW por celda para su uso en el análisis THS
# posterior de identificación de hot spots
st_write(grid_with_counts, output_gpkg_path, delete_dsn = TRUE)
