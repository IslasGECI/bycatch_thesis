# ==========================================
# Título: Une los datos de trayectorias VMS con la información de arte de pesca de las embarcaciones
#
# Contexto (Por qué):
# Los datos de trayectorias VMS contienen la posición de las embarcaciones
# pero no indican el tipo de arte de pesca. La tabla de información de
# embarcaciones contiene el arte de pesca que cada embarcación utiliza.
# Unir ambas tablas permite clasificar cada punto VMS por tipo de arte.
#
# Descripción (Qué / Cómo):
# Lee el CSV de trayectorias VMS del Pacífico y el CSV de información de
# embarcaciones. Selecciona las columnas de arte de pesca de la tabla de
# embarcaciones. Aplica una unión interna por el identificador único de
# embarcación vessel_rnpa para conservar solo las trayectorias con
# información de arte disponible. Escribe el resultado como CSV.
#
# Entradas:
# data/external/vessel_data_pacific.csv
# data/external/vessel_info.csv
#
# Salida:
# data/processed/vessel_trajectories_with_gear.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - La unión interna descarta puntos VMS sin información de embarcación
# - Solo se incorporan las columnas de arte de pesca: gear_type, gear_trawler, gear_purse_seine, gear_longline, gear_other
# ==========================================


# ==== CONFIGURACIÓN ====

library(tidyverse)
# Proporciona read_csv para importar datos tabulares, inner_join para
# combinar tablas por una clave común, y write_csv para exportar el resultado

# Ruta del CSV con las trayectorias VMS de embarcaciones en el Pacífico
# mexicano, que contiene la posición geográfica y el identificador de cada
# embarcación en cada intervalo de reporte
input_vessel_data_path <- "data/external/vessel_data_pacific.csv"

# Ruta del CSV con la información descriptiva de cada embarcación, incluyendo
# el tipo de arte de pesca y las características de la embarcación
input_vessel_info_path <- "data/external/vessel_info.csv"

# Ruta del CSV que almacenará las trayectorias VMS enriquecidas con las
# columnas de arte de pesca de cada embarcación
output_trajectories_path <- "data/processed/vessel_trajectories_with_gear.csv"

# Nombre de la columna clave que identifica unívocamente a cada embarcación
# en ambas tablas y permite la unión entre trayectorias e información
key_column_name <- "vessel_rnpa"

# Nombres de las columnas de arte de pesca que se seleccionarán de la tabla
# de información de embarcaciones para agregar a las trayectorias VMS
gear_column_names <- c(
  "gear_type",
  "gear_trawler",
  "gear_purse_seine",
  "gear_longline",
  "gear_other"
)


# ==== ENTRADAS ====

# Importa las trayectorias VMS del Pacífico desde el CSV descargado por el
# pipeline de datos externos, que contiene un registro por cada intervalo de
# reporte del sistema de monitoreo de embarcaciones
vessel_data_pacific_tbl <- read_csv(
  input_vessel_data_path,
  show_col_types = FALSE
)

# Importa la información descriptiva de las embarcaciones desde el CSV
# descargado por el pipeline de datos externos, que contiene el registro
# de cada embarcación con sus características y arte de pesca
vessel_info_tbl <- read_csv(
  input_vessel_info_path,
  show_col_types = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Selecciona únicamente la columna clave y las columnas de arte de pesca de
# la tabla de información de embarcaciones para evitar incorporar columnas
# innecesarias al unir las tablas
vessel_info_selected_tbl <- vessel_info_tbl |>
  select(all_of(key_column_name), all_of(gear_column_names))

# Aplica una unión interna entre las trayectorias VMS y la información
# seleccionada de embarcaciones usando el identificador vessel_rnpa como
# clave, lo que conserva solo los puntos con información de arte disponible
vessel_trajectories_with_gear_tbl <- vessel_data_pacific_tbl |>
  inner_join(vessel_info_selected_tbl, by = key_column_name)


# ==== SALIDA ====

# Escribe las trayectorias VMS enriquecidas con las columnas de arte de
# pesca como CSV, para que otros scripts del pipeline puedan consumirlas
# sin repetir la operación de unión
write_csv(vessel_trajectories_with_gear_tbl, output_trajectories_path)
