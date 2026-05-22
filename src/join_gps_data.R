# ==========================================
# Título: Concatena los registros GPS de albatros de Guadalupe y Clarión
#
# Contexto (Por qué):
# Los registros GPS de albatros provienen de dos colonias diferentes:
# Guadalupe y Clarión. Consolidar ambos archivos en un único dataset
# estandarizado facilita los análisis posteriores de movimientos y
# distribución espacial de las aves.
#
# Descripción (Qué / Cómo):
# Carga los dos archivos CSV originales, selecciona únicamente las
# columnas que ambos comparten, agrega una columna que identifica la
# isla de origen de cada registro y concatena ambas tablas. Exporta
# el resultado como un CSV consolidado para el resto del pipeline.
#
# Entradas:
# data/raw/gps-albatros-guadalupe.csv
# data/raw/gps-albatros-clarion.csv
#
# Salida:
# data/processed/gps_albatross_all.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - Solo se conservan las columnas comunes: date, time, longitude, latitude, name y Altitude
# - Se agrega la columna island_name para identificar la isla de origen de cada registro
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse)  # Proporciona readr para importar CSVs y dplyr para seleccionar y combinar tablas

# Rutas de los archivos CSV de entrada con datos GPS de cada colonia
input_guadalupe_path <- "data/raw/gps-albatros-guadalupe.csv"
input_clarion_path <- "data/raw/gps-albatros-clarion.csv"

# Ruta del archivo CSV de salida con los registros consolidados
output_csv_path <- "data/processed/gps_albatross_all.csv"

# Nombres de las columnas que se conservan de ambos archivos originales
column_date <- "date"
column_time <- "time"
column_longitude <- "longitude"
column_latitude <- "latitude"
column_name <- "name"
column_altitude <- "Altitude"

# Nombre de la columna que identifica la isla de origen del registro
column_island <- "island_name"


# ==== ENTRADAS ====
# Importa los registros GPS de la colonia de Guadalupe como tabla
guadalupe_data <- read_csv(input_guadalupe_path, show_col_types = FALSE)
# Importa los registros GPS de la colonia de Clarión como tabla
clarion_data <- read_csv(input_clarion_path, show_col_types = FALSE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Selecciona las columnas relevantes de los datos de Guadalupe y agrega
# la columna que identifica la isla de origen de cada registro
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

# Aplica el mismo proceso a los datos de Clarión para mantener la
# consistencia estructural antes de combinar ambos datasets
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

# Concatena ambas tablas usando bind_rows() ya que ambas comparten la
# misma estructura de columnas después del proceso de selección
albatross_combined <- bind_rows(
  guadalupe_selected,
  clarion_selected
)


# ==== SALIDA ====
# Exporta el dataset combinado como CSV para consumir en los scripts
# de análisis de distribución espacial y modelado de hábitat
write_csv(
  albatross_combined,
  output_csv_path
)
