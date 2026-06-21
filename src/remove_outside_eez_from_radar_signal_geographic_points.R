# ==========================================
# Título: Elimina puntos de radar fuera de la ZEE mexicana
#
# Contexto (Por qué):
# Los puntos de señal de radar de albatros de Guadalupe
# abarcan todo el Pacífico Norte, incluyendo aguas fuera de
# la ZEE mexicana que no son relevantes para el análisis.
#
# Descripción (Qué / Cómo):
# Lee el CSV de puntos geográficos de señal de radar y el
# shapefile de la ZEE mexicana. Convierte cada fila a un punto
# geográfico y conserva únicamente los puntos que caen dentro
# de la ZEE del Pacífico mexicano. Elimina la geometría espacial
# y escribe el resultado como CSV con la misma estructura original.
#
# Entradas:
# data/processed/radar_signal_geographic_points.csv
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# data/processed/radar_signal_geographic_points_in_eez.csv
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - La capa 2 del shapefile de ZEE corresponde al Pacífico mexicano
# - Los puntos exactamente sobre el borde del polígono se conservan
# - La columna geometry se elimina antes de escribir el CSV de salida
# - El CSV de salida conserva las mismas columnas que el de entrada
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para manipulación de datos tabulares con dplyr
library(tidyverse)

# Adjunta sf para operaciones espaciales de filtrado por polígono
library(sf)

# Ruta del shapefile de la Zona Económica Exclusiva de México que
# define el límite marítimo para filtrar los puntos fuera del área
input_eez_mexico_shp_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo CSV con los puntos de señal de radar que contiene
# las coordenadas geográficas de cada detección de albatros
input_radar_signal_csv_path <- "data/processed/radar_signal_geographic_points.csv"

# Ruta del archivo CSV de salida con únicamente los puntos de radar
# que caen dentro de la ZEE del Pacífico mexicano
output_radar_signal_csv_path <- "data/processed/radar_signal_geographic_points_in_eez.csv"

# CRS geográfico WGS84 en el que están codificadas las coordenadas
# de los puntos de radar y al que se transformará el shapefile
crs_wgs84 <- 4326

# Índice de la capa del shapefile de ZEE que corresponde al Pacífico
# mexicano, donde la capa 1 es la superficie continental y la capa 2
# es la Zona Económica Exclusiva del Pacífico mexicano
pacific_eez_shp_layer <- 2

# Nombre de la columna de longitud geográfica en el CSV de entrada
# que contiene la coordenada zonal de cada punto de radar
longitude_column_name <- "longitude"

# Nombre de la columna de latitud geográfica en el CSV de entrada
# que contiene la coordenada meridional de cada punto de radar
latitude_column_name <- "latitude"


# ==== ENTRADAS ====

# Importa el shapefile de la Zona Económica Exclusiva de México que
# contiene los polígonos marítimos de soberanía mexicana para filtrar
# espacialmente los puntos de radar que caen dentro de aguas mexicanas
eez_mexico_polygon <- st_read(input_eez_mexico_shp_path, quiet = TRUE)

# Transforma la EEZ a coordenadas geográficas WGS84 para que el CRS
# del polígono coincida con el CRS de las coordenadas de los puntos
# de radar que están expresadas en grados decimales
mexico_eez_wgs84 <- eez_mexico_polygon |>
  st_transform(crs_wgs84)

# Lee el CSV de puntos geográficos de señal de radar que contiene
# las coordenadas de cada detección y los metadatos de la señal
# registrada por los dispositivos de los albatros de Guadalupe
radar_signal_points_table <- read_csv(
  input_radar_signal_csv_path,
  show_col_types = FALSE
)

# Filtra las filas con coordenadas completas para evitar errores
# de georreferenciación durante la conversión a objeto espacial
# cuando alguna coordenada falta por fallo del dispositivo GPS
radar_signal_points_clean <- radar_signal_points_table |>
  filter(
    !is.na(.data[[longitude_column_name]]) &
      !is.na(.data[[latitude_column_name]])
  )

# Convierte la tabla de puntos de radar a un objeto sf geográfico
# en WGS84 conservando las columnas originales de latitud y longitud
# para mantener la estructura completa del CSV original en la salida
radar_signal_points_sf <- st_as_sf(
  radar_signal_points_clean,
  coords = c(longitude_column_name, latitude_column_name),
  crs = crs_wgs84,
  remove = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Determina qué puntos de radar caen dentro de la ZEE del Pacífico
# mexicano usando la capa seleccionada del shapefile transformado a
# WGS84 para que coincida con el CRS de los puntos de radar
is_inside_eez_mexico_matrix <- st_within(
  radar_signal_points_sf,
  mexico_eez_wgs84[pacific_eez_shp_layer, ],
  sparse = FALSE
)

# Convierte la matriz de una columna a un vector lógico donde cada
# posición indica si el punto correspondiente está dentro de la ZEE
# del Pacífico mexicano
is_inside_eez_vector <- is_inside_eez_mexico_matrix[, 1]

# Conserva únicamente los puntos de radar que están dentro de la ZEE
# del Pacífico mexicano para limitar el análisis a las aguas marítimas
# mexicanas donde las colonias de albatros de Guadalupe se distribuyen
radar_signal_in_eez_sf <- radar_signal_points_sf[is_inside_eez_vector, ]

# Elimina la columna de geometría espacial para devolver la tabla
# a un formato plano de CSV con las columnas originales de latitud,
# longitud y metadatos de cada punto de señal de radar sin modificar
radar_signal_in_eez_table <- radar_signal_in_eez_sf |>
  st_drop_geometry()


# ==== SALIDA ====

# Escribe el CSV con los puntos de señal de radar dentro de la ZEE
# del Pacífico mexicano para que los scripts de visualización
# procesen únicamente puntos del área de estudio mexicana
write_csv(radar_signal_in_eez_table, output_radar_signal_csv_path)
