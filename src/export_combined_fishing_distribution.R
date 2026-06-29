# ==========================================
# Título: Exporta la distribución combinada de pesca con ponderación UDOI
#
# Contexto (Por qué):
# Cada arte de pesca tiene un índice UDOI individual que mide su
# solapamiento con la distribución de albatros. Al construir la
# distribución combinada de pesca, ponderar cada arte por su UDOI
# individual da más peso al arte que más coincide espacialmente con
# los albatros, mejorando la relevancia ecológica del índice conjunto.
#
# Descripción (Qué / Cómo):
# Lee los GeoPackages de hot spot de palangre y arrastre con el
# conteo de puntos por celda. Lee la máscara binaria de ZEE del
# Pacífico mexicano. Lee los archivos JSON con los UDOI individuales
# de palangre y arrastre. Verifica que las cuatro cuadrículas estén
# alineadas en filas y CRS. Enmascara las celdas fuera de la ZEE.
# Normaliza cada distribución a una función de masa de probabilidad
# que suma 1. Pondera cada distribución por su UDOI y las combina
# con una media ponderada. Re-normaliza la distribución combinada.
# Escribe la distribución combinada como GeoPackage sin columna de
# albatros para mantener una separación limpia de responsabilidades.
#
# Entradas:
# data/processed/vms_longline_hotspot.gpkg
# data/processed/vms_trawler_hotspot.gpkg
# data/processed/eez_mask_in_grid.gpkg
# data/processed/longline_udoi.json
# data/processed/trawler_udoi.json
#
# Salida:
# data/processed/combined_fishing_distribution.gpkg
#
# Dependencias:
# sf
# tidyverse
# jsonlite
#
# Notas:
# - La ponderación por UDOI da más peso al arte con mayor solapamiento
#   con albatros al construir la distribución combinada de pesca
# - La máscara se aplica antes de normalizar para que las
#   distribuciones reflejen solo las celdas dentro de la ZEE
# - Cada distribución de arte se normaliza por su suma total dentro
#   de la ZEE para que ambas tengan masa de probabilidad unitaria
# - La re-normalización final garantiza que la distribución combinada
#   sume exactamente 1 dentro de la ZEE del Pacífico mexicano
# ==========================================


# ==== CONFIGURACIÓN ====

library(sf)
# Proporciona st_read para importar geometrías desde GeoPackage y
# st_drop_geometry para descartar la geometría al combinar datos

library(tidyverse)
# Proporciona mutate para crear nuevas columnas dentro del flujo
# de transformación de datos del ecosistema tidyverse

library(jsonlite)
# Proporciona fromJSON para leer los valores de UDOI individuales
# de palangre y arrastre desde archivos JSON como pesos escalares

# Ruta del GeoPackage con los puntos de palangre (n_points) por
# celda de la rejilla KDE como medida de intensidad de pesca
input_vms_longline_path <- "data/processed/vms_longline_hotspot.gpkg"

# Ruta del GeoPackage con los puntos de arrastre (n_points) por
# celda de la rejilla KDE como medida de intensidad de pesca
input_vms_trawler_path <- "data/processed/vms_trawler_hotspot.gpkg"

# Ruta del GeoPackage con la máscara binaria de ZEE del Pacífico
# mexicano (in_eez_outside_gulf) para filtrar celdas fuera de la
# zona de estudio antes de normalizar
input_eez_mask_path <- "data/processed/eez_mask_in_grid.gpkg"

# Ruta del archivo JSON con el índice UDOI de solapamiento
# albatros-palangre generado por src/compute_udoi.R como peso
# para ponderar la distribución de palangre en la combinación
input_udoi_longline_path <- "data/processed/longline_udoi.json"

# Ruta del archivo JSON con el índice UDOI de solapamiento
# albatros-arrastre generado por src/compute_trawler_udoi.R como
# peso para ponderar la distribución de arrastre en la combinación
input_udoi_trawler_path <- "data/processed/trawler_udoi.json"

# Ruta del archivo GeoPackage de salida con la distribución
# combinada de palangre y arrastre ponderada por UDOI para que
# el script de albatros la consuma como entrada intermedia
output_gpkg_path <- "data/processed/combined_fishing_distribution.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla de hot spot de palangre con la columna
# n_points_vms_longline que cuenta los puntos de pesca en cada celda;
# la geometría define la partición espacial de la rejilla del KDE
vms_longline_grid_sf <- st_read(input_vms_longline_path, quiet = TRUE)

# Importa la rejilla de hot spot de arrastre con la columna
# n_points_vms_trawler que cuenta los puntos de pesca en cada celda
vms_trawler_grid_sf <- st_read(input_vms_trawler_path, quiet = TRUE)

