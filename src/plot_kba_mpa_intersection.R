# ==========================================
# Título: Grafica la intersección entre el sitio potencial KBA y las AMP de México
#
# Contexto (Por qué):
# El polígono rojo del KBA (potentialSite = TRUE) delimita la zona de
# alimentación relevante del albatros de Laysan. Las Áreas Marinas Protegidas
# (AMP) definen zonas marinas bajo protección legal. Su intersección revela
# qué fracción del sitio potencial KBA está protegida dentro del sistema de AMP.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de la intersección KBA ∩ AMP (calculada solo con celdas
# potentialSite = TRUE), los polígonos KBA originales, las AMP, la ZEE y la
# costa. Filtra el KBA a potentialSite = TRUE y lo fusiona en un contorno rojo.
# Construye un mapa con ggplot2 que superpone la intersección destacada sobre
# el contorno rojo del KBA, las AMP, la ZEE y la costa. Usa el bounding box
# de zoom in como extensión.
#
# Entradas:
# data/processed/kba_mpa_intersection_guadalupe.gpkg
# data/processed/kba_polygons_guadalupe.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_with_mpa.png
#
# Dependencias:
# jsonlite
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - El KBA se filtra a potentialSite = TRUE (polígono rojo de mapSite())
# - st_union() fusiona las 16 celdas del sitio potencial en un solo contorno
# - La ZEE se transforma de NSIDC EASE-Grid Global a WGS 84 (EPSG:4326)
# - La intersección ya viene pre-calculada por export_kba_mpa_intersection.R
# ==========================================


# ==== CONFIGURACIÓN ====
library(jsonlite) # Proporciona fromJSON para leer el bounding box de configuración
library(rnaturalearth) # Proporciona ne_countries() para descargar límites políticos mundiales
library(rnaturalearthdata) # Proporciona los datos cartográficos base de Natural Earth
library(sf) # Proporciona st_read para importar geometrías y st_transform para reproyectar
library(tidyverse) # Proporciona ggplot2 para graficar y dplyr para filtrar y agrupar

# Rutas de los archivos de entrada con datos geoespaciales
input_intersection_path <- "data/processed/kba_mpa_intersection_guadalupe.gpkg"
input_kba_path <- "data/processed/kba_polygons_guadalupe.gpkg"
input_mpa_path <- "data/processed/mexico_mpa.gpkg"
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
input_bbox_json_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

# Ruta del archivo PNG que almacenará el mapa de intersección KBA ∩ AMP
output_figure_path <- "reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_with_mpa.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"
# Sistema de referencia espacial para la reproyección de la ZEE
target_crs <- 4326

# Colores para las capas del mapa
coast_fill_color <- "gray90" # Color de relleno para el continente
coast_line_color <- "gray50" # Color del contorno de la línea de costa
eez_fill_color <- NA # Sin relleno para la ZEE (solo contorno)
eez_fill_alpha <- NA # Sin transparencia porque la ZEE no tiene relleno
eez_line_color <- "#1E3A8A" # Color del contorno de la ZEE
mpa_fill_color <- "#86EFAC" # Color de relleno verde claro para las Áreas Marinas Protegidas
mpa_fill_alpha <- 0.3 # Transparencia del relleno de las AMP para ver capas subyacentes
mpa_line_color <- "#166534" # Color del contorno verde oscuro de las AMP
kba_polygon_border_color <- "#DC2626" # Color rojo del contorno del sitio potencial KBA
kba_polygon_border_width <- 0.8 # Grosor del contorno rojo del KBA
intersection_fill_color <- "#22C55E" # Color de relleno destacado para la intersección KBA ∩ AMP
intersection_fill_alpha <- 0.7 # Transparencia moderada para resaltar la intersección
intersection_line_color <- "#166534" # Color del contorno de la intersección

# Dimensiones y resolución de la figura de salida
fig_width <- 8 # Ancho en pulgadas consistente con otros mapas del proyecto
fig_height <- 6 # Alto en pulgadas que mantiene proporción cartográfica
fig_dpi <- 300 # Resolución adecuada para reportes o publicaciones


