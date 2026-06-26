# ==========================================
# Título: Clasifica celdas de la rejilla del KDE dentro y fuera de la ZEE del Pacífico mexicano
#
# Contexto (Por qué):
# El análisis de riesgo de captura incidental requiere distinguir las
# celdas de la rejilla del KDE que caen dentro de la ZEE del Pacífico
# mexicano y fuera del Golfo de California de las que están fuera de
# esta zona de estudio. Esta máscara binaria permite filtrar o ponderar
# análisis posteriores según la jurisdicción marítima.
#
# Descripción (Qué / Cómo):
# Extrae la rejilla vacía del estUDm guardado en el RDS del KDE
# individual de todas las colonias. Lee el shapefile de la ZEE de
# México y selecciona la capa del Pacífico mexicano. Lee el polígono
# del Golfo de California desde el archivo KML. Transforma ambos
# polígonos al CRS de la rejilla. Determina qué celdas intersectan
# la ZEE del Pacífico y cuáles intersectan el Golfo de California.
# Asigna 1 a las celdas dentro de la ZEE del Pacífico y fuera del
# Golfo de California, y 0 en cualquier otro caso.
#
# Entradas:
# data/processed/individual_kde_all.rds
# data/external/Exclusive_economic_zone_Mexico.shp
# data/raw/gulf_of_california.kml
#
# Salida:
# data/processed/eez_mask_in_grid.gpkg
#
# Dependencias:
# adehabitatHR
# sf
# tidyverse
#
# Notas:
# - La rejilla se hereda del KDE individual de 95 albatros
# - La capa 2 del shapefile de ZEE corresponde al Pacífico mexicano
# - Las celdas sobre el borde del Golfo se consideran fuera (0)
# - Las celdas sobre el borde de la ZEE se consideran dentro (1)
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para tener disponibles las funciones de
# manipulación de datos y gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta sf para trabajar con datos geoespaciales vectoriales
# y realizar operaciones de intersección espacial
library(sf)

# Adjunta adehabitatHR para extraer la rejilla del estUDm del
# KDE individual de albatros
library(adehabitatHR)

# Ruta del archivo RDS con el KDE individual de todas las colonias
# de albatros, que contiene la rejilla de densidad de utilización
input_kde_rds_path <- "data/processed/individual_kde_all.rds"

# Ruta del shapefile de la Zona Económica Exclusiva de México que
# contiene múltiples capas para distintas regiones marítimas
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo KML con el polígono del Golfo de California que
# delimita la zona que debemos excluir del área de estudio
input_gulf_kml_path <- "data/raw/gulf_of_california.kml"

# Ruta del archivo GeoPackage de salida con la máscara binaria de
# ZEE por celda de la rejilla del KDE
output_gpkg_path <- "data/processed/eez_mask_in_grid.gpkg"

# Índice de la capa del shapefile de ZEE que corresponde al Pacífico
# mexicano, que es la región marítima donde se ubican las colonias
# de albatros de Laysan del proyecto
pacific_eez_shp_layer <- 2

# Nombre de la columna booleana que indica si la celda está dentro
# de la ZEE del Pacífico mexicano y fuera del Golfo de California
mask_column_name <- "in_eez_outside_gulf"


# ==== ENTRADAS ====

# Carga el archivo RDS que contiene el KDE individual de las tres
# colonias de albatros generado por bycatch::create_individual_kde
kde_cache <- readRDS(input_kde_rds_path)

# Extrae la superficie KDE que es un objeto estUDm con la rejilla
# de densidad de utilización para cada individuo de todas las colonias
kde_surface_estUDm <- kde_cache$KDE_surface

# Convierte el estUDm a un SpatialPixelsDataFrame donde cada columna
# representa la densidad de un individuo en cada píxel de la rejilla
kde_pixels_spdf <- estUDm2spixdf(kde_surface_estUDm)

# Convierte cada píxel de la rejilla en un polígono cuadrado para
# poder realizar intersecciones espaciales con sf
kde_polygons_spdf <- as(kde_pixels_spdf, "SpatialPolygonsDataFrame")

# Convierte los polígonos espaciales a un objeto sf para trabajar
# con el ecosistema tidyverse de datos espaciales
grid_sf <- st_as_sf(kde_polygons_spdf)

# Descarta todas las columnas de densidad de los individuos y solo
# conserva la geometría de la rejilla como partición espacial vacía
grid_geometry <- st_geometry(grid_sf)

