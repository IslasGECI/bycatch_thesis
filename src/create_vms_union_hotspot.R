# ==========================================
# Título: Combina hot spots VMS de palangre y arrastre en una union de dos artes
#
# Contexto (Por que):
# Los mapas de hot spots por separado permiten ver la congestión de cada arte,
# pero no muestran las celdas donde al menos un arte presenta agrupación
# significativa. La unión de los hot spots de palangre y arrastre revela la
# extensión combinada del tráfico de ambos artes sobre la rejilla del KDE.
#
# Descripción (Qué / Cómo):
# Lee los GeoPackages de hot spots de palangre y arrastre generados por
# src/compute_vms_by_gear_hotspot.R. Une ambas tablas por el identificador
# único de celda (cell_id). Calcula el conteo de puntos de la unión como el
# máximo entre los dos artes. Calcula el z-score de la unión como el máximo
# entre los dos z-scores. Clasifica cada celda como hot spot de palangre,
# hot spot de arrastre y hot spot de al menos un arte. Escribe la rejilla
# combinada como GeoPackage.
#
# Entradas:
# data/processed/vms_longline_hotspot.gpkg
# data/processed/vms_trawler_hotspot.gpkg
#
# Salida:
# data/processed/vms_union_hotspot.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - Ambas rejillas contienen las mismas celdas (mismos cell_id)
# - El conteo de la unión se calcula con pmax para obtener el máximo
#   entre artes, no la suma
# - El z-score de la unión se calcula con pmax para preservar el hot
#   spot más significativo entre los dos artes
# - El p-valor se recalcula a partir del z-score máximo
# ==========================================


# ==== CONFIGURACIÓN ====

library(sf)
# Proporciona st_read para importar las rejillas y st_write para exportar
# la unión como GeoPackage

library(tidyverse)
# Proporciona dplyr para full_join, mutate, left_join, select y filter

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para los puntos
# VMS de palangre en la rejilla del KDE
input_longline_hotspot_path <- "data/processed/vms_longline_hotspot.gpkg"

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para los puntos
# VMS de arrastre en la rejilla del KDE
input_trawler_hotspot_path <- "data/processed/vms_trawler_hotspot.gpkg"

# Ruta del GeoPackage de salida con la unión de hot spots de palangre
# y arrastre para su uso en el cálculo de intersección con el KBA y
# en el graficado del mapa combinado
output_union_path <- "data/processed/vms_union_hotspot.gpkg"

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96


# ==== ENTRADAS ====

# Importa la rejilla con los z-scores de Getis-Ord Gi* para los puntos
# VMS de palangre desde el GeoPackage generado por
# src/compute_vms_by_gear_hotspot.R
longline_hotspot_sf <- st_read(input_longline_hotspot_path, quiet = TRUE)

# Importa la rejilla con los z-scores de Getis-Ord Gi* para los puntos
# VMS de arrastre desde el GeoPackage generado por
# src/compute_vms_by_gear_hotspot.R
trawler_hotspot_sf <- st_read(input_trawler_hotspot_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 desde el inicio del procesamiento para
# evitar errores por geometrías inválidas en los polígonos de la
# rejilla del KDE durante las operaciones de unión y escritura
sf_use_s2(FALSE)

# Separa los atributos de la rejilla de palangre de su geometría para
# evitar conflictos de columnas duplicadas durante la unión por cell_id
longline_attributes_df <- longline_hotspot_sf |>
  st_drop_geometry()

# Separa los atributos de la rejilla de arrastre de su geometría para
# evitar conflictos de columnas duplicadas durante la unión por cell_id
trawler_attributes_df <- trawler_hotspot_sf |>
  st_drop_geometry()

# Une ambas tablas de atributos por el identificador único de celda
# usando full_join para conservar celdas que pudieran existir en solo
# un arte; los sufijos _longline y _trawler distinguen columnas con
# nombres repetidos como gi_star_z_score y gi_star_p_value
joined_attributes_df <- longline_attributes_df |>
  full_join(trawler_attributes_df, by = "cell_id", suffix = c("_longline", "_trawler"))

# Recupera la geometría de la rejilla desde el archivo de palangre
# porque ambas rejillas comparten las mismas celdas y el mismo CRS;
# la unión left_join por cell_id asegura que cada fila recupere su
# geometría correspondiente
longline_geometry_sf <- longline_hotspot_sf |>
  select(cell_id, geom)

# Reconstruye el objeto espacial uniendo los atributos combinados con
# la geometría de la rejilla usando el identificador de celda como
# clave de correspondencia uno a uno; st_as_sf activa la clase sf
# sobre el data.frame que contiene la columna de geometría
union_hotspot_sf <- joined_attributes_df |>
  left_join(longline_geometry_sf, by = "cell_id") |>
  st_as_sf()

# Calcula el conteo combinado, el z-score máximo, el p-valor y las
# tres clasificaciones binarias en un solo paso de mutate para
# mantener el flujo lineal y evitar asignaciones intermedias
union_hotspot_sf <- union_hotspot_sf |>
  mutate(
    # Conteo combinado como el máximo entre palangre y arrastre usando
    # pmax para que una celda con actividad en al menos un arte tenga
    # un conteo positivo, ignorando valores faltantes del otro arte
    n_points_vms_union = pmax(
      n_points_vms_longline, n_points_vms_trawler, na.rm = TRUE
    ),
    # Z-score combinado como el máximo entre los dos artes usando pmax
    # para conservar el valor más significativo de agrupación espacial
    gi_star_z_score = pmax(
      gi_star_z_score_longline, gi_star_z_score_trawler, na.rm = TRUE
    ),
    # P-valor bilateral aproximado calculado desde el z-score máximo
    # usando la distribución normal acumulada para mantener un formato
    # consistente con los GeoPackages de hot spots individuales; este
    # p-valor es conservador porque usa el máximo de dos pruebas
    gi_star_p_value = 2 * pnorm(
      q = -abs(gi_star_z_score), mean = 0, sd = 1, lower.tail = TRUE
    ),
    # Clasificación de hot spot de palangre: verdadero si la celda
    # tiene al menos un punto VMS de palangre y su z-score supera el
    # umbral de significancia del 95 %; replace_na convierte valores
    # faltantes en FALSE para evitar clasificaciones incorrectas
    is_hotspot_longline = replace_na(
      n_points_vms_longline > 0 & gi_star_z_score_longline >= hot_spot_z_threshold,
      FALSE
    ),
    # Clasificación de hot spot de arrastre: verdadero si la celda
    # tiene al menos un punto VMS de arrastre y su z-score supera el
    # umbral de significancia del 95 %
    is_hotspot_trawler = replace_na(
      n_points_vms_trawler > 0 & gi_star_z_score_trawler >= hot_spot_z_threshold,
      FALSE
    ),
    # Clasificación de hot spot de al menos un arte: verdadero si el
    # palangre o el arrastre (o ambos) presentan agrupación
    # significativa en la celda
    is_hotspot_any = is_hotspot_longline | is_hotspot_trawler
  )


# ==== SALIDA ====

# Escribe la rejilla combinada de palangre y arrastre como GeoPackage
# con los conteos, z-scores, p-valores y clasificaciones de cada arte
# y de la unión, para que los scripts de intersección y graficado
# puedan leerla sin recalcular la combinación de los dos artes
st_write(union_hotspot_sf, output_union_path, delete_dsn = TRUE, quiet = TRUE)
