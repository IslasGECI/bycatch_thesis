# ==========================================
# Título: Visualiza la ZEE de México, el bounding box y los registros GPS de albatros
#
# Contexto (Por qué):
# Los datos de seguimiento GPS de albatros permiten estudiar patrones de
# movimiento y áreas de alimentación. Visualizarlos en el contexto de la
# ZEE de México y el bounding box regional facilita la interpretación
# espacial y la verificación de la calidad de los datos.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de la ZEE de México, los puntos GPS de albatros y
# los bounding boxes de configuración. Transforma la ZEE a WGS84, crea
# los polígonos de los bounding boxes, convierte los puntos GPS a sf y
# genera un mapa con ggplot2 que muestra todas las capas superpuestas.
# Exporta la figura como PNG para su uso en reportes.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/gps_albatross_all.csv
# data/processed/bounding_box.json
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/mexico_eez_bounding_box_zoom_out.png
#
# Dependencias:
# glue
# jsonlite
# sf
# tidyverse
#
# Notas:
# - Las coordenadas GPS están en WGS84; la ZEE se transforma a EPSG:4326 para compatibilidad
# - Se muestran dos bounding boxes: el regional (morado) y el de zoom (naranja)
# ==========================================


# ==== CONFIGURACIÓN ====
library(glue) # Proporciona glue() para interpolar variables en los mensajes del gráfico
library(jsonlite) # Proporciona fromJSON para leer los bounding boxes de configuración
library(sf) # Proporciona st_read, st_transform y st_as_sf para operaciones espaciales
library(tidyverse) # Proporciona ggplot2 y readr para graficar e importar datos tabulares

# Rutas de archivos de entrada
bbox_config_path <- "data/processed/bounding_box.json"
input_gps_path <- "data/processed/gps_albatross_all.csv"
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
zoom_bounding_box_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

# Ruta del archivo PNG de salida
output_figure_path <- "reports/figures/mexico_eez_bounding_box_zoom_out.png"

# Carga los límites del bounding box regional desde el archivo JSON
bbox_config <- fromJSON(bbox_config_path)
bbox_lon_min <- bbox_config$bbox$lon_min
bbox_lon_max <- bbox_config$bbox$lon_max
bbox_lat_min <- bbox_config$bbox$lat_min
bbox_lat_max <- bbox_config$bbox$lat_max

# Carga los límites del bounding box de zoom desde el archivo JSON
bbox_zoom <- fromJSON(zoom_bounding_box_path)
bbox_zoom_lon_min <- bbox_zoom$bbox$lon_min
bbox_zoom_lon_max <- bbox_zoom$bbox$lon_max
bbox_zoom_lat_min <- bbox_zoom$bbox$lat_min
bbox_zoom_lat_max <- bbox_zoom$bbox$lat_max

# Colores para las distintas capas del mapa
fill_eez_color <- "#93C5FD" # Color de relleno de la ZEE de México
line_eez_color <- "#1E3A8A" # Color del contorno de la ZEE
fill_alpha <- 0.5 # Transparencia del relleno de la ZEE
line_bbox_color <- "#C6B7E2" # Color del contorno del bounding box regional
line_zoom_color <- "#F6C177" # Color del contorno del bounding box de zoom
line_bbox_width <- 1 # Grosor de línea de los bounding boxes

# Colores para los puntos GPS según la isla de origen
color_guadalupe <- "#8ECFB0"
color_clarion <- "#C6B7E2"
color_san_benedicto <- "#F4A7A1"

# Tamaño y transparencia de los puntos GPS en el mapa
gps_point_size <- 0.3
gps_point_alpha <- 0.7

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====
# Importa el shapefile de la ZEE de México como objeto sf
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)
# Importa los registros GPS de albatros desde el archivo CSV consolidado
gps_tracks <- read_csv(input_gps_path, show_col_types = FALSE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Transforma la ZEE a coordenadas geográficas WGS84 para que coincida
# con el sistema de referencia de los datos GPS y los bounding boxes
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(4326)

# Convierte los registros GPS de tabla a puntos espaciales sf usando
# las columnas de longitud y latitud como coordenadas geográficas
gps_points_sf <- gps_tracks |>
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE
  )

# Construye el polígono del bounding box regional a partir de las
# coordenadas definidas en el archivo JSON de configuración
bounding_box_polygon <- st_bbox(
  c(
    xmin = bbox_lon_min,
    xmax = bbox_lon_max,
    ymin = bbox_lat_min,
    ymax = bbox_lat_max
  ),
  crs = 4326
) |>
  st_as_sfc()

# Construye el polígono del bounding box de zoom para mostrar el
# área de intersección dentro del contexto regional más amplio
bounding_box_zoom_polygon <- st_bbox(
  c(
    xmin = bbox_zoom_lon_min,
    xmax = bbox_zoom_lon_max,
    ymin = bbox_zoom_lat_min,
    ymax = bbox_zoom_lat_max
  ),
  crs = 4326
) |>
  st_as_sfc()

# Construye el mapa temático con todas las capas espaciales superpuestas
plot_map <- ggplot() +
  # Capa de la ZEE de México con relleno semitransparente
  geom_sf(
    data = mexico_eez_wgs84,
    fill = fill_eez_color,
    color = line_eez_color,
    alpha = fill_alpha
  ) +
  # Capa del bounding box regional que define el área de estudio amplia
  geom_sf(
    data = bounding_box_polygon,
    fill = NA,
    color = line_bbox_color,
    linewidth = line_bbox_width
  ) +
  # Capa de los puntos GPS de albatros coloreados por isla de origen
  geom_sf(
    data = gps_points_sf,
    aes(color = island_name),
    size = gps_point_size,
    alpha = gps_point_alpha
  ) +
  # Asigna colores distintivos a cada colonia de albatros
  scale_color_manual(
    values = c(
      "Guadalupe" = color_guadalupe,
      "Clarion" = color_clarion,
      "San Benedicto" = color_san_benedicto
    )
  ) +
  # Capa del bounding box de zoom que muestra el área de intersección
  geom_sf(
    data = bounding_box_zoom_polygon,
    fill = NA,
    color = line_zoom_color,
    linewidth = line_bbox_width
  ) +
  # Preserva la proyección geográfica original de los datos
  coord_sf() +
  # Estilo limpio que enfatiza las capas espaciales del mapa
  theme_minimal() +
  # Etiquetas del mapa con los nombres de las capas en español
  labs(
    title = "ZEE de México, rutas GPS de albatros y bounding boxes",
    color = "Isla",
    subtitle = glue(
      "Bounding box: {bbox_lat_min}–{bbox_lat_max}°N, {abs(bbox_lon_max)}–{abs(bbox_lon_min)}°O"
    )
  )


# ==== SALIDA ====
# Exporta el mapa como PNG para integrarse con el sistema de reportes
# del proyecto y permitir la inspección visual de las capas espaciales
ggsave(
  filename = output_figure_path,
  plot = plot_map,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
