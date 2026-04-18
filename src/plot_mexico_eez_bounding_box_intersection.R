# ==========================================
# Título: Graficar Intersección entre EEZ de México y Bounding Box
#
# Contexto (Por qué):
# Después de recortar la Zona Económica Exclusiva (EEZ) de México usando
# un bounding box regional, es útil generar una visualización rápida para
# verificar que el recorte espacial ocurrió correctamente y que la región
# resultante coincide con el área esperada del Pacífico Norte.
#
# Descripción (Qué / Cómo):
# El script carga el GeoPackage generado previamente que contiene la
# intersección entre la EEZ de México y un bounding box geográfico.
# Posteriormente construye una figura simple usando ggplot2 y la exporta
# como archivo PNG para facilitar inspección visual.
#
# Entradas:
# data/processed/mexico_eez_bounding_box_intersection.gpkg (capa: mexico_eez_bbox)
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salidas:
# reports/figures/mexico_eez_bounding_box_zoom_in.png
#
# Dependencias:
# sf
# tidyverse
# glue
# jsonlite
#
# Notas:
# Se utiliza geom_sf() para mantener la geometría original sin necesidad
# de reproyecciones adicionales.
# Se utiliza coord_sf() para establecer los límites del mapa.
# ==========================================


# ==== HEADER ====
library(glue)       # Permite construir mensajes dinámicos con variables para depuración o logging
library(jsonlite)   # Permite leer archivos JSON de configuración para centralizar parámetros
library(sf)         # Permite leer y manipular datos espaciales vectoriales
library(tidyverse)  # Proporciona ggplot2 para construir visualizaciones declarativas

# ==== CONFIGURATION ====
# Centralizar rutas y parámetros evita valores dispersos y facilita mantenimiento
zoom_bounding_box_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"
input_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
output_figure_path <- "reports/figures/mexico_eez_bounding_box_zoom_in.png"

zoom_bbox <- fromJSON(zoom_bounding_box_path)
bbox_lon_min <- zoom_bbox$bbox$lon_min
bbox_lon_max <- zoom_bbox$bbox$lon_max
bbox_lat_min <- zoom_bbox$bbox$lat_min
bbox_lat_max <- zoom_bbox$bbox$lat_max

input_layer_name <- "mexico_eez_bbox"

fill_color <- "#7DD3FC"     # Color de relleno que destaca el polígono marino
line_color <- "#075985"     # Color de contorno para definir claramente los límites
line_size <- 0.3            # Grosor de línea moderado para mantener legibilidad

fig_width <- 8              # Ancho de figura consistente con otros mapas del proyecto
fig_height <- 6             # Alto que mantiene proporción cartográfica
fig_dpi <- 300              # Resolución adecuada para reportes o publicaciones

# ==== INPUTS ====
# Se lee la capa espacial desde el GeoPackage generado previamente
# quiet = TRUE evita mensajes informativos innecesarios en ejecución automática
mexico_eez_bounding_box_sf <- st_read(
  dsn = input_gpkg_path,
  layer = input_layer_name,
  quiet = TRUE
)


# ==== PROCESS / ANALYSIS ====
# Se construye una visualización simple que resalta la geometría recortada
# ggplot permite un enfoque declarativo para construir mapas reproducibles
plot_mexico_eez_bbox <- ggplot() +
  geom_sf(
    data = mexico_eez_bounding_box_sf,
    fill = fill_color,
    color = line_color,
    linewidth = line_size
  ) +
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +
  theme_minimal() +
  labs(
    title = "Mexico EEZ intersection with albatross GPS data",
    subtitle = glue(
      "Bounding box: {bbox_lat_min}–{bbox_lat_max}°N, {abs(bbox_lon_max)}–{abs(bbox_lon_min)}°W"
    )
  )


# ==== OUTPUT ====
# Se exporta la figura como PNG para integrarse con el sistema de reportes
ggsave(
  filename = output_figure_path,
  plot = plot_mexico_eez_bbox,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
