# ================================
# Concatena archivos CSV con columnas distintas con puntos geográficos de viajes de alimentación.
#
# Por qué:
# En los datos de GPS de Isla Guadalupe e Isla Clarión las columnas no coinciden exactamente.
# Necesitamos asegurar que las columnas se alineen por nombre y que los datos faltantes se rellenen
# correctamente.
#
# Cómo:
# Lee dos archivos CSV, estandarizar columnas implícitamente mediante bind_rows, y exportar un
# único archivo combinado.
#
# Entradas:
# - data/processed/trips_geographic_points_clarion.csv
# - data/processed/trips_geographic_points_guadalupe.csv
#
# Salida:
# - data/processed/trips_geographic_points_all.csv
#
# Dependencias:
# - tidyverse

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