# Importa la máscara binaria de ZEE con la columna
# in_eez_outside_gulf que indica si cada celda está dentro de la
# ZEE del Pacífico mexicano y fuera del Golfo de California
eez_mask_sf <- st_read(input_eez_mask_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Extrae el vector de conteo de puntos de palangre desde la
# rejilla de hot spot para normalizarlo como distribución de
# probabilidad de intensidad de pesca en el espacio
n_points_vms_longline_per_cell <- vms_longline_grid_sf$n_points_vms_longline

# Extrae el vector de conteo de puntos de arrastre desde la
# rejilla de hot spot para normalizarlo como distribución de
# probabilidad de intensidad de pesca en el espacio
n_points_vms_trawler_per_cell <- vms_trawler_grid_sf$n_points_vms_trawler

# Extrae el vector binario de la máscara de ZEE que vale 1 para
# celdas dentro de la ZEE del Pacífico y fuera del Golfo, y 0
# para celdas fuera de la zona de estudio
is_in_eez_outside_gulf <- eez_mask_sf$in_eez_outside_gulf

# Verifica que las tres cuadrículas tengan el mismo número de
# filas para garantizar que los vectores estén alineados y
# evitar errores silenciosos por desalineación de la rejilla
stopifnot(nrow(vms_longline_grid_sf) == nrow(vms_trawler_grid_sf))
stopifnot(nrow(vms_longline_grid_sf) == nrow(eez_mask_sf))

# Verifica que las tres cuadrículas compartan el mismo CRS para
# garantizar que la alineación espacial sea correcta y evitar
# errores silenciosos por proyecciones diferentes
stopifnot(st_crs(vms_longline_grid_sf) == st_crs(vms_trawler_grid_sf))
stopifnot(st_crs(vms_longline_grid_sf) == st_crs(eez_mask_sf))

# Aplica la máscara de ZEE al conteo de puntos de palangre
# multiplicando cada valor por el indicador binario, lo que pone
# a cero las celdas fuera de la ZEE del Pacífico mexicano
n_longline_masked <- n_points_vms_longline_per_cell * is_in_eez_outside_gulf

# Aplica la máscara de ZEE al conteo de puntos de arrastre
# multiplicando cada valor por el indicador binario, lo que pone
# a cero las celdas fuera de la ZEE del Pacífico mexicano
n_trawler_masked <- n_points_vms_trawler_per_cell * is_in_eez_outside_gulf

# Calcula la suma total de puntos de palangre en las celdas dentro
# de la ZEE para usar como denominador de la normalización y
# transformar el conteo absoluto en una proporción dentro de la
# zona de estudio
n_total_longline_points <- sum(n_longline_masked)

# Calcula la suma total de puntos de arrastre en las celdas dentro
# de la ZEE para usar como denominador de la normalización y
# transformar el conteo absoluto en una proporción dentro de la
# zona de estudio
n_total_trawler_points <- sum(n_trawler_masked)

# Normaliza la distribución de puntos de palangre dentro de la
# ZEE dividiendo cada celda enmascarada entre la suma total dentro
# de la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_longline_points <- n_longline_masked / n_total_longline_points

# Normaliza la distribución de puntos de arrastre dentro de la
# ZEE dividiendo cada celda enmascarada entre la suma total dentro
# de la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_trawler_points <- n_trawler_masked / n_total_trawler_points

# Lee el valor escalar del índice UDOI de solapamiento albatros-
# palangre desde el JSON generado por src/compute_udoi.R para
# usarlo como peso de la distribución de palangre en la combinación
longline_udoi <- fromJSON(input_udoi_longline_path)$udoi

# Lee el valor escalar del índice UDOI de solapamiento albatros-
# arrastre desde el JSON generado por src/compute_trawler_udoi.R
# para usarlo como peso de la distribución de arrastre
trawler_udoi <- fromJSON(input_udoi_trawler_path)$udoi

# Calcula la suma de ambos pesos UDOI como denominador de la media
# ponderada para que la distribución combinada resultante sume 1
sum_udoi_weights <- longline_udoi + trawler_udoi

# Combina las distribuciones normalizadas de palangre y arrastre
# ponderando cada arte por su índice UDOI individual para que el
# arte con mayor solapamiento con albatros contribuya más en la
# distribución combinada de pesca dentro de la ZEE
combined_fishing_distribution <- (longline_udoi * normalized_longline_points + trawler_udoi * normalized_trawler_points) / sum_udoi_weights

# Calcula la suma de la distribución combinada ponderada para
# verificar que sume 1 (la media ponderada con pesos normalizados
# garantiza masa de probabilidad unitaria)
combined_fishing_integral <- sum(combined_fishing_distribution)

# Re-normaliza la distribución combinada dividiendo entre su suma
# para garantizar que la masa de probabilidad sea exactamente 1
# antes de multiplicarla por la distribución de albatros
normalized_combined_fishing_distribution <- combined_fishing_distribution / combined_fishing_integral

# Construye la rejilla de salida con la geometría original de la
# rejilla del KDE heredada de vms_longline_grid_sf y la nueva
# columna de la distribución combinada normalizada; se descartan
# las columnas de conteo originales porque este archivo intermedio
# solo debe exponer la distribución combinada para el siguiente paso
combined_fishing_sf <- vms_longline_grid_sf |>
  mutate(normalized_combined_fishing = normalized_combined_fishing_distribution) |>
  select(normalized_combined_fishing)


# ==== SALIDA ====

# Escribe el GeoPackage con la distribución combinada de pesca
# normalizada y ponderada por UDOI para que el script de albatros
# la consuma como entrada y calcule el producto final del índice
# conjunto de solapamiento albatros-pesca combinada
st_write(combined_fishing_sf, output_gpkg_path, delete_dsn = TRUE)