# ==== ENTRADAS ====
# Importa la intersección KBA ∩ AMP desde el GeoPackage generado por
# export_kba_mpa_intersection.R (ya filtrada a potentialSite = TRUE)
kba_mpa_intersection_sf <- st_read(input_intersection_path, quiet = TRUE)
# Importa los polígonos KBA originales para extraer el contorno rojo del
# sitio potencial (potentialSite = TRUE) como referencia
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)
# Importa las Áreas Marinas Protegidas de México como contexto de las
# zonas marinas protegidas existentes
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)
# Importa el shapefile de la ZEE de México para contexto geográfico de
# la jurisdicción marítima mexicana
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)
# Descarga los límites políticos mundiales desde Natural Earth para usar
# como fondo de costa en el mapa
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")
# Carga los límites del bounding box de zoom in para establecer la
# extensión geográfica centrada en la ZEE de México
bbox_config <- fromJSON(input_bbox_json_path)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la fusión espacial
sf_use_s2(FALSE)
# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# rojo que renderiza bycatch::render_potential_kba(), y las fusiona en un
# solo contorno para graficarlo como referencia
kba_red_polygon_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # summarise() sin argumentos disuelve la geometría automáticamente en sf
  summarise()
# Transforma la ZEE de NSIDC EASE-Grid Global a coordenadas geográficas WGS84
# para que coincida con el sistema de referencia de los polígonos KBA y AMP
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)
# Extrae la longitud oeste del bounding box de zoom in para el límite izquierdo del mapa
bbox_lon_min <- bbox_config$bbox$lon_min
# Extrae la longitud este del bounding box de zoom in para el límite derecho del mapa
bbox_lon_max <- bbox_config$bbox$lon_max
# Extrae la latitud sur del bounding box de zoom in para el límite inferior del mapa
bbox_lat_min <- bbox_config$bbox$lat_min
# Extrae la latitud norte del bounding box de zoom in para el límite superior del mapa
bbox_lat_max <- bbox_config$bbox$lat_max
# Construye el mapa temático con cinco capas espaciales que muestran la
# relación entre el sitio potencial KBA y las AMP
plot_kba_mpa_intersection <- ggplot() +
  # Capa base de costa mundial como referencia geográfica regional para
  # ubicar visualmente la extensión del mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = 0.2
  ) +
  # Capa de la ZEE de México solo con contorno (sin relleno) para definir el
  # contexto marítimo de jurisdicción mexicana sin obstruir las capas internas
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = 0.3
  ) +
  # Capa de las Áreas Marinas Protegidas en verde que muestra la extensión de las
  # zonas marinas bajo protección legal en México
  geom_sf(
    data = mexico_mpa_sf,
    fill = mpa_fill_color,
    alpha = mpa_fill_alpha,
    color = mpa_line_color,
    linewidth = 0.3
  ) +
  # Capa del contorno rojo del sitio potencial KBA (sin relleno) que
  # replica el polígono rojo de mapSite() como referencia del área de
  # alimentación del albatros antes de la intersección con las AMP
  geom_sf(
    data = kba_red_polygon_sf,
    fill = NA,
    color = kba_polygon_border_color,
    linewidth = kba_polygon_border_width
  ) +
  # Capa de la intersección KBA ∩ AMP con color destacado que muestra
  # la fracción del sitio potencial KBA que está bajo protección legal
  geom_sf(
    data = kba_mpa_intersection_sf,
    fill = intersection_fill_color,
    alpha = intersection_fill_alpha,
    color = intersection_line_color,
    linewidth = 0.4
  ) +
  # Limita la extensión del mapa al bounding box de zoom in centrado en
  # la ZEE de México donde se ubican las AMP del Pacífico mexicano
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +
  # Estilo limpio que enfatiza las capas espaciales sin distracciones
  theme_minimal() +
  # Etiquetas del mapa en inglés para integrarse al reporte del primer artículo
  labs(
    title = "KBA Intersection with Marine Protected Areas",
    subtitle = "Laysan Albatross — Guadalupe Island",
    x = "Longitude",
    y = "Latitude"
  )


# ==== SALIDA ====
# Exporta el mapa como PNG con resolución de publicación para incluirlo
# en el reporte del primer artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_kba_mpa_intersection,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
