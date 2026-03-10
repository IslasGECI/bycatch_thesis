# ==========================================
# Title: Plot Mexico EEZ Bounding Box Intersection
#
# Background (Why):
# Después de recortar la Zona Económica Exclusiva (EEZ) de México usando
# un bounding box regional, es útil generar una visualización rápida para
# verificar que el recorte espacial ocurrió correctamente y que la región
# resultante coincide con el área esperada del Pacífico Norte.
#
# What / How:
# El script carga el GeoPackage generado previamente que contiene la
# intersección entre la EEZ de México y un bounding box geográfico.
# Posteriormente construye una figura simple usando ggplot2 y la exporta
# como archivo PNG para facilitar inspección visual.
#
# Inputs:
# data/processed/mexico_eez_bbox_intersection.gpkg (layer: mexico_eez_bbox)
#
# Outputs:
# reports/figures/mexico_eez_bbox.png
#
# Dependencies:
# sf, tidyverse
#
# Notes:
# Se utiliza geom_sf() para mantener la geometría original sin necesidad
# de reproyecciones adicionales.
# ==========================================


# ==== HEADER ====
library(sf)         # Permite leer y manipular datos espaciales vectoriales
library(tidyverse)  # Proporciona ggplot2 para construir visualizaciones declarativas


# ==== CONFIGURATION ====
# Centralizar rutas y parámetros evita valores dispersos y facilita mantenimiento
input_gpkg_path <- "data/processed/mexico_eez_bbox_intersection.gpkg"
input_layer_name <- "mexico_eez_bbox"

output_figure_path <- "reports/figures/mexico_eez_bbox.png"

fill_color <- "#7DD3FC"     # Color de relleno que destaca el polígono marino
line_color <- "#075985"     # Color de contorno para definir claramente los límites
line_size <- 0.3            # Grosor de línea moderado para mantener legibilidad

fig_width <- 8              # Ancho de figura consistente con otros mapas del proyecto
fig_height <- 6             # Alto que mantiene proporción cartográfica
fig_dpi <- 300              # Resolución adecuada para reportes o publicaciones


# ==== INPUTS ====
# Se lee la capa espacial desde el GeoPackage generado previamente
# quiet = TRUE evita mensajes informativos innecesarios en ejecución automática
mexico_eez_bbox_sf <- st_read(
  dsn = input_gpkg_path,
  layer = input_layer_name,
  quiet = TRUE
)


# ==== PROCESS / ANALYSIS ====
# Se construye una visualización simple que resalta la geometría recortada
# ggplot permite un enfoque declarativo para construir mapas reproducibles
plot_mexico_eez_bbox <- ggplot() +
  geom_sf(
    data = mexico_eez_bbox_sf,
    fill = fill_color,
    color = line_color,
    linewidth = line_size
  ) +
  coord_sf() +      # Mantiene la proyección geográfica del objeto sf
  theme_minimal() + # Reduce elementos visuales para enfatizar la geometría
  labs(
    title = "Mexico EEZ Intersection with North Pacific Bounding Box",
    subtitle = "Spatial subset: 10–55°N, 110–170°W",
    caption = "Source: mexico_eez_bbox_intersection.gpkg"
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
