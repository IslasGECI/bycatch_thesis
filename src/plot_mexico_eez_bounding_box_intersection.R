# ==========================================
# Título: Grafica la intersección entre la EEZ de México y el bounding box
#
# Contexto (Por qué):
# Después de recortar la Zona Económica Exclusiva de México usando un
# bounding box regional, es útil generar una visualización para verificar
# que el recorte espacial ocurrió correctamente y que la región resultante
# coincide con el área esperada del Pacífico Norte.
#
# Descripción (Qué / Cómo):
# Carga el GeoPackage con la intersección entre la EEZ de México y el
# bounding box geográfico, construye una figura simple con ggplot2 y
# la exporta como PNG para facilitar la inspección visual del recorte.
#
# Entradas:
# data/processed/mexico_eez_bounding_box_intersection.gpkg (capa: mexico_eez_bbox)
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/mexico_eez_bounding_box_zoom_in.png
#
# Dependencias:
# glue
# jsonlite
# sf
# tidyverse
#
# Notas:
# - geom_sf() mantiene la geometría original sin reproyecciones adicionales
# - coord_sf() establece los límites del mapa desde el bounding box de configuración
# ==========================================


# ==== CONFIGURACIÓN ====
library(glue)       # Proporciona glue() para interpolar variables en mensajes del gráfico
library(jsonlite)   # Proporciona fromJSON para leer el bounding box de configuración
library(sf)         # Proporciona st_read para importar geometrías desde GeoPackage
library(tidyverse)  # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del archivo JSON con los límites del bounding box de la región de estudio
zoom_bounding_box_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"
# Ruta del GeoPackage con la intersección EEZ-bounding box
input_gpkg_path <- "data/processed/mexico_eez_bounding_box_intersection.gpkg"
# Ruta del archivo PNG que almacenará la figura de la intersección
output_figure_path <- "reports/figures/mexico_eez_bounding_box_zoom_in.png"

# Carga los límites del bounding box desde el archivo JSON de configuración
zoom_bbox <- fromJSON(zoom_bounding_box_path)
# Extrae las coordenadas del bounding box para establecer los límites del mapa
bbox_lon_min <- zoom_bbox$bbox$lon_min
bbox_lon_max <- zoom_bbox$bbox$lon_max
bbox_lat_min <- zoom_bbox$bbox$lat_min
bbox_lat_max <- zoom_bbox$bbox$lat_max

# Nombre de la capa dentro del GeoPackage que contiene la geometría recortada
input_layer_name <- "mexico_eez_bbox"

# Colores para la visualización de la intersección en el mapa
fill_color <- "#7DD3FC"     # Color de relleno que destaca el polígono marino
line_color <- "#075985"     # Color de contorno para definir claramente los límites
line_size <- 0.3            # Grosor de línea moderado para mantener legibilidad

# Dimensiones y resolución de la figura de salida
fig_width <- 8              # Ancho consistente con otros mapas del proyecto
fig_height <- 6             # Alto que mantiene proporción cartográfica
fig_dpi <- 300              # Resolución adecuada para reportes o publicaciones


# ==== ENTRADAS ====
# Importa la capa espacial desde el GeoPackage generado previamente
# con la intersección entre la EEZ de México y el bounding box regional
mexico_eez_bounding_box_sf <- st_read(
  dsn = input_gpkg_path,
  layer = input_layer_name,
  quiet = TRUE
)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye una visualización simple que resalta la geometría recortada
# usando ggplot2 con un enfoque declarativo para mapas reproducibles
plot_mexico_eez_bbox <- ggplot() +
  # Capa de la geometría de la intersección con colores definidos
  geom_sf(
    data = mexico_eez_bounding_box_sf,
    fill = fill_color,
    color = line_color,
    linewidth = line_size
  ) +
  # Limita la extensión del mapa al bounding box de configuración
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +
  # Estilo limpio que enfatiza la geometría espacial
  theme_minimal() +
  # Etiquetas del mapa en español con los límites del bounding box
  labs(
    title = "Intersección de la ZEE de México con el bounding box",
    subtitle = glue(
      "Bounding box: {bbox_lat_min}–{bbox_lat_max}°N, {abs(bbox_lon_max)}–{abs(bbox_lon_min)}°O"
    )
  )


# ==== SALIDA ====
# Exporta la figura como PNG para integrarse con el sistema de reportes
# del proyecto y permitir la inspección visual del recorte espacial
ggsave(
  filename = output_figure_path,
  plot = plot_mexico_eez_bbox,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
