# ==========================================
# Título: Grafica el mapa combinado del sitio potencial KBA con los hot spots de palangre de GFW
#
# Contexto (Por qué):
# El polígono del KBA (potentialSite = TRUE) delimita la zona de alimentación
# relevante del albatros de Laysan. Las celdas hot spot de palangre de GFW
# indican zonas con agrupación significativa de presión pesquera. El mapa
# combinado superpone ambas capas para visualizar la presión pesquera dentro
# del área de alimentación del albatros.
#
# Descripción (Qué / Cómo):
# Lee los polígonos KBA, las celdas hot spot de GFW, la intersección
# KBA ∩ hot spot, las AMP, la ZEE y la costa. Filtra el KBA a
# potentialSite = TRUE. Construye un mapa con ggplot2 que superpone las
# celdas hot spot, el relleno púrpura del KBA, el relleno rojo de la
# intersección, la ZEE, las AMP y la costa. Usa el bounding box
# hardcodeado de la intersección KBA como extensión.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/processed/gfw_longline_hotspot_all.gpkg
# data/processed/kba_hotspot_intersection.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/kba_and_gfw_longline_hotspot_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - El KBA se filtra a potentialSite = TRUE
# - st_union() fusiona las celdas del sitio potencial en un solo contorno
# - Las celdas hot spot se dibujan debajo del KBA para que el relleno
#   púrpura oculte las celdas verdes dentro del área de alimentación
# - La intersección KBA ∩ hot spot se dibuja sobre el KBA para resaltar
#   las celdas con presión pesquera significativa dentro del KBA
# - La ZEE se transforma de NSIDC EASE-Grid Global a WGS 84 (EPSG:4326)
# ==========================================


# ==== CONFIGURACIÓN ====

library(rnaturalearth)
# Proporciona ne_countries() para descargar límites políticos mundiales

library(rnaturalearthdata)
# Proporciona los datos cartográficos base de Natural Earth

library(sf)
# Proporciona st_read para importar geometrías y st_transform para reproyectar

library(tidyverse)
# Proporciona ggplot2 para graficar y dplyr para filtrar y agrupar

# Ruta del GeoPackage con los polígonos KBA originales para extraer el
# contorno del sitio potencial (potentialSite = TRUE)
input_kba_path <- "data/processed/kba_polygons_all.gpkg"

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para los puntos
# de palangre de GFW en la rejilla del KDE
input_hotspot_path <- "data/processed/gfw_longline_hotspot_all.gpkg"

# Ruta del GeoPackage con la intersección KBA ∩ hot spot para resaltar
# las celdas con presión pesquera significativa dentro del KBA
input_intersection_path <- "data/processed/kba_hotspot_intersection.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la ZEE de México
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG que almacenará el mapa combinado de KBA y hot spots
# de palangre de GFW en el Pacífico mexicano
output_figure_path <- "reports/figures/kba_and_gfw_longline_hotspot_map.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"

# Sistema de referencia espacial para la reproyección de la ZEE
target_crs <- 4326

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96

# Colores para las capas del mapa
coast_fill_color <- "gray90"
coast_line_color <- "gray50"
eez_line_color <- "#1E3A8A"
mpa_line_color <- "#166534"
kba_fill_color <- "#8B5CF6"
hot_spot_fill_color <- "#E67E22"
non_hot_spot_fill_color <- "#2ECC71"
intersection_fill_color <- "#DC2626"

# Grosor de las líneas en las capas del mapa
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Dimensiones y resolución de la figura de salida
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa los polígonos KBA originales para extraer el contorno del sitio
# potencial (potentialSite = TRUE) como referencia del área de alimentación
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)

# Importa la rejilla con los z-scores de Getis-Ord Gi* desde el GeoPackage
# generado por src/compute_gfw_longline_hotspot.R
longline_hotspot_sf <- st_read(input_hotspot_path, quiet = TRUE)

