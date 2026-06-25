# ==========================================
# Título: Une los datos de trayectorias VMS con la información de arte de pesca de todas las embarcaciones
#
# Contexto (Por qué):
# Los datos de trayectorias VMS contienen la posición de las embarcaciones
# pero no indican el tipo de arte de pesca. La tabla de información de
# embarcaciones indica el arte de cada embarcación. Filtrar por la ZEE
# del Pacífico mexicano descarta los puntos en alta mar o en aguas de
# otros países, y unir con la información de arte permite clasificar
# cada trayectoria por tipo de pesca.
#
# Descripción (Qué / Cómo):
# Lee el CSV de trayectorias VMS del Pacífico y el CSV de información de
# embarcaciones. Filtra las trayectorias VMS para conservar únicamente los
# puntos dentro de la ZEE del Pacífico mexicano (código eez == 8429).
# Selecciona la columna clave y todas las columnas de tipo de arte de la
# tabla de embarcaciones. Aplica una unión interna por el identificador
# vessel_rnpa para etiquetar cada trayectoria VMS con el arte de pesca
# de la embarcación. Escribe el resultado como CSV.
#
# Entradas:
# data/external/vessel_data_pacific.csv
# data/external/vessel_info.csv
#
# Salida:
# data/processed/vessel_trajectories.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - El filtro espacial por eez == 8429 conserva solo la ZEE del Pacífico mexicano
# - No se filtra por arte de pesca: se conservan todas las embarcaciones
# - La unión interna descarta embarcaciones sin registro en vessel_info
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

# Ruta del CSV que almacenará las trayectorias VMS con información de arte
# de pesca para todas las embarcaciones dentro de la ZEE mexicana
output_trajectories_path <- "data/processed/vessel_trajectories.csv"

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

# Filtra las trayectorias VMS para conservar únicamente los puntos que
# caen dentro de la ZEE del Pacífico mexicano (código 8429), descartando
# los puntos en alta mar (eez == 0) o dentro de ZEE de otros países
vessel_data_pacific_filtered_tbl <- vessel_data_pacific_tbl |>
  filter(eez == 8429)

# Selecciona únicamente la columna clave y las columnas de tipo de arte de
# la tabla de embarcaciones para evitar incorporar columnas innecesarias al
# unir con las trayectorias VMS. No se filtra por arte de pesca: se
# conservan todas las embarcaciones con independencia de su arte
vessel_info_selected_tbl <- vessel_info_tbl |>
  select(all_of(key_column_name), all_of(gear_column_names))

# Aplica una unión interna entre las trayectorias VMS filtradas por ZEE
# mexicana y la información seleccionada de todas las embarcaciones usando
# el identificador vessel_rnpa como clave, lo que etiqueta cada trayectoria
# con el arte de pesca de la embarcación correspondiente
vessel_trajectories_tbl <- vessel_data_pacific_filtered_tbl |>
  inner_join(vessel_info_selected_tbl, by = key_column_name)


# ==== SALIDA ====

# Escribe las trayectorias VMS con información de arte de pesca como CSV,
# para que los scripts de conteo por celda y de análisis de hot spots
# puedan consumirlas clasificadas por tipo de pesca
write_csv(vessel_trajectories_tbl, output_trajectories_path)
