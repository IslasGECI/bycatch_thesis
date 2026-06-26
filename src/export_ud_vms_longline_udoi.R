# ==========================================
# Título: Calcula el producto normalizado de solapamiento de albatros con presencia de palangre
#
# Contexto (Por qué):
# Necesitamos una superficie conjunta que combine la concentración de
# albatros (N_IND) con la intensidad de pesca de palangre (n_points)
# para identificar celdas donde ambas variables coinciden. El producto
# de las distribuciones normalizadas produce un índice conjunto.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de solapamiento de albatros con la columna N_IND.
# Lee el GeoPackage de hot spot de palangre con la columna de conteo
# de puntos. Lee la máscara binaria de ZEE del Pacífico mexicano.
# Verifica que las tres cuadrículas tengan el mismo número de filas
# y el mismo CRS. Aplica la máscara a ambas columnas de valor para
# excluir celdas fuera de ZEE. Divide cada columna por su suma total
# para normalizar ambas distribuciones a una función de masa de
# probabilidad. Calcula el producto celda por celda de las dos
# distribuciones normalizadas. Escribe el resultado como GeoPackage
# con una sola columna.
#
# Entradas:
# data/processed/ud_in_grid.gpkg
# data/processed/vms_longline_hotspot.gpkg
# data/processed/eez_mask_in_grid.gpkg
#
# Salida:
# data/processed/ud_vms_longline_udoi.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - Las tres cuadrículas deben tener el mismo CRS, el mismo número de
#   celdas y las mismas geometrías en el mismo orden de filas
# - La máscara se aplica multiplicando cada columna por
#   in_eez_outside_gulf antes de normalizar
# - La normalización divide cada valor entre la suma total de su
#   columna para que ambas distribuciones sumen 1
# - El producto udoi_value representa la intersección ponderada de
#   ambas distribuciones dentro de la ZEE; valores altos indican
#   coincidencia de ambas variables en la misma celda
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

# Ruta del GeoPackage con los puntos de palangre (n_points) por
# celda de la rejilla KDE como medida de intensidad de pesca
input_vms_longline_path <- "data/processed/vms_longline_hotspot.gpkg"

# Ruta del GeoPackage con la máscara binaria de ZEE del Pacífico
# mexicano (in_eez_outside_gulf) para filtrar celdas fuera de la
# zona de estudio antes de normalizar
input_eez_mask_path <- "data/processed/eez_mask_in_grid.gpkg"

# Ruta del archivo GeoPackage de salida con el producto normalizado
# de ambas distribuciones como índice conjunto de albatros y pesca
output_gpkg_path <- "data/processed/ud_vms_longline_udoi.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla de solapamiento de albatros con la columna N_IND
# que cuenta cuántos individuos tienen su área núcleo en cada celda;
# la geometría define la partición espacial de la rejilla del KDE
ud_grid_sf <- st_read(input_ud_path, quiet = TRUE)

# Importa la rejilla de hot spot de palangre con la columna
# n_points_vms_longline que cuenta los puntos de pesca en cada celda
vms_longline_grid_sf <- st_read(input_vms_longline_path, quiet = TRUE)

# Importa la máscara binaria de ZEE con la columna
# in_eez_outside_gulf que indica si cada celda está dentro de la
# ZEE del Pacífico mexicano y fuera del Golfo de California
eez_mask_sf <- st_read(input_eez_mask_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Extrae el vector de conteo de individuos desde la rejilla de
# solapamiento de albatros para normalizarlo como distribución
# de probabilidad de presencia de albatros en el espacio
n_ind_per_cell <- ud_grid_sf$N_IND

# Extrae el vector de conteo de puntos de palangre desde la
# rejilla de hot spot para normalizarlo como distribución de
# probabilidad de intensidad de pesca en el espacio
n_points_vms_longline_per_cell <- vms_longline_grid_sf$n_points_vms_longline

# Extrae el vector binario de la máscara de ZEE que vale 1 para
# celdas dentro de la ZEE del Pacífico y fuera del Golfo, y 0
# para celdas fuera de la zona de estudio
is_in_eez_outside_gulf <- eez_mask_sf$in_eez_outside_gulf

# Verifica que las tres cuadrículas tengan el mismo número de
# filas para garantizar que los vectores estén alineados y
# evitar errores silenciosos por desalineación de la rejilla
stopifnot(nrow(ud_grid_sf) == nrow(vms_longline_grid_sf))
stopifnot(nrow(ud_grid_sf) == nrow(eez_mask_sf))

# Verifica que las tres cuadrículas compartan el mismo CRS para
# garantizar que la alineación espacial sea correcta y evitar
# errores silenciosos por proyecciones diferentes
stopifnot(st_crs(ud_grid_sf) == st_crs(vms_longline_grid_sf))
stopifnot(st_crs(ud_grid_sf) == st_crs(eez_mask_sf))

# Aplica la máscara de ZEE al conteo de individuos multiplicando
# cada valor por el indicador binario, lo que pone a cero las
# celdas fuera de la ZEE del Pacífico mexicano
n_ind_masked <- n_ind_per_cell * is_in_eez_outside_gulf

# Aplica la máscara de ZEE al conteo de puntos de palangre
# multiplicando cada valor por el indicador binario, lo que pone
# a cero las celdas fuera de la ZEE del Pacífico mexicano
n_points_masked <- n_points_vms_longline_per_cell * is_in_eez_outside_gulf

# Calcula la suma total de individuos en las celdas dentro de la
# ZEE para usar como denominador de la normalización y transformar
# el conteo absoluto en una proporción dentro de la zona de estudio
n_total_individuals <- sum(n_ind_masked)

# Calcula la suma total de puntos de palangre en las celdas dentro
# de la ZEE para usar como denominador de la normalización y
# transformar el conteo absoluto en una proporción dentro de la
# zona de estudio
n_total_longline_points <- sum(n_points_masked)

# Normaliza la distribución de individuos dentro de la ZEE
# dividiendo cada celda enmascarada entre la suma total dentro de
# la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_individuals <- n_ind_masked / n_total_individuals

# Normaliza la distribución de puntos de palangre dentro de la
# ZEE dividiendo cada celda enmascarada entre la suma total dentro
# de la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_longline_points <- n_points_masked / n_total_longline_points

# Calcula el producto celda por celda de las dos distribuciones
# normalizadas para obtener un índice conjunto que es alto solo
# donde ambas variables tienen valores altos simultáneamente
udoi_values <- normalized_individuals * normalized_longline_points

# Construye la rejilla de salida con la geometría original de la
# rejilla del KDE y la nueva columna del producto normalizado;
# la geometría se hereda de ud_grid_sf que comparte el mismo CRS
# y orden de filas que vms_longline_grid_sf
udoi_grid_sf <- ud_grid_sf |>
  mutate(udoi_value = udoi_values) |>
  select(udoi_value)


# ==== SALIDA ====

# Escribe el GeoPackage con el producto normalizado de ambas
# distribuciones como índice conjunto de albatros y pesca para
# su uso en análisis de riesgo de captura incidental
st_write(udoi_grid_sf, output_gpkg_path, delete_dsn = TRUE)
