# ==========================================
# Título: Filtra las trayectorias VMS por tipo de arte de pesca
#
# Contexto (Por qué):
# El pipeline produce un archivo de trayectorias VMS con todas las
# embarcaciones dentro de la ZEE mexicana y sus artes de pesca.
# Para el análisis de riesgo de captura incidental de albatros es
# necesario aislar las trayectorias de un tipo específico de arte.
#
# Descripción (Qué / Cómo):
# Recibe el nombre del arte de pesca como argumento (longline,
# trawler, purse_seine, other). Lee el CSV de trayectorias VMS con
# información de arte de pesca ya unida y filtrada a la ZEE del
# Pacífico mexicano (vessel_trajectories.csv). Filtra las filas
# para conservar únicamente aquellas con el arte de pesca
# especificado. Escribe el resultado como CSV.
#
# Entradas:
# data/processed/vessel_trajectories.csv
#
# Salida:
# data/processed/vessel_trajectories_{gear}.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - El filtro espacial por ZEE y la unión con información de arte de pesca
#   se realizan en src/create_vessel_joined.R
# - El nombre del arte de pesca se pasa como primer argumento al script
# - Los valores válidos son: longline, trawler, purse_seine, other
# ==========================================


# ==== CONFIGURACIÓN ====

library(tidyverse)
# Proporciona read_csv para importar datos tabulares, filter para conservar
# únicamente las filas que cumplen una condición, y write_csv para exportar

# Lee el nombre del arte de pesca desde el primer argumento de la línea
# de comandos (por ejemplo, "trawler", "purse_seine", "other") para
# construir el nombre de la columna y la ruta de salida correspondientes
gear <- commandArgs(trailingOnly = TRUE)[1]

# Construye el nombre de la columna booleana que identifica el arte de
# pesca en el CSV de trayectorias VMS (ej. gear_trawler, gear_purse_seine)
gear_column <- paste0("gear_", gear)

# Ruta del CSV con las trayectorias VMS de todas las embarcaciones dentro de
# la ZEE del Pacífico mexicano, ya unidas con la información de arte de pesca
# (producido por src/create_vessel_joined.R)
input_trajectories_path <- "data/processed/vessel_trajectories.csv"

# Ruta del CSV que almacenará las trayectorias VMS de embarcaciones que
# usan el arte de pesca especificado como primer argumento
output_trajectories_path <- paste0(
  "data/processed/vessel_trajectories_", gear, ".csv"
)


# ==== ENTRADAS ====

# Importa las trayectorias VMS con información de arte de pesca, ya filtradas
# a la ZEE del Pacífico mexicano por src/create_vessel_joined.R, que contiene
# un registro por cada intervalo de reporte con las columnas de posición
# geográfica, identificador de embarcación y tipo de arte de pesca
vessel_trajectories_tbl <- read_csv(
  input_trajectories_path,
  show_col_types = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra las trayectorias VMS para conservar únicamente los puntos de
# embarcaciones que usan el arte de pesca especificado (gear_{gear} == 1),
# aprovechando que la columna de arte de pesca ya está presente en la tabla
# de entrada gracias a la unión realizada en src/create_vessel_joined.R
vessel_trajectories_filtered_tbl <- vessel_trajectories_tbl |>
  filter(.data[[gear_column]] == 1)


# ==== SALIDA ====

# Escribe las trayectorias VMS filtradas por arte de pesca como CSV, para
# que los scripts de conteo por celda y análisis de hot spots de cada arte
# puedan consumirlas sin repetir el filtrado por tipo de pesca
write_csv(vessel_trajectories_filtered_tbl, output_trajectories_path)
