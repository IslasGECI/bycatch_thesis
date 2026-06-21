# ==========================================
# Título: Calcula Getis-Ord Gi* sobre sumas de señal de radar por celda
#
# Contexto (Por qué):
# Las sumas de señal de radar por celda indican intensidad de
# detección de albatros, pero no toda celda con suma alta es un
# hot spot significativo. El estadístico Getis-Ord Gi* identifica
# celdas con alta intensidad rodeadas de otras celdas con alta
# intensidad en la región del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con las sumas de señal de radar por celda de
# la rejilla del KDE. Construye una matriz de vecindad Queen entre
# celdas usando spdep. Calcula el estadístico Gi* (z-score) para
# cada celda y su p-valor asociado. Escribe la rejilla con los
# z-scores y p-valores como GeoPackage.
#
# Entradas:
# data/processed/radar_signal_in_grid.gpkg
#
# Salida:
# data/processed/radar_signal_hotspot.gpkg
#
# Dependencias:
# sf
# spdep
# tidyverse
#
# Notas:
# - Queen contiguity: vecinas si comparten borde o esquina
# - localG() devuelve z-scores; p-valores con pnorm()
# - Celdas sin vecinos reciben NA en z-score y p-valor
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
library(sf)

# Adjunta spdep para el análisis espacial de vecindad y el
# cálculo del estadístico Getis-Ord Gi*
library(spdep)

# Ruta del GeoPackage con las sumas de señal de radar por celda
# de la rejilla del KDE generadas por src/export_radar_signal_in_grid.R
input_gpkg_path <- "data/processed/radar_signal_in_grid.gpkg"

# Ruta del GeoPackage de salida con los z-scores de Getis-Ord Gi*
output_gpkg_path <- "data/processed/radar_signal_hotspot.gpkg"

# Nombre de la columna que contiene la suma de señal de radar
# por celda sobre la cual se calculará el estadístico Gi* para
# identificar agrupaciones significativas de alta intensidad
column_name_radar_signal_sum <- "sum_radar_signal"

# Tipo de vecindad espacial para la matriz de pesos: TRUE usa
# Queen contiguity (compartir borde o esquina entre celdas)
is_queen_contiguity <- TRUE


# ==== ENTRADAS ====

# Importa la rejilla con las sumas de señal de radar desde el
# GeoPackage generado por src/export_radar_signal_in_grid.R
grid_with_sums <- st_read(input_gpkg_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Construye la lista de vecinos espaciales usando contiguidad
# Queen donde dos celdas son vecinas si comparten un borde o
# una esquina de sus polígonos cuadrados en la rejilla del KDE
neighbors_list <- poly2nb(
  pl = grid_with_sums,
  queen = is_queen_contiguity
)

# Convierte la lista de vecinos a una lista de pesos espaciales
# estilo "W" (fila estandarizada) donde cada celda vecina recibe
# un peso igual a 1 dividido entre el número total de vecinos
spatial_weights <- nb2listw(
  neighbours = neighbors_list,
  style = "W",
  zero.policy = TRUE
)

# Extrae el vector de sumas de señal de radar de la rejilla para
# usarlo como variable de atributo en el estadístico Getis-Ord Gi*
radar_signal_sum_values <- grid_with_sums[[column_name_radar_signal_sum]]

# Calcula el estadístico Getis-Ord Gi* para cada celda usando
# localG que devuelve z-scores positivos para hot spots de alta
# intensidad de señal de radar y negativos para cold spots de
# baja intensidad en la región del Pacífico mexicano
gi_star_results <- localG(
  x = radar_signal_sum_values,
  listw = spatial_weights,
  zero.policy = TRUE
)

# Extrae los z-scores del vector resultado de localG que son el
# estadístico Gi* con valores positivos indicando clustering de
# valores altos y negativos indicando clustering de valores bajos
z_scores <- as.numeric(gi_star_results)

# Calcula el p-valor bilateral para cada z-score usando la
# función de distribución normal acumulada pnorm, donde el
# p-valor representa la probabilidad de observar un z-score
# tan extremo bajo la hipótesis nula de ausencia de patrón
n_cells <- length(z_scores)

# Inicializa el vector de p-valores con NA para todas las
# celdas antes de llenarlo con los valores calculados
p_values <- rep(NA_real_, n_cells)

# Identifica qué celdas tienen z-score finito (no NA) para
# poder calcular su p-valor bilateral correspondiente
is_finite_z <- is.finite(z_scores)

# Calcula el p-valor bilateral solo para las celdas con z-score
# finito usando 2 * P(Z > |z|) como prueba bilateral estándar
p_values[is_finite_z] <- 2 * pnorm(
  q = -abs(z_scores[is_finite_z]),
  mean = 0,
  sd = 1,
  lower.tail = TRUE
)

# Agrega los z-scores y p-valores como nuevas columnas en la
# rejilla para tener todos los resultados en un solo objeto
# espacial listo para su análisis e interpretación de hot spots
grid_with_hotspots <- grid_with_sums |>
  mutate(
    gi_star_z_score = z_scores,
    gi_star_p_value = p_values
  )


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla, las sumas originales de
# señal de radar, los z-scores de Getis-Ord Gi* y los p-valores
# para su uso en la identificación de hot spots de intensidad de
# señal de radar en el Pacífico mexicano
st_write(grid_with_hotspots, output_gpkg_path, delete_dsn = TRUE)
