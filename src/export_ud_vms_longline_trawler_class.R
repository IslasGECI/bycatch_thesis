# ==========================================
# Título: Clasifica el índice UDOI combinado en categorías por cuartiles
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
# cuartiles (Q1, Q2, Q3). Asigna la clase 0 a las celdas sin
# solapamiento (valor cero). Asigna las clases 1 a 4 a las celdas
# con solapamiento según el cuartil al que pertenezcan. Escribe el
# resultado como GeoPackage con una columna de clase entera.
#
# Entradas:
# data/processed/ud_vms_longline_trawler_udoi.gpkg
#
# Salida:
# data/processed/ud_vms_longline_trawler_class.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - Los cuartiles se calculan solo sobre valores positivos (> 0)
# - La clase 0 indica celda sin solapamiento albatros-pesca
# - Clase 1: valores entre 0 y Q1; Clase 2: entre Q1 y Q2
# - Clase 3: entre Q2 y Q3; Clase 4: mayores a Q3
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
input_gpkg_path <- "data/processed/ud_vms_longline_trawler_udoi.gpkg"

# Ruta del GeoPackage de salida con la clasificación por cuartiles
# del índice UDOI combinado para las celdas dentro de la ZEE
output_gpkg_path <- "data/processed/ud_vms_longline_trawler_class.gpkg"


# ==== ENTRADAS ====

# Importa la rejilla con el producto normalizado de albatros y la
# suma de palangre y arrastre desde el GeoPackage generado por
# export_ud_vms_longline_trawler_udoi.R
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
# los cuartiles exclusivamente sobre la distribución de celdas con
# solapamiento, excluyendo los ceros que distorsionarían los umbrales
positive_udoi_values <- udoi_values[is_positive_value]

# Calcula el primer cuartil (Q1) de los valores positivos para
# definir el límite inferior de la categoría de solapamiento bajo
first_quartile <- quantile(positive_udoi_values, probs = 0.25)

# Calcula el segundo cuartil (Q2, mediana) de los valores positivos
# para dividir la distribución en dos mitades iguales
second_quartile <- quantile(positive_udoi_values, probs = 0.50)

# Calcula el tercer cuartil (Q3) de los valores positivos para
# definir el límite inferior de la categoría de solapamiento alto
third_quartile <- quantile(positive_udoi_values, probs = 0.75)

# Construye la rejilla de clasificación asignando la clase 0 a
# celdas sin solapamiento (valor cero) y las clases 1 a 4 según
# el cuartil al que pertenece cada valor positivo dentro de la ZEE
udoi_classification_sf <- udoi_grid_sf |>
  mutate(
    udoi_class = case_when(
      # Conserva las celdas sin solapamiento con clase 0 para
      # distinguir las áreas donde no hay coincidencia de albatros
      # con palangre ni arrastre dentro de la ZEE
      udoi_value == 0 ~ 0L,
      # Asigna clase 1 a valores positivos hasta el primer cuartil
      # que representan el 25% inferior del solapamiento observado
      udoi_value <= first_quartile ~ 1L,
      # Asigna clase 2 a valores entre el primer y segundo cuartil
      # que representan el segundo cuartil de solapamiento
      udoi_value <= second_quartile ~ 2L,
      # Asigna clase 3 a valores entre el segundo y tercer cuartil
      # que representan el tercer cuartil de solapamiento
      udoi_value <= third_quartile ~ 3L,
      # Asigna clase 4 al resto de valores mayores al tercer
      # cuartil que representan el 25% superior del solapamiento
      TRUE ~ 4L
    )
  ) |>
  select(udoi_class)


# ==== SALIDA ====

# Escribe el GeoPackage con la clasificación por cuartiles del
# índice UDOI combinado para su uso en mapas discretos y análisis
# de riesgo de captura incidental dentro de la ZEE
st_write(udoi_classification_sf, output_gpkg_path, delete_dsn = TRUE)
