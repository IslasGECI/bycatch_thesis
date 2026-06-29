# ==========================================
# Título: Calcula el producto UDOI de albatros con la distribución combinada de pesca
#
# Contexto (Por qué):
# La distribución combinada de pesca ya integra las intensidades de
# palangre y arrastre ponderadas por su UDOI individual. Falta
# multiplicarla por la distribución de albatros para obtener el
# índice conjunto de solapamiento albatros-pesca combinada dentro
# de la ZEE del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de solapamiento de albatros con la columna N_IND.
# Lee el GeoPackage de distribución combinada de pesca con la columna
# normalized_combined_fishing. Lee la máscara binaria de ZEE.
# Verifica que las tres cuadrículas estén alineadas en filas y CRS.
# Aplica la máscara a la distribución de albatros para excluir celdas
# fuera de la ZEE. Normaliza la distribución de albatros dividiendo
# entre su suma total dentro de la ZEE. Multiplica celda por celda
# el albatros normalizado por la distribución combinada de pesca.
# Escribe el producto como GeoPackage con la columna udoi_value.
#
# Entradas:
# data/processed/ud_in_grid.gpkg
# data/processed/combined_fishing_distribution.gpkg
# data/processed/eez_mask_in_grid.gpkg
#
# Salida:
# data/processed/ud_vms_all_gear_udoi.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - La distribución combinada de pesca ya está enmascarada y normalizada
# - El albatros se enmascara y normaliza dentro de la ZEE de forma
#   independiente para que ambas distribuciones tengan masa unitaria
# - El producto resultante es alto solo donde albatros y pesca
#   combinada coinciden en la misma celda dentro de la ZEE
# - Este script no necesita jsonlite porque los UDOI individuales ya
#   fueron aplicados en export_combined_fishing_distribution.R
# ==========================================


# ==== CONFIGURACIÓN ====

library(sf)
# Proporciona st_read para importar geometrías desde GeoPackage y
# st_drop_geometry para descartar la geometría al combinar datos

library(tidyverse)
# Proporciona mutate para crear nuevas columnas dentro del flujo
# de transformación de datos del ecosistema tidyverse

# Ruta del GeoPackage con el conteo de individuos (N_IND) por celda
# de la rejilla KDE generado por export_ud_in_grid.R como medida de
# concentración de albatros de Laysan
input_ud_path <- "data/processed/ud_in_grid.gpkg"

# Ruta del GeoPackage con la distribución combinada de palangre y
# arrastre ponderada por UDOI generado por
# export_combined_fishing_distribution.R como medida de intensidad
# conjunta de pesca normalizada dentro de la ZEE
input_combined_fishing_path <- "data/processed/combined_fishing_distribution.gpkg"

# Ruta del GeoPackage con la máscara binaria de ZEE del Pacífico
# mexicano (in_eez_outside_gulf) para filtrar celdas fuera de la
# zona de estudio antes de normalizar el albatros
input_eez_mask_path <- "data/processed/eez_mask_in_grid.gpkg"

# Ruta del archivo GeoPackage de salida con el producto normalizado
# de albatros y la distribución combinada de pesca como índice
# conjunto de solapamiento para análisis de riesgo de captura
output_gpkg_path <- "data/processed/ud_vms_all_gear_udoi.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla de solapamiento de albatros con la columna N_IND
# que cuenta cuántos individuos tienen su área núcleo en cada celda;
# la geometría define la partición espacial de la rejilla del KDE
ud_grid_sf <- st_read(input_ud_path, quiet = TRUE)

# Importa la rejilla de distribución combinada de pesca con la
# columna normalized_combined_fishing que contiene la masa de
# probabilidad conjunta de palangre y arrastre ponderada por UDOI
combined_fishing_grid_sf <- st_read(input_combined_fishing_path, quiet = TRUE)

# Importa la máscara binaria de ZEE con la columna
# in_eez_outside_gulf que indica si cada celda está dentro de la
# ZEE del Pacífico mexicano y fuera del Golfo de California
eez_mask_sf <- st_read(input_eez_mask_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Extrae el vector de conteo de individuos desde la rejilla de
# solapamiento de albatros para normalizarlo como distribución
# de probabilidad de presencia de albatros en el espacio
n_ind_per_cell <- ud_grid_sf$N_IND

# Extrae el vector de distribución combinada de pesca normalizada
# desde la rejilla intermedia para multiplicarlo celda por celda
# con la distribución de albatros normalizada
normalized_combined_fishing_from_file <- combined_fishing_grid_sf$normalized_combined_fishing

# Extrae el vector binario de la máscara de ZEE que vale 1 para
# celdas dentro de la ZEE del Pacífico y fuera del Golfo, y 0
# para celdas fuera de la zona de estudio
is_in_eez_outside_gulf <- eez_mask_sf$in_eez_outside_gulf

# Verifica que las tres cuadrículas tengan el mismo número de
# filas para garantizar que los vectores estén alineados y
# evitar errores silenciosos por desalineación de la rejilla
stopifnot(nrow(ud_grid_sf) == nrow(combined_fishing_grid_sf))
stopifnot(nrow(ud_grid_sf) == nrow(eez_mask_sf))

# Verifica que las tres cuadrículas compartan el mismo CRS para
# garantizar que la alineación espacial sea correcta y evitar
# errores silenciosos por proyecciones diferentes
stopifnot(st_crs(ud_grid_sf) == st_crs(combined_fishing_grid_sf))
stopifnot(st_crs(ud_grid_sf) == st_crs(eez_mask_sf))

# Aplica la máscara de ZEE al conteo de individuos multiplicando
# cada valor por el indicador binario, lo que pone a cero las
# celdas fuera de la ZEE del Pacífico mexicano
n_ind_masked <- n_ind_per_cell * is_in_eez_outside_gulf

# Calcula la suma total de individuos en las celdas dentro de la
# ZEE para usar como denominador de la normalización y transformar
# el conteo absoluto en una proporción dentro de la zona de estudio
n_total_individuals <- sum(n_ind_masked)

# Normaliza la distribución de individuos dentro de la ZEE
# dividiendo cada celda enmascarada entre la suma total dentro de
# la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_individuals <- n_ind_masked / n_total_individuals

# Calcula el producto celda por celda de la distribución normalizada
# de albatros con la distribución combinada de pesca para obtener un
# índice conjunto que es alto solo donde los albatros coinciden con
# alta intensidad de palangre, arrastre o ambos simultáneamente
udoi_values <- normalized_individuals * normalized_combined_fishing_from_file

# Construye la rejilla de salida con la geometría original de la
# rejilla del KDE y la nueva columna del producto normalizado;
# la geometría se hereda de ud_grid_sf que comparte el mismo CRS
# y orden de filas que las demás cuadrículas
udoi_grid_sf <- ud_grid_sf |>
  mutate(udoi_value = udoi_values) |>
  select(udoi_value)


# ==== SALIDA ====

# Escribe el GeoPackage con el producto normalizado de albatros y
# la distribución combinada de pesca como índice conjunto para su
# uso en análisis de riesgo de captura incidental
st_write(udoi_grid_sf, output_gpkg_path, delete_dsn = TRUE)
