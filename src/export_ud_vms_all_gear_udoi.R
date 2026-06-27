# ==========================================
# Título: Calcula el producto UDOI-ponderado de albatros con pesca combinada
#
# Contexto (Por qué):
# Cada arte de pesca tiene un índice UDOI individual que mide su
# solapamiento con la distribución de albatros. Al construir la
# distribución combinada de pesca, ponderar cada arte por su UDOI
# individual da más peso al arte que más coincide espacialmente con
# los albatros, mejorando la relevancia ecológica del índice conjunto.
#
# Descripción (Qué / Cómo):
# Lee los GeoPackages de albatros, palangre, arrastre y la máscara
# de ZEE. Lee los archivos JSON con los UDOI individuales de palangre
# y arrastre. Verifica que todas las cuadrículas estén alineadas en
# filas y CRS. Enmascara las celdas fuera de la ZEE del Pacífico.
# Normaliza cada distribución a una función de masa de probabilidad
# que suma 1. Ponderá la distribución de cada arte por su UDOI y las
# combina con una media ponderada. Multiplica celda por celda la
# distribución de albatros por la distribución combinada de pesca.
# Escribe el producto como GeoPackage.
#
# Entradas:
# data/processed/ud_in_grid.gpkg
# data/processed/vms_longline_hotspot.gpkg
# data/processed/vms_trawler_hotspot.gpkg
# data/processed/eez_mask_in_grid.gpkg
# data/processed/longline_udoi.json
# data/processed/trawler_udoi.json
#
# Salida:
# data/processed/ud_vms_all_gear_udoi.gpkg
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
# - La re-normalización final de la distribución combinada garantiza
#   que el producto con albatros sea una masa de probabilidad conjunta
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

# Ruta del GeoPackage con el conteo de individuos (N_IND) por celda
# de la rejilla KDE generado por export_ud_in_grid.R como medida de
# concentración de albatros de Laysan
input_ud_path <- "data/processed/ud_in_grid.gpkg"

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

# Ruta del archivo GeoPackage de salida con el producto normalizado
# de albatros y la suma de pesca combinada como índice conjunto
output_gpkg_path <- "data/processed/ud_vms_all_gear_udoi.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla de solapamiento de albatros con la columna N_IND
# que cuenta cuántos individuos tienen su área núcleo en cada celda;
# la geometría define la partición espacial de la rejilla del KDE
ud_grid_sf <- st_read(input_ud_path, quiet = TRUE)

# Importa la rejilla de hot spot de palangre con la columna
# n_points_vms_longline que cuenta los puntos de pesca en cada celda
vms_longline_grid_sf <- st_read(input_vms_longline_path, quiet = TRUE)

# Importa la rejilla de hot spot de arrastre con la columna
# n_points_vms_trawler que cuenta los puntos de pesca en cada celda
vms_trawler_grid_sf <- st_read(input_vms_trawler_path, quiet = TRUE)

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

# Extrae el vector de conteo de puntos de arrastre desde la
# rejilla de hot spot para normalizarlo como distribución de
# probabilidad de intensidad de pesca en el espacio
n_points_vms_trawler_per_cell <- vms_trawler_grid_sf$n_points_vms_trawler

# Extrae el vector binario de la máscara de ZEE que vale 1 para
# celdas dentro de la ZEE del Pacífico y fuera del Golfo, y 0
# para celdas fuera de la zona de estudio
is_in_eez_outside_gulf <- eez_mask_sf$in_eez_outside_gulf

# Verifica que las cuatro cuadrículas tengan el mismo número de
# filas para garantizar que los vectores estén alineados y
# evitar errores silenciosos por desalineación de la rejilla
stopifnot(nrow(ud_grid_sf) == nrow(vms_longline_grid_sf))
stopifnot(nrow(ud_grid_sf) == nrow(vms_trawler_grid_sf))
stopifnot(nrow(ud_grid_sf) == nrow(eez_mask_sf))

# Verifica que las cuatro cuadrículas compartan el mismo CRS para
# garantizar que la alineación espacial sea correcta y evitar
# errores silenciosos por proyecciones diferentes
stopifnot(st_crs(ud_grid_sf) == st_crs(vms_longline_grid_sf))
stopifnot(st_crs(ud_grid_sf) == st_crs(vms_trawler_grid_sf))
stopifnot(st_crs(ud_grid_sf) == st_crs(eez_mask_sf))

# Aplica la máscara de ZEE al conteo de individuos multiplicando
# cada valor por el indicador binario, lo que pone a cero las
# celdas fuera de la ZEE del Pacífico mexicano
n_ind_masked <- n_ind_per_cell * is_in_eez_outside_gulf

# Aplica la máscara de ZEE al conteo de puntos de palangre
# multiplicando cada valor por el indicador binario, lo que pone
# a cero las celdas fuera de la ZEE del Pacífico mexicano
n_longline_masked <- n_points_vms_longline_per_cell * is_in_eez_outside_gulf

# Aplica la máscara de ZEE al conteo de puntos de arrastre
# multiplicando cada valor por el indicador binario, lo que pone
# a cero las celdas fuera de la ZEE del Pacífico mexicano
n_trawler_masked <- n_points_vms_trawler_per_cell * is_in_eez_outside_gulf

# Calcula la suma total de individuos en las celdas dentro de la
# ZEE para usar como denominador de la normalización y transformar
# el conteo absoluto en una proporción dentro de la zona de estudio
n_total_individuals <- sum(n_ind_masked)

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

# Normaliza la distribución de individuos dentro de la ZEE
# dividiendo cada celda enmascarada entre la suma total dentro de
# la ZEE para que los valores resulten en una función de masa de
# probabilidad que suma 1 dentro de la zona de estudio
normalized_individuals <- n_ind_masked / n_total_individuals

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

# Calcula el producto celda por celda de la distribución normalizada
# de albatros con la distribución combinada de pesca para obtener un
# índice conjunto que es alto solo donde los albatros coinciden con
# alta intensidad de palangre, arrastre o ambos simultáneamente
udoi_values <- normalized_individuals * normalized_combined_fishing_distribution

# Construye la rejilla de salida con la geometría original de la
# rejilla del KDE y la nueva columna del producto normalizado;
# la geometría se hereda de ud_grid_sf que comparte el mismo CRS
# y orden de filas que vms_longline_grid_sf y vms_trawler_grid_sf
udoi_grid_sf <- ud_grid_sf |>
  mutate(udoi_value = udoi_values) |>
  select(udoi_value)


# ==== SALIDA ====

# Escribe el GeoPackage con el producto normalizado de albatros y
# la suma de distribuciones de pesca como índice conjunto para su
# uso en análisis de riesgo de captura incidental
st_write(udoi_grid_sf, output_gpkg_path, delete_dsn = TRUE)
