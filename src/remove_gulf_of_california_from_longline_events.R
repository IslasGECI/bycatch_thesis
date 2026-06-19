# ==========================================
# Título: Elimina eventos de palangre dentro del Golfo de California
#
# Contexto (Por qué):
# El análisis de hot spots de palangre se enfoca en aguas del
# Pacífico mexicano donde las colonias de albatros se distribuyen.
# Los eventos dentro del Golfo de California representan una zona
# oceanográfica distinta que no es utilizada por las aves de las
# colonias estudiadas e introduciría ruido en el análisis espacial.
#
# Descripción (Qué / Cómo):
# Lee el archivo KML del Golfo de California y el shapefile de la
# ZEE mexicana como referencias espaciales para filtrar. Lee el CSV
# de eventos de palangre en formato largo con coordenadas de inicio
# y fin por fila. Convierte cada fila a un punto geográfico y
# conserva únicamente los puntos que caen dentro de la ZEE del
# Pacífico mexicano pero fuera del Golfo de California. Escribe el
# resultado como CSV con la misma estructura original.
#
# Entradas:
# data/raw/gulf_of_california.kml
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/longline_events_long.csv
#
# Salida:
# data/processed/longline_events_in_eez_without_gulf_of_california.csv
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - El filtro espacial usa el CRS geográfico WGS84 de los tres archivos
# - La capa 2 del shapefile de ZEE corresponde al Pacífico mexicano
# - Los puntos exactamente sobre el borde del polígono se conservan
# - La columna geometry se elimina antes de escribir el CSV de salida
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para manipulación de datos tabulares con dplyr
library(tidyverse)

# Adjunta sf para operaciones espaciales de filtrado por polígono
library(sf)

# Ruta del archivo KML con el polígono del Golfo de California
input_gulf_kml_path <- "data/raw/gulf_of_california.kml"
input_eez_mexico_shp_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo CSV con los eventos de palangre en formato largo
input_longline_csv_path <- "data/processed/longline_events_long.csv"

# Ruta del archivo CSV de salida sin eventos dentro del Golfo
output_longline_csv_path <- "data/processed/longline_events_in_eez_without_gulf_of_california.csv"

# CRS geográfico WGS84 en el que están codificados tanto el KML
# como las coordenadas de los puntos de palangre en el CSV
crs_wgs84 <- 4326


# ==== ENTRADAS ====

# Importa el polígono del Golfo de California desde el archivo KML
# que define el límite geográfico para filtrar los eventos que caen
# dentro de esta zona que está fuera del área de estudio
gulf_polygon <- st_read(input_gulf_kml_path, quiet = TRUE)

# Importa el shapefile de la Zona Económica Exclusiva de México que
# contiene múltiples capas para filtrar los eventos que ocurren dentro de aguas mexicanas
eez_mexico_polygon <- st_read(input_eez_mexico_shp_path, quiet = TRUE)

# Transforma la EEZ a coordenadas geográficas WGS84 para que los límites
# del bounding box definidos en grados coincidan con la geometría
mexico_eez_wgs84 <- eez_mexico_polygon |>
  st_transform(crs_wgs84)

# Lee el CSV de eventos de palangre en formato largo que contiene
# las coordenadas de inicio y fin de cada operación de pesca en
# columnas separadas de latitud y longitud geográficas
longline_points_table <- read_csv(
  input_longline_csv_path,
  show_col_types = FALSE
)

# Filtra las filas con coordenadas completas para evitar errores
# de georreferenciación durante la conversión a objeto espacial
longline_points_clean <- longline_points_table |>
  filter(!is.na(lat) & !is.na(lon))

# Convierte la tabla de puntos de palangre a un objeto sf
# geográfico en WGS84 conservando las columnas originales de
# latitud y longitud para la escritura posterior del CSV
longline_points_sf <- st_as_sf(
  longline_points_clean,
  coords = c("lon", "lat"),
  crs = crs_wgs84,
  remove = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Determina qué puntos de palangre caen dentro del polígono del
# Golfo de California usando la matriz densa de evaluación espacial
# que compara cada punto contra el único polígono de referencia
is_inside_gulf_matrix <- st_within(longline_points_sf, gulf_polygon, sparse = FALSE)

# Índice de la capa del shapefile de ZEE que corresponde al Pacífico
# mexicano
pacific_eez_shp_layer <- 2

# Determina qué puntos de palangre caen dentro de la ZEE del Pacífico
# mexicano usando la capa seleccionada del shapefile transformado a
# WGS84 para que coincida con el CRS de los puntos de palangre
is_inside_eez_mexico_matrix <- st_within(longline_points_sf, mexico_eez_wgs84[pacific_eez_shp_layer, ], sparse = FALSE)

# Convierte cada matriz de una columna a vectores lógicos donde cada
# posición indica si el punto correspondiente está dentro del Golfo
# de California o dentro de la ZEE del Pacífico mexicano
is_inside_gulf_vector <- is_inside_gulf_matrix[, 1]
is_inside_eez_vector <- is_inside_eez_mexico_matrix[, 1]

# Conserva únicamente los puntos de palangre que están dentro de la
# ZEE del Pacífico mexicano pero fuera del Golfo de California para
# limitar el análisis de hot spots a las aguas del Pacífico mexicano
# que son utilizadas por los albatros de las colonias estudiadas
longline_inside_eez_outside_gulf_sf <- longline_points_sf[is_inside_eez_vector & !is_inside_gulf_vector, ]

# Elimina la columna de geometría espacial para devolver la tabla
# a un formato plano de CSV con las columnas originales de latitud,
# longitud y metadatos de cada evento de palangre
longline_inside_eez_outside_gulf_table <- longline_inside_eez_outside_gulf_sf |>
  st_drop_geometry()


# ==== SALIDA ====

# Escribe el CSV con los eventos de palangre dentro de la ZEE del
# Pacífico mexicano pero fuera del Golfo de California para que el
# script de conteo por celda de la rejilla del KDE procese solamente
# puntos del área de estudio del Pacífico mexicano
write_csv(longline_inside_eez_outside_gulf_table, output_longline_csv_path)
