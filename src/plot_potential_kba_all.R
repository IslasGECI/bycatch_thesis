# ==========================================
# Título: Grafica el polígono rojo del KBA (sitio potencial) del albatros de Laysan
#
# Contexto (Por qué):
# bycatch::render_potential_kba() combina una densidad azul con un contorno
# rojo para las celdas que cumplen el umbral de sitio potencial. Este script
# replica el contorno rojo sobre la ZEE y la costa para integrarlo al estilo
# visual del resto del proyecto.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de polígonos KBA, filtra las celdas con potentialSite = TRUE,
# fusiona sus geometrías en un solo polígono y lo grafica como contorno rojo
# sobre la ZEE de México y la línea de costa. Usa el mismo bounding box de
# zoom in que el mapa de intersección con AMP para mantener coherencia visual.
# Exporta la figura como PNG.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/gps_albatross_50_percent_potential_kba_ars_all_without_mpa.png
#
# Dependencias:
# jsonlite
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - El filtro potentialSite = TRUE aísla el polígono rojo de mapSite()
# - st_union() fusiona las 16 celdas en un solo contorno
# - La ZEE se transforma de NSIDC EASE-Grid Global a WGS 84 (EPSG:4326)
# ==========================================


# ==== CONFIGURACIÓN ====
library(rnaturalearth) # Proporciona ne_countries() para descargar límites políticos mundiales
library(rnaturalearthdata) # Proporciona los datos cartográficos base de Natural Earth
library(sf) # Proporciona st_read para importar geometrías y st_transform para reproyectar
library(tidyverse) # Proporciona ggplot2 para graficar y dplyr para filtrar y agrupar

# Ruta del GeoPackage con los polígonos KBA de ambas colonias
input_kba_path <- "data/processed/kba_polygons_all.gpkg"
# Ruta del shapefile de la Zona Económica Exclusiva de México
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
# Ruta del archivo PNG que almacenará el mapa del polígono rojo del KBA
output_figure_path <- "reports/figures/gps_albatross_50_percent_potential_kba_ars_all_without_mpa.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"
# Sistema de referencia espacial para la reproyección de la ZEE
target_crs <- 4326

# Colores para las capas del mapa
coast_fill_color <- "gray90" # Color de relleno para el continente
coast_line_color <- "gray50" # Color del contorno de la línea de costa
eez_fill_color <- "#93C5FD" # Color de relleno semitransparente para la ZEE
eez_fill_alpha <- 0.2 # Transparencia del relleno de la ZEE para ver capas subyacentes
eez_line_color <- "#1E3A8A" # Color del contorno de la ZEE
kba_polygon_border_color <- "#DC2626" # Color rojo del contorno del sitio potencial KBA
kba_polygon_border_width <- 0.8 # Grosor del contorno rojo del KBA

# Dimensiones y resolución de la figura de salida
fig_width <- 8 # Ancho en pulgadas consistente con otros mapas del proyecto
fig_height <- 6 # Alto en pulgadas que mantiene proporción cartográfica
fig_dpi <- 300 # Resolución adecuada para reportes o publicaciones


# ==== ENTRADAS ====
# Importa los polígonos KBA de ambas colonias desde el GeoPackage
# generado por bycatch::create_potential_kba()
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)
# Importa el shapefile de la ZEE de México como objeto sf para operaciones
# espaciales de superposición geográfica
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)
# Descarga los límites políticos mundiales desde Natural Earth para usar
# como fondo de costa en el mapa; escala media equilibra detalle y velocidad
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")
# ==== PROCESAMIENTO / ANÁLISIS ====
# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la fusión espacial
sf_use_s2(FALSE)
# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# rojo que renderiza bycatch::render_potential_kba()
kba_red_polygon_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # Fusiona todas las celdas del sitio potencial en un solo polígono para
  # graficarlo como un contorno rojo único (sin relleno) sobre el mapa;
  # summarise() sin argumentos disuelve la geometría automáticamente en sf
  summarise()
# Transforma la ZEE de NSIDC EASE-Grid Global a coordenadas geográficas WGS84
# para que coincida con el sistema de referencia de los polígonos KBA
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)
# Define los límites del mapa centrados en el Pacífico de la península de Baja
# California para mostrar el sitio potencial KBA de ambas colonias
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35
# Construye el mapa temático con el contorno rojo del sitio potencial KBA
# sobre la costa y la ZEE como contexto geográfico
plot_kba_all <- ggplot() +
  # Capa base de costa mundial como referencia geográfica regional
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = 0.2
  ) +
  # Capa de la ZEE de México con relleno semitransparente para definir el
  # contexto marítimo de jurisdicción mexicana sin ocultar las capas internas
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = eez_fill_color,
    alpha = eez_fill_alpha,
    color = eez_line_color,
    linewidth = 0.3
  ) +
  # Capa del contorno rojo del sitio potencial KBA (sin relleno) que replica
  # el polígono rojo de mapSite() de bycatch::render_potential_kba()
  geom_sf(
    data = kba_red_polygon_sf,
    fill = NA,
    color = kba_polygon_border_color,
    linewidth = kba_polygon_border_width
  ) +
  # Limita la extensión del mapa al bounding box de zoom in para mantener
  # la misma vista que el mapa de intersección KBA ∩ AMP
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +
  # Estilo limpio que enfatiza las capas espaciales sin distracciones
  theme_minimal() +
  # Etiquetas del mapa en inglés para integrarse al reporte del segundo artículo
  labs(
    title = "Potential KBA for Laysan Albatross — Guadalupe, Clarion and San Benito Islands",
    subtitle = "50% kernel density estimate with ARS smoothing",
    x = "Longitude",
    y = "Latitude"
  )


# ==== SALIDA ====
# Exporta el mapa como PNG con resolución de publicación para incluirlo
# en el reporte del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_kba_all,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
