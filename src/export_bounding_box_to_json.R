# ==========================================
# Título: Calcular Bounding Box Redondeado a Partir de Datos GPS de Albatros
#
# Contexto (Por qué):
# Para mantener consistencia entre scripts de análisis y visualización,
# es conveniente definir la región espacial de trabajo mediante un
# bounding box almacenado en un archivo de configuración. En lugar de
# definir manualmente los límites geográficos, este script calcula el
# bounding box directamente a partir de los datos GPS de albatros.
#
# Descripción (Qué / Cómo):
# El script carga el archivo CSV con registros GPS, calcula los valores
# mínimos y máximos de longitud y latitud, y posteriormente expande
# estos límites al múltiplo de 5 grados más cercano utilizando
# floor() y ceiling(). Esto produce límites cartográficos más limpios
# y fáciles de interpretar en mapas regionales.
#
# Entradas:
# data/processed/gps_albatross_all.csv
#
# Salidas:
# data/processed/bounding_box.json
#
# Dependencias:
# tidyverse
# jsonlite
#
# Notas:
# El redondeo asegura que:
#   - límites oeste y sur se redondeen hacia abajo
#   - límites este y norte se redondeen hacia arriba
# Se añade un buffer de 1 grado para dejar margen en el bounding box
# ==========================================


# ==== HEADER ====
library(tidyverse)
library(jsonlite)


# ==== CONFIGURATION ====
input_csv_path <- "data/processed/gps_albatross_all.csv"
output_json_path <- "data/processed/bounding_box.json"

rounding_multiple <- 10
buffer <- 1 # Grados adicionales para asegurar que el bounding box deje un margen


# ==== INPUTS ====
gps_data <- read_csv(input_csv_path, show_col_types = FALSE)


# ==== PROCESS / ANALYSIS ====
# Se calcula el bounding box mínimo que contiene todos los puntos GPS
bbox_raw <- gps_data |>
  summarise(
    lon_min = min(longitude, na.rm = TRUE) - buffer,
    lon_max = max(longitude, na.rm = TRUE) + buffer,
    lat_min = min(latitude, na.rm = TRUE) - buffer,
    lat_max = max(latitude, na.rm = TRUE) + buffer
  )

# Se redondean los límites al múltiplo de 5 más cercano
bbox_rounded <- bbox_raw |>
  mutate(
    lon_min = floor(lon_min / rounding_multiple) * rounding_multiple,
    lon_max = ceiling(lon_max / rounding_multiple) * rounding_multiple,
    lat_min = floor(lat_min / rounding_multiple) * rounding_multiple,
    lat_max = ceiling(lat_max / rounding_multiple) * rounding_multiple
  )


# ==== CREATE JSON STRUCTURE ====
# Se convierte la tabla a lista para generar la estructura JSON deseada
bbox_list <- list(
  bbox = list(
    lon_min = bbox_rounded$lon_min,
    lon_max = bbox_rounded$lon_max,
    lat_min = bbox_rounded$lat_min,
    lat_max = bbox_rounded$lat_max
  )
)


# ==== OUTPUT ====
# Se exporta el archivo JSON de configuración
write_json(
  bbox_list,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE
)
