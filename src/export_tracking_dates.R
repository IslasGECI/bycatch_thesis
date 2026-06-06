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

# ==== PROCESAMIENTO DE TEMPORADAS ====
# Prepara los registros de Guadalupe para agruparlos por temporada de
# rastreo: octubre-septiembre en lugar de año calendario
guadalupe_with_season <- guadalupe_data |>
  filter(!is.na(date), !is.na(name)) |>
  mutate(
    # Extrae el año numérico de los primeros cuatro caracteres de la fecha
    year = as.numeric(str_sub(date, 1, 4)),
    # Extrae el mes numérico de los caracteres 6 y 7 de la fecha ISO
    month = as.numeric(str_sub(date, 6, 7)),
    # Asigna cada registro a la temporada Oct-Sep: los meses antes de
    # octubre pertenecen a la temporada que inició el año anterior
    season_year = if_else(month >= 10, year, year - 1)
  )
# Calcula el rango de temporadas con datos en la colonia Guadalupe para
# construir la secuencia completa de temporadas consecutivas
guadalupe_season_range <- guadalupe_with_season |>
  summarise(
    min_season = min(season_year),
    max_season = max(season_year)
  )
# Crea una secuencia completa de temporadas desde la primera hasta la
# última para incluir temporadas sin rastreo en la tabla del artículo
guadalupe_season_complete <- tibble(
  season_year = seq(
    guadalupe_season_range$min_season,
    guadalupe_season_range$max_season
  )
)
# Agrupa los registros por temporada y calcula las fechas extremas y el
# número de individuos únicos rastreados en cada temporada con datos
guadalupe_season_stats <- guadalupe_with_season |>
  group_by(season_year) |>
  summarise(
    start = min(date),
    end = max(date),
    n = n_distinct(name),
    .groups = "drop"
  )
# Combina la secuencia completa con las estadísticas calculadas para
# rellenar las temporadas sin datos con valores de ausencia
guadalupe_seasons_full <- guadalupe_season_complete |>
  left_join(guadalupe_season_stats, by = "season_year") |>
  mutate(
    # Usa "--" para la fecha de inicio en temporadas sin rastreo GPS
    start = if_else(is.na(start), "--", start),
    # Usa "--" para la fecha de término en temporadas sin rastreo GPS
    end = if_else(is.na(end), "--", end),
    # Usa cero para el conteo de individuos en temporadas sin rastreo
    n = if_else(is.na(n), 0L, n),
    # Crea la etiqueta de temporada con formato AAAA-AAAA para la tabla
    season = paste0(season_year, "-", season_year + 1)
  ) |>
  # Ordena las temporadas de la más antigua a la más reciente antes de
  # descartar la columna season_year que solo sirve para el ordenamiento
  arrange(season_year) |>
  # Conserva solo las columnas que aparecerán en la tabla del artículo
  select(season, start, end, n)


# Prepara los registros de Clarion para el agrupamiento por temporada
# octubre-septiembre siguiendo el mismo procedimiento que Guadalupe
clarion_with_season <- clarion_data |>
  filter(!is.na(date), !is.na(name)) |>
  mutate(
    year = as.numeric(str_sub(date, 1, 4)),
    month = as.numeric(str_sub(date, 6, 7)),
    season_year = if_else(month >= 10, year, year - 1)
  )
# Calcula el rango de temporadas con datos en la colonia Clarion
clarion_season_range <- clarion_with_season |>
  summarise(
    min_season = min(season_year),
    max_season = max(season_year)
  )
# Crea la secuencia completa de temporadas consecutivas para Clarion
clarion_season_complete <- tibble(
  season_year = seq(
    clarion_season_range$min_season,
    clarion_season_range$max_season
  )
)
# Agrupa los registros de Clarion por temporada y calcula fechas y conteos
clarion_season_stats <- clarion_with_season |>
  group_by(season_year) |>
  summarise(
    start = min(date),
    end = max(date),
    n = n_distinct(name),
    .groups = "drop"
  )
