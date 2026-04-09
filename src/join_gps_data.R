# ==========================================
# Title: Concatenate Albatross GPS Tracks from Guadalupe and Clarion
#
# Background (Why):
# Los registros GPS de albatros provienen de dos colonias diferentes
# (Guadalupe y Clarión). Para facilitar análisis posteriores de
# movimientos y distribución espacial, es conveniente consolidar
# ambos archivos en un único dataset estandarizado.
#
# What / How:
# El script carga los dos archivos CSV originales, selecciona
# únicamente las columnas que ambos comparten y agrega una columna
# que identifica la isla de origen de cada registro. Finalmente,
# concatena ambas tablas y exporta el resultado como un nuevo CSV.
#
# Inputs:
# data/raw/gps-albatros-guadalupe.csv
# data/raw/gps-albatros-clarion.csv
#
# Outputs:
# data/processed/gps_albatross_all.csv
#
# Dependencies:
# tidyverse
#
# Notes:
# Solo se conservan las columnas comunes necesarias para el análisis:
# date, time, longitude, latitude, name y Altitude.
# ==========================================


# ==== HEADER ====
library(tidyverse)  # Proporciona readr y dplyr para importar y manipular tablas


# ==== CONFIGURATION ====
# Centralizar rutas y constantes facilita mantenimiento del pipeline
input_guadalupe_path <- "data/raw/gps-albatros-guadalupe.csv"
input_clarion_path <- "data/raw/gps-albatros-clarion.csv"

output_csv_path <- "data/processed/gps_albatross_all.csv"

column_date <- "date"
column_time <- "time"
column_longitude <- "longitude"
column_latitude <- "latitude"
column_name <- "name"
column_altitude <- "Altitude"

column_island <- "island_name"


# ==== INPUTS ====
# Se importan ambos archivos CSV como data frames tabulares
guadalupe_data <- read_csv(input_guadalupe_path, show_col_types = FALSE)
clarion_data <- read_csv(input_clarion_path, show_col_types = FALSE)


# ==== PROCESS / ANALYSIS ====
# Se seleccionan únicamente las columnas relevantes y se agrega
# una columna que identifica la isla de origen del registro
guadalupe_selected <- guadalupe_data |>
  select(
    all_of(column_date),
    all_of(column_time),
    all_of(column_longitude),
    all_of(column_latitude),
    all_of(column_name),
    all_of(column_altitude)
  ) |>
  mutate(
    island_name = "Guadalupe"
  )

# Se aplica el mismo proceso al archivo de Clarión para mantener
# consistencia estructural antes de combinar los datasets
clarion_selected <- clarion_data |>
  select(
    all_of(column_date),
    all_of(column_time),
    all_of(column_longitude),
    all_of(column_latitude),
    all_of(column_name),
    all_of(column_altitude)
  ) |>
  mutate(
    island_name = "Clarion"
  )

# Se concatenan ambas tablas utilizando bind_rows()
# ya que ambas comparten la misma estructura de columnas
albatross_combined <- bind_rows(
  guadalupe_selected,
  clarion_selected
)


# ==== OUTPUT ====
# Se exporta el dataset combinado como archivo CSV
write_csv(
  albatross_combined,
  output_csv_path
)