# Construye un sf limpio con solo la geometría y un identificador
# de celda para poder referenciar cada fila unívocamente
grid_cells <- st_sf(
  cell_id = seq_along(grid_geometry),
  geometry = grid_geometry
)

# Importa el shapefile de la Zona Económica Exclusiva de México que
# contiene los límites marítimos de México en múltiples capas
eez_mexico_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Importa el polígono del Golfo de California desde el archivo KML
# que define el límite geográfico de la zona que debemos excluir
gulf_polygon_sf <- st_read(input_gulf_kml_path, quiet = TRUE)

# Obtiene el CRS proyectado de la rejilla del KDE para poder
# transformar los polígonos de referencia al mismo sistema
grid_crs <- st_crs(grid_cells)

# Selecciona únicamente la capa del Pacífico mexicano del shapefile
# de la ZEE para limitar el análisis a la región de interés donde
# se distribuyen las colonias de albatros de Laysan
eez_pacific_sf <- eez_mexico_sf[pacific_eez_shp_layer, ]

# Transforma la ZEE del Pacífico mexicano del CRS original del
# shapefile al CRS de la rejilla del KDE para que las operaciones
# de intersección espacial sean correctas
eez_pacific_projected_sf <- st_transform(eez_pacific_sf, crs = grid_crs)

# Transforma el polígono del Golfo de California del CRS geográfico
# del KML al CRS de la rejilla del KDE para que las operaciones de
# intersección espacial sean correctas
gulf_projected_sf <- st_transform(gulf_polygon_sf, crs = grid_crs)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas en los polígonos durante las operaciones de intersección
sf_use_s2(FALSE)

# Identifica qué celdas de la rejilla intersectan la ZEE del Pacífico
# mexicano usando intersección espacial entre ambas geometrías. El
# resultado es una lista donde cada elemento contiene los índices de
# los polígonos de ZEE que toca cada celda
indices_eez_per_cell <- st_intersects(grid_cells, eez_pacific_projected_sf)

# Calcula el número de polígonos de ZEE que intersecta cada celda
# aplicando la función lengths a la lista de intersecciones. Una
# celda dentro de la ZEE tendrá al menos un polígono de intersección
n_eez_intersections <- lengths(indices_eez_per_cell)

# Determina qué celdas están dentro de la ZEE del Pacífico mexicano
# convirtiendo el conteo de intersecciones en un valor lógico donde
# TRUE significa que la celda toca la ZEE
is_in_eez_pacific <- n_eez_intersections > 0

# Identifica qué celdas de la rejilla intersectan el polígono del
# Golfo de California para poder excluirlas del área de estudio
indices_gulf_per_cell <- st_intersects(grid_cells, gulf_projected_sf)

# Calcula el número de polígonos del Golfo que intersecta cada celda
# aplicando la función lengths a la lista de intersecciones
n_gulf_intersections <- lengths(indices_gulf_per_cell)

# Determina qué celdas están dentro del Golfo de California
# convirtiendo el conteo de intersecciones en un valor lógico donde
# TRUE significa que la celda toca el Golfo y debe excluirse
is_in_gulf_california <- n_gulf_intersections > 0

# Calcula la máscara binaria que vale 1 únicamente para las celdas
# que están dentro de la ZEE del Pacífico mexicano y fuera del Golfo
# de California, que es la región de interés para el análisis de
# riesgo de captura incidental del albatros de Laysan
is_eez_outside_gulf <- is_in_eez_pacific & !is_in_gulf_california

# Convierte el vector lógico a entero para que la columna en el
# GeoPackage sea numérica y compatible con operaciones de filtrado
# y ponderación en análisis posteriores
in_eez_outside_gulf <- as.integer(is_eez_outside_gulf)

# Agrega la máscara binaria de ZEE como una nueva columna en la
# rejilla para tener la clasificación espacial y la geometría en
# un solo objeto espacial listo para exportar
grid_with_mask <- grid_cells |>
  mutate(!!mask_column_name := in_eez_outside_gulf)


# ==== SALIDA ====

# Escribe el GeoPackage con la rejilla y la máscara binaria de ZEE
# por celda para que los scripts de análisis posteriores puedan
# filtrar o ponderar las celdas según su ubicación dentro o fuera
# de la ZEE del Pacífico mexicano
st_write(grid_with_mask, output_gpkg_path, delete_dsn = TRUE)
