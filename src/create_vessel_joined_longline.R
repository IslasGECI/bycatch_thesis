# ==========================================
# Título: Une los datos de trayectorias VMS con la información de arte de pesca de las embarcaciones
#
# Contexto (Por qué):
# Los datos de trayectorias VMS contienen la posición de las embarcaciones
# pero no indican el tipo de arte de pesca. La tabla de información de
# embarcaciones indica qué embarcaciones usan palangre. Filtrar solo las
# embarcaciones con palangre aísla las trayectorias relevantes para la
# evaluación de riesgo de captura incidental de albatros.
#
# Descripción (Qué / Cómo):
# Lee el CSV de trayectorias VMS del Pacífico y el CSV de información de
# embarcaciones. Filtra las trayectorias VMS para conservar únicamente los
# puntos dentro de la ZEE del Pacífico mexicano (código eez == 8429).
# Filtra la tabla de embarcaciones para conservar solo aquellas con palangre
# como arte de pesca (gear_longline == 1). Selecciona la columna clave y las
# columnas de tipo de arte. Aplica una unión interna por el identificador
# vessel_rnpa para conservar solo las trayectorias de embarcaciones
# palangreras dentro de la ZEE mexicana. Escribe el resultado como CSV.
#
# Entradas:
# data/external/vessel_data_pacific.csv
# data/external/vessel_info.csv
#
# Salida:
# data/processed/vessel_trajectories_longline.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - El filtro espacial por eez == 8429 conserva solo la ZEE del Pacífico mexicano
# - El filtro previo a la unión reduce el número de filas en el join
# - Solo se incorporan las columnas gear_longline y gear_type
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

# Ruta del CSV que almacenará las trayectorias VMS de embarcaciones que
# usan palangre como arte de pesca
output_trajectories_path <- "data/processed/vessel_trajectories_longline.csv"

# Nombre de la columna clave que identifica unívocamente a cada embarcación
# en ambas tablas y permite la unión entre trayectorias e información
key_column_name <- "vessel_rnpa"

# Nombres de las columnas de arte de pesca que se seleccionarán de la tabla
# de información de embarcaciones para agregar a las trayectorias VMS
gear_column_names <- c(
  "gear_type",
  "gear_longline"
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

# Filtra las trayectorias VMS para conservar únicamente los puntos que
# caen dentro de la ZEE del Pacífico mexicano (código 8429), descartando
# los puntos en alta mar (eez == 0) o dentro de ZEE de otros países
vessel_data_pacific_filtered_tbl <- vessel_data_pacific_tbl |>
  filter(eez == 8429)

# Filtra la tabla de embarcaciones para conservar solo aquellas cuyo arte
# de pesca incluye palangre (gear_longline == 1), reduciendo el número de
# filas que entran en la unión y asegurando que el resultado contenga
# únicamente trayectorias de embarcaciones palangreras
vessel_info_longline_tbl <- vessel_info_tbl |>
  filter(gear_longline == 1)

# Selecciona únicamente la columna clave y las columnas de tipo de arte de
# la tabla de embarcaciones filtrada para evitar incorporar columnas
# innecesarias al unir con las trayectorias VMS
vessel_info_selected_tbl <- vessel_info_longline_tbl |>
  select(all_of(key_column_name), all_of(gear_column_names))

# Aplica una unión interna entre las trayectorias VMS filtradas por ZEE
# mexicana y la información seleccionada de embarcaciones palangreras
# usando el identificador vessel_rnpa como clave, lo que conserva solo
# los puntos de embarcaciones que usan palangre dentro de la ZEE mexicana
vessel_trajectories_longline_tbl <- vessel_data_pacific_filtered_tbl |>
  inner_join(vessel_info_selected_tbl, by = key_column_name)


# ==== SALIDA ====

# Escribe las trayectorias VMS de embarcaciones palangreras como CSV, para
# que otros scripts del pipeline puedan consumirlas sin repetir la
# operación de filtrado y unión
write_csv(vessel_trajectories_longline_tbl, output_trajectories_path)