# Combina la secuencia completa con las estadísticas para incluir
# temporadas sin datos de Clarion en la tabla del artículo
clarion_seasons_full <- clarion_season_complete |>
  left_join(clarion_season_stats, by = "season_year") |>
  mutate(
    start = if_else(is.na(start), "--", start),
    end = if_else(is.na(end), "--", end),
    n = if_else(is.na(n), 0L, n),
    season = paste0(season_year, "-", season_year + 1)
  ) |>
  arrange(season_year) |>
  select(season, start, end, n)


# Prepara los registros de San Benedicto para el agrupamiento por
# temporada octubre-septiembre siguiendo el mismo procedimiento
san_benedicto_with_season <- san_benedicto_data |>
  filter(!is.na(date), !is.na(name)) |>
  mutate(
    year = as.numeric(str_sub(date, 1, 4)),
    month = as.numeric(str_sub(date, 6, 7)),
    season_year = if_else(month >= 10, year, year - 1)
  )
# Calcula el rango de temporadas con datos en San Benedicto
san_benedicto_season_range <- san_benedicto_with_season |>
  summarise(
    min_season = min(season_year),
    max_season = max(season_year)
  )
# Crea la secuencia completa de temporadas consecutivas para San Benedicto
san_benedicto_season_complete <- tibble(
  season_year = seq(
    san_benedicto_season_range$min_season,
    san_benedicto_season_range$max_season
  )
)
# Agrupa los registros de San Benedicto por temporada y calcula fechas y conteos
san_benedicto_season_stats <- san_benedicto_with_season |>
  group_by(season_year) |>
  summarise(
    start = min(date),
    end = max(date),
    n = n_distinct(name),
    .groups = "drop"
  )
# Combina la secuencia completa con las estadísticas para incluir
# temporadas sin datos de San Benedicto en la tabla del artículo
san_benedicto_seasons_full <- san_benedicto_season_complete |>
  left_join(san_benedicto_season_stats, by = "season_year") |>
  mutate(
    start = if_else(is.na(start), "--", start),
    end = if_else(is.na(end), "--", end),
    n = if_else(is.na(n), 0L, n),
    season = paste0(season_year, "-", season_year + 1)
  ) |>
  arrange(season_year) |>
  select(season, start, end, n)


# ==== ENSAMBLE DE LA SALIDA ====
# Combina los valores planos con las tablas de temporadas en una lista
# única que el motor de mustache usa para resolver todas las variables
methods_list <- list(
  guadalupe_n_total = guadalupe_n_total,
  guadalupe_min_date = guadalupe_min_date,
  guadalupe_max_date = guadalupe_max_date,
  guadalupe_min_year = guadalupe_min_year,
  guadalupe_max_year = guadalupe_max_year,
  guadalupe_seasons = guadalupe_seasons_full,
  clarion_n_total = clarion_n_total,
  clarion_min_date = clarion_min_date,
  clarion_max_date = clarion_max_date,
  clarion_min_year = clarion_min_year,
  clarion_max_year = clarion_max_year,
  clarion_seasons = clarion_seasons_full,
  san_benedicto_n_total = san_benedicto_n_total,
  san_benedicto_min_date = san_benedicto_min_date,
  san_benedicto_max_date = san_benedicto_max_date,
  san_benedicto_min_year = san_benedicto_min_year,
  san_benedicto_max_year = san_benedicto_max_year,
  san_benedicto_seasons = san_benedicto_seasons_full
)


# ==== SALIDA ====
# Exporta la lista completa como JSON para que el motor de mustache
# resuelva las variables en el texto del primer artículo, usando el
# formato renglón para conservar la estructura tabular de temporadas
write_json(
  methods_list,
  output_json_path,
  pretty = TRUE,
  auto_unbox = TRUE,
  dataframe = "rows"
)
