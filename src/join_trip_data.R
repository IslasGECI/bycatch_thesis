# ==========================================
# Título: Concatena los puntos geográficos de viajes de alimentación de albatros
#
# Contexto (Por qué):
# Los datos GPS de albatros de las islas Guadalupe y Clarión contienen
# puntos geográficos de viajes de alimentación. Las columnas de ambos
# archivos no coinciden exactamente, por lo que es necesario combinarlos
# en un único dataset estandarizado para los análisis posteriores.
#
# Descripción (Qué / Cómo):
# Carga los dos archivos CSV de puntos geográficos de viajes, los combina
# mediante bind_rows() que alinea automáticamente las columnas por nombre
# y exporta el resultado como un archivo CSV unificado para el pipeline.
#
# Entradas:
# data/processed/trips_geographic_points_clarion.csv
# data/processed/trips_geographic_points_guadalupe.csv
#
# Salida:
# data/processed/trips_geographic_points_all.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - bind_rows() alinea las columnas por nombre y rellena con NA las que faltan
# - Los datos faltantes en una tabla se rellenan con NA al combinar
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse)  # Proporciona readr para importar CSVs y dplyr para combinar tablas

# Ruta del archivo CSV con los puntos geográficos de viajes de Clarión
input_file_clarion_path <- "data/processed/trips_geographic_points_clarion.csv"
# Ruta del archivo CSV con los puntos geográficos de viajes de Guadalupe
input_file_guadalupe_path <- "data/processed/trips_geographic_points_guadalupe.csv"
# Ruta del archivo CSV de salida con los puntos combinados de ambas colonias
output_file_combined_path <- "data/processed/trips_geographic_points_all.csv"


# ==== ENTRADAS ====
# Importa los puntos geográficos de viajes de la colonia de Clarión
clarion_data <- read_csv(input_file_clarion_path, show_col_types = FALSE)
# Importa los puntos geográficos de viajes de la colonia de Guadalupe
guadalupe_data <- read_csv(input_file_guadalupe_path, show_col_types = FALSE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Combina ambas tablas alineando las columnas por nombre para obtener
# un único dataset con todos los viajes de alimentación de ambas colonias
combined_data <- bind_rows(clarion_data, guadalupe_data)


# ==== SALIDA ====
# Exporta el dataset combinado como CSV para consumir en los scripts
# de análisis de distribución espacial y modelado de hábitat
write_csv(
  combined_data,
  output_file_combined_path
)