# Importa la intersección KBA ∩ hot spot desde el GeoPackage generado por
# src/export_kba_hotspot_intersection.R
kba_hotspot_intersection_sf <- st_read(input_intersection_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto de las
# zonas marinas protegidas existentes
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contexto geográfico de
# la jurisdicción marítima mexicana
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para usar
# como fondo de costa en el mapa
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la fusión espacial
sf_use_s2(FALSE)

# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# rojo que renderiza mapSite(), y las fusiona en un solo contorno para
# graficarlo como relleno de referencia del área de alimentación
kba_union_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  summarise()

# Filtra la rejilla para conservar solo las celdas con al menos un punto
# de palangre de GFW para evitar saturar la visualización con las celdas
# vacías que no aportan información sobre presión pesquera
grid_nonzero_sf <- longline_hotspot_sf |>
  filter(n_points_gfw_longline > 0) |>
  mutate(
    # Clasifica cada celda como hot spot o no hot spot según el umbral de
    # z-score >= 1.96 que corresponde a un nivel de significancia del 95%
    is_hot_spot = gi_star_z_score >= hot_spot_z_threshold
  )

# Transforma la ZEE de NSIDC EASE-Grid Global a coordenadas geográficas
# WGS84 para que coincida con el sistema de referencia de los demás
# polígonos KBA, AMP y costa
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Define los límites del mapa centrados en el Pacífico de la península de
# Baja California para mostrar la intersección KBA con los hot spots de
# palangre de GFW en la región de la ZEE de México
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35

# Construye el mapa temático con seis capas espaciales que muestran la
# relación entre el sitio potencial KBA y los hot spots de palangre de GFW
plot_kba_hotspot_combined <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional para
  # ubicar visualmente la extensión del mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de las celdas con puntos de palangre coloreadas según la
  # clasificación binaria: naranja para hot spots con agrupación
  # significativa y verde para no hot spots
  geom_sf(
    data = grid_nonzero_sf,
    mapping = aes(fill = is_hot_spot),
    color = NA
  ) +

  # Escala discreta de colores que asigna púrpura al sitio potencial
  # KBA, verde a los no hot spots y naranja a los hot spots, con
  # etiquetas descriptivas para la interpretación del mapa. El orden
  # de la leyenda se controla con breaks para que coincida con la
  # jerarquía visual del mapa
  scale_fill_manual(
    breaks = c("potential_kba", "FALSE", "TRUE"),
    values = c(
      "potential_kba" = kba_fill_color,
      "FALSE" = non_hot_spot_fill_color,
      "TRUE" = hot_spot_fill_color
    ),
    labels = c(
      "potential_kba" = "Potential KBA",
      "FALSE" = "No hot spot (z < 1.96)",
      "TRUE" = "Hot spot (z >= 1.96)"
    ),
    name = "Clasificación Gi*"
  ) +

  # Capa del relleno púrpura del sitio potencial KBA que se dibuja sobre
  # las celdas de palangre para que el color púrpura oculte las celdas
  # verdes dentro del área de alimentación del albatros. El mapeo a
  # fill con una constante genera una entrada en la leyenda para el KBA
  geom_sf(
    data = kba_union_sf,
    mapping = aes(fill = "potential_kba"),
    color = NA
  ) +

  # Capa de la intersección KBA ∩ hot spot con relleno rojo que se dibuja
  # sobre el KBA para resaltar las celdas con presión pesquera significativa
  # dentro del área de alimentación del albatros
  geom_sf(
    data = kba_hotspot_intersection_sf,
    fill = intersection_fill_color,
    color = NA
  ) +

  # Capa de la ZEE de México solo con contorno (sin relleno) para definir
  # el contexto marítimo de jurisdicción mexicana sobre las capas de datos
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde (sin
  # relleno) para mostrar su ubicación sobre las capas de datos
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Limita la extensión del mapa al bounding box centrado en la ZEE de
  # México donde se ubican las colonias de albatros de Laysan
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que enfatiza las capas espaciales sin distracciones
  theme_minimal() +

  # Etiquetas del mapa en inglés para integrarse al reporte del segundo
  # artículo del proyecto sobre riesgo de captura incidental
  labs(
    title = "Potential KBA with GFW Longline Hotspots",
    subtitle = "Laysan Albatross — Guadalupe, Clarion and San Benedicto islands",
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior derecha para no obstruir la
  # visualización de las celdas en el mapa
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa combinado como PNG con resolución de publicación para
# incluirlo en el reporte del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_kba_hotspot_combined,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
