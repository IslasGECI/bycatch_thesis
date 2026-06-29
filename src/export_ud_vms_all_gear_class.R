# ==========================================
# Título: Clasifica el índice UDOI combinado en categorías por percentiles
#
# Contexto (Por qué):
# El índice UDOI combinado de albatros-palangre-arrastre es una
# superficie continua. Necesitamos discretizarla en cuatro categorías
# para facilitar la interpretación y comparación entre celdas dentro
# de la ZEE del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con el producto normalizado de solapamiento por
# celda. Extrae los valores positivos del índice y calcula sus tres
# percentiles (p50, p75, p95). Asigna la clase 0 a las celdas sin
# solapamiento (valor cero). Asigna las clases 1 a 4 a las celdas
# con solapamiento según el percentil al que pertenezcan. Escribe el
# resultado como GeoPackage con una columna de clase entera.
#
# Entradas:
# data/processed/ud_vms_all_gear_udoi.gpkg
#
# Salida:
# data/processed/ud_vms_all_gear_class.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - Los percentiles se calculan solo sobre valores positivos (> 0)
# - La clase 0 indica celda sin solapamiento albatros-pesca
# - Clase 1: riesgo mínimo (50 % inferior, ≤ percentil 50)
# - Clase 2: riesgo bajo (siguiente 25 %, percentil 50–75)
# - Clase 3: riesgo medio (siguiente 20 %, percentil 75–95)
# - Clase 4: riesgo alto (5 % superior, > percentil 95)
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta sf para leer datos geoespaciales desde GeoPackage y
# trabajar con geometrías vectoriales dentro del flujo tidyverse
library(sf)

# Adjunta tidyverse para transformación y clasificación de datos
# con dplyr (mutate, case_when) dentro del ecosistema tidy
library(tidyverse)

# Ruta del GeoPackage con el producto normalizado de solapamiento
# de albatros con palangre y arrastre por celda de la rejilla KDE
input_gpkg_path <- "data/processed/ud_vms_all_gear_udoi.gpkg"

# Ruta del GeoPackage de salida con la clasificación por percentiles
# del índice UDOI combinado para las celdas dentro de la ZEE
output_gpkg_path <- "data/processed/ud_vms_all_gear_class.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla con el producto normalizado de albatros y la
# suma de palangre y arrastre desde el GeoPackage generado por
# export_ud_vms_all_gear_udoi.R
udoi_grid_sf <- st_read(input_gpkg_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Extrae el vector del producto normalizado por celda donde cada
# valor representa la probabilidad conjunta de albatros y pesca
# combinada en esa celda dentro de la ZEE del Pacífico mexicano
udoi_values <- udoi_grid_sf$udoi_value

# Identifica las celdas con valor positivo porque representan los
# sitios donde ambas distribuciones coinciden dentro de la ZEE
is_positive_value <- udoi_values > 0

# Extrae solo los valores positivos del índice UDOI para calcular
# los percentiles exclusivamente sobre la distribución de celdas con
# solapamiento, excluyendo los ceros que distorsionarían los umbrales
positive_udoi_values <- udoi_values[is_positive_value]

# Calcula el percentil 50 (mediana) de los valores positivos para
# definir el límite superior de la categoría de riesgo mínimo
threshold_1 <- quantile(positive_udoi_values, probs = 0.50)

# Calcula el percentil 75 de los valores positivos para definir el
# límite superior de la categoría de riesgo bajo
threshold_2 <- quantile(positive_udoi_values, probs = 0.75)

# Calcula el percentil 95 de los valores positivos para definir el
# límite superior de la categoría de riesgo medio
threshold_3 <- quantile(positive_udoi_values, probs = 0.95)

# Construye la rejilla de clasificación asignando la clase 0 a
# celdas sin solapamiento (valor cero) y las clases 1 a 4 según
# el percentil al que pertenece cada valor positivo dentro de la ZEE
udoi_classification_sf <- udoi_grid_sf |>
  mutate(
    udoi_class = case_when(
      # Conserva las celdas sin solapamiento con clase 0 para
      # distinguir las áreas donde no hay coincidencia de albatros
      # con palangre ni arrastre dentro de la ZEE
      udoi_value == 0 ~ 0L,
      # Asigna clase 1 (riesgo mínimo) a valores ≤ percentil 50
      # que representan el 50 % inferior del solapamiento observado
      udoi_value <= threshold_1 ~ 1L,
      # Asigna clase 2 (riesgo bajo) a valores entre percentil 50 y 75
      # que representan el siguiente 25 % del solapamiento observado
      udoi_value <= threshold_2 ~ 2L,
      # Asigna clase 3 (riesgo medio) a valores entre percentil 75 y 95
      # que representan el siguiente 20 % del solapamiento observado
      udoi_value <= threshold_3 ~ 3L,
      # Asigna clase 4 (riesgo alto) al resto de valores mayores al
      # percentil 95 que representan el 5 % superior del solapamiento
      TRUE ~ 4L
    )
  ) |>
  select(udoi_class)


# ==== SALIDA ====

# Escribe el GeoPackage con la clasificación por percentiles del
# índice UDOI combinado para su uso en mapas discretos y análisis
# de riesgo de captura incidental dentro de la ZEE
st_write(udoi_classification_sf, output_gpkg_path, delete_dsn = TRUE)
