# ==========================================
# Título: Calcula el bounding box redondeado a partir de datos GPS de albatros
#
# Contexto (Por qué):
# Para mantener consistencia entre scripts de análisis y visualización
# es necesario definir la región espacial de trabajo mediante un bounding
# box almacenado en un archivo de configuración. Calcularlo directamente
# a partir de los datos GPS evita definir manualmente los límites.
#
# Descripción (Qué / Cómo):
# Carga el archivo CSV con registros GPS, calcula los valores mínimos
# y máximos de longitud y latitud, y expande estos límites al múltiplo
# de 5 grados más cercano. Agrega un buffer de 1 grado para dejar margen
# y exporta el resultado como JSON para que otros scripts lo consuman.
#
# Entradas:
# data/processed/gps_albatross_all.csv
#
# Salida:
# data/processed/bounding_box.json
#
# Dependencias:
# tidyverse
# jsonlite
#
# Notas:
# - El redondeo usa floor() para límites inferiores y ceiling() para superiores
# - El buffer de 1 grado evita que puntos queden exactamente sobre el borde
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse)  # Proporciona readr para importar datos y dplyr para transformaciones
library(jsonlite)   # Proporciona write_json para exportar el bounding box como JSON

# Ruta del archivo CSV con los registros GPS combinados de ambas colonias
input_csv_path <- "data/processed/gps_albatross_all.csv"
# Ruta del archivo JSON que almacenará el bounding box de la región de estudio
output_json_path <- "data/processed/bounding_box.json"

# Múltiplo de redondeo para obtener límites cartográficos limpios
rounding_multiple <- 10
# Grados adicionales para evitar que puntos queden exactamente sobre el borde
buffer <- 1


# ==== ENTRADAS ====
# Carga los registros GPS de albatros desde el archivo CSV consolidado
gps_data <- read_csv(input_csv_path, show_col_types = FALSE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Calcula los valores extremos de longitud y latitud con un margen de seguridad
bbox_raw <- gps_data |>
  summarise(
    lon_min = min(longitude, na.rm = TRUE) - buffer,
    lon_max = max(longitude, na.rm = TRUE) + buffer,
    lat_min = min(latitude, na.rm = TRUE) - buffer,
    lat_max = max(latitude, na.rm = TRUE) + buffer
  )

# Redondea los límites al múltiplo de 5 grados más cercano para obtener
# coordenadas cartográficas limpias y fáciles de interpretar en mapas
bbox_rounded <- bbox_raw |>
  mutate(
    lon_min = floor(lon_min / rounding_multiple) * rounding_multiple,
    lon_max = ceiling(lon_max / rounding_multiple) * rounding_multiple,
    lat_min = floor(lat_min / rounding_multiple) * rounding_multiple,
    lat_max = ceiling(lat_max / rounding_multiple) * rounding_multiple
  )

# Convierte la tabla de una fila en una lista anidada con la estructura
# JSON esperada por los scripts de visualización del proyecto
bbox_list <- list(
  bbox = list(
    lon_min = bbox_rounded$lon_min,
    lon_max = bbox_rounded$lon_max,
    lat_min = bbox_rounded$lat_min,
    lat_max = bbox_rounded$lat_max
  )
)


# ==== SALIDA ====
# Exporta el bounding box como JSON de configuración para mantener
# la consistencia espacial entre todos los scripts del pipeline
write_json(
  bbox_list,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE
)
