# ==========================================
# Title: Visualización de la ZEE de México, Bounding Box del Pacífico Norte y Registros GPS de Albatros
#
# Background (Why):
# Los datos de seguimiento GPS de albatros permiten estudiar patrones de
# movimiento, áreas de alimentación y uso del espacio marino. Para interpretar
# estos movimientos es útil visualizarlos en el contexto geográfico donde
# ocurren, particularmente en relación con la Zona Económica Exclusiva (ZEE)
# de México y con una región de estudio definida mediante un bounding box.
# Esta visualización facilita la inspección exploratoria de los datos,
# permitiendo verificar que las trayectorias de las aves se encuentren dentro
# del área esperada del Pacífico Nororiental y que los datos espaciales estén
# correctamente georreferenciados.
#
# What / How:
# El script carga el shapefile de la Zona Económica Exclusiva de México,
# transforma la geometría al sistema de coordenadas geográficas WGS84
# (EPSG:4326) para asegurar compatibilidad con datos GPS, y construye un
# bounding box definido por límites de latitud y longitud que delimitan la
# región de interés. Posteriormente, importa un archivo CSV que contiene
# registros GPS combinados de albatros provenientes de dos colonias
# (Guadalupe y Clarión), convierte esas coordenadas en un objeto espacial
# de tipo sf y genera un mapa con ggplot2 donde se muestran:
#   1) la ZEE de México,
#   2) el bounding box de la región de estudio,
#   3) los puntos GPS de los albatros coloreados según la isla de origen.
# Finalmente, el mapa se exporta como una figura PNG para su uso en reportes
# o inspección visual de los datos.
#
# Inputs:
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/gps_albatross_combined.csv
#
# Outputs:
# reports/figures/mexico_eez_bbox_union.png
#
# Dependencies:
# sf
# tidyverse
#
# Notes:
# Se supone que las coordenadas GPS del archivo CSV están en longitud y
# latitud (WGS84). La conversión explícita del shapefile a EPSG:4326 asegura
# que todas las capas espaciales compartan el mismo sistema de referencia,
# evitando errores de superposición en la visualización.
# ==========================================

library(jsonlite)
library(sf)
library(tidyverse)

# ==== CONFIGURATION ====
config_path <- "bounding_box_config.json"
input_gps_path <- "data/processed/gps_albatross_combined.csv"
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
output_figure_path <- "reports/figures/mexico_eez_bbox_union.png"

bbox_config <- fromJSON(config_path)
bbox_lon_min <- bbox_config$bbox$lon_min
bbox_lon_max <- bbox_config$bbox$lon_max
bbox_lat_min <- bbox_config$bbox$lat_min
bbox_lat_max <- bbox_config$bbox$lat_max

# ==== INPUTS ====
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)

gps_tracks <- read_csv(input_gps_path, show_col_types = FALSE)

# Transform geometry to geographic coordinates
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(4326)

# Convert GPS table to spatial points
gps_points_sf <- gps_tracks |>
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE
  )

# ==== CREATE BOUNDING BOX ====
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

# ==== PLOT ====
plot_map <- ggplot() +
  geom_sf(
    data = mexico_eez_wgs84,
    fill = "#93C5FD",
    color = "#1E3A8A",
    alpha = 0.5
  ) +
  geom_sf(
    data = bounding_box_polygon,
    fill = NA,
    color = "#C6B7E2",
    linewidth = 1
  ) +
  geom_sf(
    data = gps_points_sf,
    aes(color = island_name),
    size = 0.3,
    alpha = 0.7
  ) +
  scale_color_manual(
    values = c(
      "Guadalupe" = "#8ECFB0",
      "Clarion" = "#F4A7A1"
    )
  ) +
  coord_sf() +
  theme_minimal() +
  labs(
    title = "Mexico EEZ, Bounding Box and Albatross GPS Tracks",
    color = "Island"
  )

# ==== OUTPUT ====
ggsave(
  filename = output_figure_path,
  plot = plot_map,
  width = 8,
  height = 6,
  dpi = 300
)
