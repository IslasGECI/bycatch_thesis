# ==========================================
# Título: Concatenar Puntos Geográficos de Viajes de Alimentación de Albatros
#
# Contexto (Por qué):
# Los datos de GPS de albatros de las islas Guadalupe y Clarión contienen
# puntos geográficos de viajes de alimentación. Las columnas de ambos
# archivos no coinciden exactamente, por lo que es necesario estandarizarlos
# y combinarlos en un único dataset para análisis posteriores.
#
# Descripción (Qué / Cómo):
# El script carga los dos archivos CSV de puntos geográficos de viajes,
# los combina automáticamente mediante bind_rows() que alinea las columnas
# por nombre, y exporta el resultado como un archivo CSV unificado.
#
# Entradas:
# data/processed/trips_geographic_points_clarion.csv
# data/processed/trips_geographic_points_guadalupe.csv
#
# Salidas:
# data/processed/trips_geographic_points_all.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# Se utiliza bind_rows() que automáticamente estandariza las columnas.
# Los datos faltantes en una tabla se rellenan con NA al combinar.
# ==========================================

# ==== HEADER ====
library(tidyverse)  # Proporciona readr y dplyr para importar y manipular tablas

# ================================
# Configuración
# ================================
input_file_clarion_path <- "data/processed/trips_geographic_points_clarion.csv"
input_file_guadalupe_path <- "data/processed/trips_geographic_points_guadalupe.csv"
output_file_combined_path <- "data/processed/trips_geographic_points_all.csv"

# ================================
# Entradas
# ================================
clarion_data_frame <- readr::read_csv(input_file_clarion_path)
guadalupe_data_frame <- readr::read_csv(input_file_guadalupe_path)

# ================================
# Procesamiento / Análisis
# ================================
combined_data_frame <- dplyr::bind_rows(clarion_data_frame, guadalupe_data_frame)

# ================================
# Salida
# ================================
readr::write_csv(combined_data_frame, output_file_combined_path)
