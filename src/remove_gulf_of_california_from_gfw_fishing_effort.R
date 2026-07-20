# ==========================================
# Título: Elimina esfuerzo pesquero de GFW fuera del Pacífico mexicano
#
# Contexto (Por qué):
# El análisis de esfuerzo pesquero aparente de Global Fishing Watch
# se enfoca en aguas del Pacífico mexicano donde las colonias de
# albatros se distribuyen. Los datos fuera del Pacífico (Golfo de
# California, Golfo de México, Mar Caribe, Atlántico) introducen
# ruido en el análisis espacial y no son relevantes para el estudio.
#
# Descripción (Qué / Cómo):
# Lee el archivo KML del Golfo de California y el shapefile de la
# ZEE mexicana como referencias espaciales para filtrar. Lee el CSV
# de esfuerzo pesquero aparente de GFW con coordenadas Lat y Lon.
# Convierte cada fila a un punto geográfico y conserva únicamente
# los puntos que caen dentro de la ZEE del Pacífico mexicano pero
# fuera del Golfo de California. Escribe el resultado como CSV con
# la misma estructura original.
#
# Entradas:
# data/raw/gulf_of_california.kml
# data/external/Exclusive_economic_zone_Mexico.shp
# data/external/gfw_apparent_fishing_effort_in_mx_eez.csv
#
# Salida:
# data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv
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

# Ruta del shapefile de la Zona Económica Exclusiva de México que
# contiene múltiples capas para filtrar los eventos que ocurren
# dentro de aguas mexicanas
input_eez_mexico_shp_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo CSV con el esfuerzo pesquero aparente de GFW
# que contiene coordenadas de latitud y longitud por fila
input_gfw_fishing_effort_csv_path <- "data/external/gfw_apparent_fishing_effort_in_mx_eez.csv"

# Ruta del archivo CSV de salida con solo los puntos del Pacífico
output_gfw_fishing_effort_csv_path <- "data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv"

# CRS geográfico WGS84 en el que están codificados tanto el KML
# como las coordenadas de los puntos de pesca en el CSV
crs_wgs84 <- 4326


# ==== ENTRADAS ====

# Importa el polígono del Golfo de California desde el archivo KML
# que define el límite geográfico para filtrar los eventos que caen
# dentro de esta zona que está fuera del área de estudio
gulf_polygon <- st_read(input_gulf_kml_path, quiet = TRUE)

# Importa el shapefile de la Zona Económica Exclusiva de México que
# contiene múltiples capas para filtrar los eventos que ocurren
# dentro de aguas mexicanas
eez_mexico_polygon <- st_read(input_eez_mexico_shp_path, quiet = TRUE)

# Transforma la EEZ a coordenadas geográficas WGS84 para que los
# límites coincidan con el CRS de los puntos de pesca
mexico_eez_wgs84 <- eez_mexico_polygon |>
  st_transform(crs_wgs84)

# Lee el CSV de esfuerzo pesquero aparente de GFW que contiene las
# coordenadas de latitud y longitud de cada punto de actividad pesquera
gfw_fishing_effort_table <- read_csv(
  input_gfw_fishing_effort_csv_path,
  show_col_types = FALSE
)

# Filtra las filas con coordenadas completas para evitar errores
# de georreferenciación durante la conversión a objeto espacial
gfw_fishing_effort_clean <- gfw_fishing_effort_table |>
  filter(!is.na(Lat) & !is.na(Lon))

# Convierte la tabla de puntos de pesca a un objeto sf geográfico
# en WGS84 conservando las columnas originales de latitud y longitud
# para la escritura posterior del CSV
gfw_fishing_effort_sf <- st_as_sf(
  gfw_fishing_effort_clean,
  coords = c("Lon", "Lat"),
  crs = crs_wgs84,
  remove = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Determina qué puntos de pesca caen dentro del polígono del
# Golfo de California usando la matriz densa de evaluación espacial
# que compara cada punto contra el único polígono de referencia
is_inside_gulf_matrix <- st_within(gfw_fishing_effort_sf, gulf_polygon, sparse = FALSE)

# Índice de la capa del shapefile de ZEE que corresponde al Pacífico
# mexicano
pacific_eez_shp_layer <- 2

# Determina qué puntos de pesca caen dentro de la ZEE del Pacífico
# mexicano usando la capa seleccionada del shapefile transformado a
# WGS84 para que coincida con el CRS de los puntos de pesca
is_inside_eez_mexico_matrix <- st_within(gfw_fishing_effort_sf, mexico_eez_wgs84[pacific_eez_shp_layer, ], sparse = FALSE)

# Convierte cada matriz de una columna a vectores lógicos donde cada
# posición indica si el punto correspondiente está dentro del Golfo
# de California o dentro de la ZEE del Pacífico mexicano
is_inside_gulf_vector <- is_inside_gulf_matrix[, 1]
is_inside_eez_vector <- is_inside_eez_mexico_matrix[, 1]

# Conserva únicamente los puntos de pesca que están dentro de la
# ZEE del Pacífico mexicano pero fuera del Golfo de California para
# limitar el análisis al área de estudio del Pacífico mexicano donde
# se distribuyen las colonias de albatros
gfw_fishing_effort_pacifico_sf <- gfw_fishing_effort_sf[is_inside_eez_vector & !is_inside_gulf_vector, ]

# Elimina la columna de geometría espacial para devolver la tabla
# a un formato plano de CSV con las columnas originales de latitud,
# longitud y metadatos de cada punto de esfuerzo pesquero
gfw_fishing_effort_pacifico_table <- gfw_fishing_effort_pacifico_sf |>
  st_drop_geometry()


# ==== SALIDA ====

# Escribe el CSV con el esfuerzo pesquero aparente de GFW dentro
# del Océano Pacífico mexicano para que los scripts de análisis
# posteriores procesen solamente puntos del área de estudio
write_csv(gfw_fishing_effort_pacifico_table, output_gfw_fishing_effort_csv_path)
