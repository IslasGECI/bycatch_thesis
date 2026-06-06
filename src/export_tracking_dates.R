# ==========================================
# Título: Exporta fechas extremas de rastreo y conteo de individuos por colonia
#
# Contexto (Por qué):
# El manuscrito del primer artículo necesita las fechas de inicio y fin del
# rastreo GPS para cada colonia, así como el número total de individuos
# rastreados. Centralizar estos valores en un archivo JSON evita
# discrepancias entre el texto del artículo y los datos fuente.
#
# Descripción (Qué / Cómo):
# Lee los archivos CSV con registros GPS de las colonias Guadalupe, Clarion
# y San Benedicto. Para cada colonia extrae las fechas mínima y máxima de
# la columna date, deriva el año de cada fecha extrema y cuenta los
# individuos únicos en la columna name. Combina todos los valores en un
# único objeto JSON de estructura plana y lo escribe en
# data/processed/methods.json.
#
# Entradas:
# data/raw/gps-albatros-guadalupe.csv
# data/raw/gps-albatros-clarion.csv
# data/raw/gps-albatros-san-benedicto.csv
#
# Salida:
# data/processed/methods.json
#
# Dependencias:
# tidyverse
# jsonlite
#
# Notas:
# - Las fechas deben estar en formato ISO 8601 (YYYY-MM-DD) para que el
#   ordenamiento lexicográfico coincida con el orden cronológico
# - El conteo de individuos usa la columna name como identificador único
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse) # Proporciona read_csv para importar datos y n_distinct para conteos
library(jsonlite) # Proporciona write_json para exportar el resultado como JSON

# Ruta del archivo CSV con los registros GPS de la colonia Guadalupe
input_guadalupe_csv_path <- "data/raw/gps-albatros-guadalupe.csv"
# Ruta del archivo CSV con los registros GPS de la colonia Clarion
input_clarion_csv_path <- "data/raw/gps-albatros-clarion.csv"
# Ruta del archivo CSV con los registros GPS de la colonia San Benedicto
input_san_benedicto_csv_path <- "data/raw/gps-albatros-san-benedicto.csv"
# Ruta del archivo JSON que almacenará los metadatos del rastreo por colonia
output_json_path <- "data/processed/methods.json"


# ==== ENTRADAS ====
# Carga los registros GPS de la colonia Guadalupe y lee la columna date
# como texto para preservar el formato ISO 8601 sin conversión a Date
guadalupe_data <- read_csv(
  input_guadalupe_csv_path,
  col_types = cols(date = col_character()),
  show_col_types = FALSE
)
# Carga los registros GPS de la colonia Clarion con la columna date como
# texto para mantener el formato original de las fechas
clarion_data <- read_csv(
  input_clarion_csv_path,
  col_types = cols(date = col_character()),
  show_col_types = FALSE
)
# Carga los registros GPS de la colonia San Benedicto con la columna date
# como texto para mantener el formato original de las fechas
san_benedicto_data <- read_csv(
  input_san_benedicto_csv_path,
  col_types = cols(date = col_character()),
  show_col_types = FALSE
)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Extrae las fechas no vacías de la colonia Guadalupe para calcular los
# extremos temporales del rastreo GPS en esa colonia
guadalupe_dates <- guadalupe_data |>
  filter(!is.na(date)) |>
  pull(date)
# Extrae las fechas no vacías de la colonia Clarion para calcular los
# extremos temporales del rastreo GPS en esa colonia
clarion_dates <- clarion_data |>
  filter(!is.na(date)) |>
  pull(date)
# Extrae las fechas no vacías de la colonia San Benedicto para calcular
# los extremos temporales del rastreo GPS en esa colonia
san_benedicto_dates <- san_benedicto_data |>
  filter(!is.na(date)) |>
  pull(date)

# Calcula la fecha más antigua del rastreo en la colonia Guadalupe usando
# el mínimo lexicográfico sobre el formato ISO 8601 de la columna date
guadalupe_min_date <- min(guadalupe_dates)
# Calcula la fecha más reciente del rastreo en la colonia Guadalupe usando
# el máximo lexicográfico sobre el formato ISO 8601 de la columna date
guadalupe_max_date <- max(guadalupe_dates)
# Calcula la fecha más antigua del rastreo en la colonia Clarion
clarion_min_date <- min(clarion_dates)
# Calcula la fecha más reciente del rastreo en la colonia Clarion
clarion_max_date <- max(clarion_dates)
# Calcula la fecha más antigua del rastreo en la colonia San Benedicto
san_benedicto_min_date <- min(san_benedicto_dates)
# Calcula la fecha más reciente del rastreo en la colonia San Benedicto
san_benedicto_max_date <- max(san_benedicto_dates)

# Extrae el año de la fecha más antigua en Guadalupe para usarlo en el
# texto del artículo donde solo interesa el año, no la fecha completa
guadalupe_min_year <- str_sub(guadalupe_min_date, 1, 4)
# Extrae el año de la fecha más reciente en Guadalupe
guadalupe_max_year <- str_sub(guadalupe_max_date, 1, 4)
# Extrae el año de la fecha más antigua en Clarion
clarion_min_year <- str_sub(clarion_min_date, 1, 4)
# Extrae el año de la fecha más reciente en Clarion
clarion_max_year <- str_sub(clarion_max_date, 1, 4)
# Extrae el año de la fecha más antigua en San Benedicto
san_benedicto_min_year <- str_sub(san_benedicto_min_date, 1, 4)
# Extrae el año de la fecha más reciente en San Benedicto
san_benedicto_max_year <- str_sub(san_benedicto_max_date, 1, 4)

# Cuenta los individuos únicos en la colonia Guadalupe usando la columna
# name como identificador de cada individuo rastreado
guadalupe_n_total <- guadalupe_data |>
  filter(!is.na(name)) |>
  pull(name) |>
  n_distinct()
# Cuenta los individuos únicos en la colonia Clarion
clarion_n_total <- clarion_data |>
  filter(!is.na(name)) |>
  pull(name) |>
  n_distinct()
# Cuenta los individuos únicos en la colonia San Benedicto
san_benedicto_n_total <- san_benedicto_data |>
  filter(!is.na(name)) |>
  pull(name) |>
  n_distinct()

# Combina todos los valores calculados en una lista plana con nombres
# descriptivos que sirven como claves para el mustache del artículo
methods_list <- list(
  guadalupe_n_total = guadalupe_n_total,
  guadalupe_min_date = guadalupe_min_date,
  guadalupe_max_date = guadalupe_max_date,
  guadalupe_min_year = guadalupe_min_year,
  guadalupe_max_year = guadalupe_max_year,
  clarion_n_total = clarion_n_total,
  clarion_min_date = clarion_min_date,
  clarion_max_date = clarion_max_date,
  clarion_min_year = clarion_min_year,
  clarion_max_year = clarion_max_year,
  san_benedicto_n_total = san_benedicto_n_total,
  san_benedicto_min_date = san_benedicto_min_date,
  san_benedicto_max_date = san_benedicto_max_date,
  san_benedicto_min_year = san_benedicto_min_year,
  san_benedicto_max_year = san_benedicto_max_year
)


# ==== SALIDA ====
# Exporta la lista plana como JSON para que el motor de mustache
# resuelva las variables en el texto del primer artículo
write_json(
  methods_list,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE
)
