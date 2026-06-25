# ==========================================
# Título: Filtra las trayectorias VMS para conservar solo embarcaciones palangreras
#
# Contexto (Por qué):
# El pipeline produce un archivo de trayectorias VMS con todas las
# embarcaciones dentro de la ZEE mexicana y sus artes de pesca.
# Para el análisis de riesgo de captura incidental de albatros es
# necesario aislar exclusivamente las trayectorias de palangreros.
#
# Descripción (Qué / Cómo):
# Lee el CSV de trayectorias VMS con información de arte de pesca ya unida
# y filtrada a la ZEE del Pacífico mexicano (vessel_trajectories.csv).
# Filtra las filas para conservar únicamente aquellas con palangre como
# arte de pesca (gear_longline == 1). Escribe el resultado como CSV.
#
# Entradas:
# data/processed/vessel_trajectories.csv
#
# Salida:
# data/processed/vessel_trajectories_longline.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - El filtro espacial por ZEE y la unión con información de arte de pesca
#   se realizan en src/create_vessel_joined.R
# - Este script solo aplica el filtro por arte de pesca (gear_longline == 1)
# ==========================================


# ==== CONFIGURACIÓN ====

library(tidyverse)
# Proporciona read_csv para importar datos tabulares, filter para conservar
# únicamente las filas que cumplen una condición, y write_csv para exportar

# Ruta del CSV con las trayectorias VMS de todas las embarcaciones dentro de
# la ZEE del Pacífico mexicano, ya unidas con la información de arte de pesca
# (producido por src/create_vessel_joined.R)
input_trajectories_path <- "data/processed/vessel_trajectories.csv"

# Ruta del CSV que almacenará las trayectorias VMS de embarcaciones que
# usan palangre como arte de pesca
output_trajectories_path <- "data/processed/vessel_trajectories_longline.csv"


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
# embarcaciones que usan palangre (gear_longline == 1), aprovechando que
# la columna de arte de pesca ya está presente en la tabla de entrada
# gracias a la unión realizada en src/create_vessel_joined.R
vessel_trajectories_longline_tbl <- vessel_trajectories_tbl |>
  filter(gear_longline == 1)


# ==== SALIDA ====

# Escribe las trayectorias VMS de embarcaciones palangreras como CSV, para
# que los scripts de conteo por celda y análisis de hot spots de palangre
# puedan consumirlas sin repetir el filtrado por arte de pesca
write_csv(vessel_trajectories_longline_tbl, output_trajectories_path)
