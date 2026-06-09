# ==========================================
# Título: Transforma eventos de palangre a formato largo por punto extremo
#
# Contexto (Por qué):
# El mapa de eventos de palangre actual solo muestra la posición de inicio de
# cada evento. Un análisis más completo requiere tanto el punto de inicio
# como el de fin en un formato tabular que permita graficar ambos extremos
# de cada operación de pesca.
#
# Descripción (Qué / Cómo):
# Lee el CSV de eventos de palangre que tiene columnas separadas para
# inicio y fin (start_time, end_time, start_lat, start_lon, end_lat,
# end_lon). Reorganiza cada fila en dos filas: una para el punto de
# inicio y otra para el punto de fin. La columna start_end identifica qué
# extremo del evento representa cada fila. Exporta el resultado como CSV
# en formato largo.
#
# Entradas:
# data/external/oorg_2025_geci_longline_events_v20260402.csv
#
# Salida:
# data/processed/longline_events_long.csv
#
# Dependencias:
# tidyverse
#
# Notas:
# - El nombre start_end abrevia "start" (inicio) y "end" (fin)
# - El formato largo facilita el filtrado por tipo de extremo
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse) # Proporciona bind_rows para apilar los puntos y dplyr para seleccionar columnas

# Ruta del archivo CSV con los eventos de palangre crudos
input_csv_path <- "data/external/oorg_2025_geci_longline_events_v20260402.csv"
# Ruta del archivo CSV de salida con los eventos en formato largo
output_csv_path <- "data/processed/longline_events_long.csv"


# ==== ENTRADAS ====
# Carga el CSV de eventos de palangre con todas las columnas
longline_data <- read_csv(input_csv_path, show_col_types = FALSE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Selecciona las columnas del punto de inicio y les agrega la
# etiqueta "start" en la columna start_end para identificar el origen
start_points <- longline_data |>
  select(
    set_id,
    ssvid,
    time = start_time,
    label,
    lat = start_lat,
    lon = start_lon
  ) |>
  mutate(start_end = "start")

# Selecciona las columnas del punto de fin y les agrega la
# etiqueta "end" en la columna start_end para identificar el destino
end_points <- longline_data |>
  select(
    set_id,
    ssvid,
    time = end_time,
    label,
    lat = end_lat,
    lon = end_lon
  ) |>
  mutate(start_end = "end")

# Apila las tablas de inicio y fin una debajo de la otra para
# obtener un único data frame con ambos extremos de cada evento
longline_long <- bind_rows(start_points, end_points)

# Ordena las filas por set_id y después por el tipo de extremo
# para que cada par inicio-fin aparezca consecutivo y ordenado
longline_long <- longline_long |>
  arrange(set_id, start_end)


# ==== SALIDA ====
# Escribe el CSV en formato largo sin incluir los números de
# fila para mantener el archivo limpio y compatible con otros
# scripts del proyecto que leen datos tabulares
write_csv(longline_long, output_csv_path)
