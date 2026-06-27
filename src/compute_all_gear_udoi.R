# ==========================================
# Título: Calcula el índice UDOI de solapamiento albatros-palangre-arrastre
#
# Contexto (Por qué):
# La rejilla ud_vms_all_gear_udoi.gpkg contiene el producto de
# las masas de probabilidad normalizadas de albatros con la suma de
# palangre y arrastre por celda. El índice UDOI (Utilization
# Distribution Overlap Index) sintetiza en un solo número el
# solapamiento entre albatros y la pesca combinada dentro de la ZEE
# del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con el producto normalizado de solapamiento
# por celda. Cuenta las celdas con valor mayor a cero como
# celdas de solapamiento. Calcula la suma total del producto.
# Multiplica el número de celdas de solapamiento por la suma
# del producto para obtener el UDOI. Escribe las estadísticas
# como JSON.
#
# Entradas:
# data/processed/ud_vms_all_gear_udoi.gpkg
#
# Salida:
# data/processed/all_gear_udoi.json
#
# Dependencias:
# sf
# jsonlite
#
# Notas:
# - El UDOI condicional a la ZEE usa n_overlap * sum(udoi_value)
# - cell_area = 127.3 km2 (LAEA, todas las celdas iguales)
# - El area se cancela al usar masas de probabilidad (suma = 1)
# ==========================================


# ==== CONFIGURACION ====

# Adjunta sf para leer datos geoespaciales desde GeoPackage y
# trabajar con geometrias vectoriales dentro del flujo tidyverse
library(sf)

# Adjunta jsonlite para exportar estadisticas en formato JSON
# que otros lenguajes y herramientas puedan consumir facilmente
library(jsonlite)

# Ruta del GeoPackage con el producto normalizado de las masas de
# probabilidad de albatros (N_IND) y la suma de palangre y arrastre
# (n_points) por celda generado por export_ud_vms_all_gear_udoi.R
input_gpkg_path <- "data/processed/ud_vms_all_gear_udoi.gpkg"

# Ruta del archivo JSON de salida con las estadisticas del indice
# UDOI para su uso en reportes y analisis de solapamiento conjunto
output_json_path <- "data/processed/all_gear_udoi.json"

# Nombre de la columna en el GeoPackage que contiene el producto
# de las distribuciones normalizadas por celda (udoi_value)
column_udoi_value <- "udoi_value"

# Area constante de cada celda en kilometros cuadrados derivada
# del CRS LAEA (+proj=laea) donde todas las celdas de la rejilla
# del KDE tienen area geometrica identica
cell_area_km2 <- 127.291418


# ==== ENTRADAS ====

# Importa la rejilla con el producto normalizado de albatros y la
# suma de palangre y arrastre desde el GeoPackage generado por
# export_ud_vms_all_gear_udoi.R
udoi_grid_sf <- st_read(input_gpkg_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANALISIS ====

# Extrae el vector del producto normalizado por celda donde cada
# valor representa la probabilidad conjunta de albatros y pesca
# combinada en esa celda dentro de la ZEE del Pacifico mexicano
udoi_values <- udoi_grid_sf[[column_udoi_value]]

# Cuenta el numero total de celdas en la rejilla del KDE que es la
# particion espacial comun para todos los analisis del proyecto
n_total_cells <- length(udoi_values)

# Cuenta las celdas donde el producto normalizado es mayor que cero
# porque representan los sitios donde ambas distribuciones coinciden
# dentro de la ZEE del Pacifico mexicano
n_overlap_cells <- sum(udoi_values > 0)

# Calcula la suma total del producto celda por celda que representa
# la probabilidad conjunta acumulada de solapamiento entre albatros
# y pesca combinada en toda la zona de estudio
sum_product <- sum(udoi_values)

# Calcula el indice UDOI multiplicando el numero de celdas de
# solapamiento por la suma del producto; el area de celda se
# cancela al usar masas de probabilidad que suman 1 cada una
udoi_index <- n_overlap_cells * sum_product


# ==== SALIDA ====

# Construye la lista con todas las estadisticas del UDOI y metadatos
# asociados para exportar como JSON con trazabilidad completa
udoi_statistics <- list(
  udoi = udoi_index,
  n_overlap = n_overlap_cells,
  sum_product = sum_product,
  cell_area_km2 = cell_area_km2,
  n_total_cells = n_total_cells,
  input = input_gpkg_path
)

# Escribe las estadisticas del UDOI como archivo JSON para que
# puedan ser consumidas por reportes, analisis y el Makefile
write_json(udoi_statistics, output_json_path, auto_unbox = TRUE, pretty = TRUE, digits = 10)
