# ==========================================
# Título: Grafica el conteo de individuos por celda de la rejilla KDE
#
# Contexto (Por qué):
# findSite() produce una superficie continua de N_IND que cuenta cuántas
# áreas de distribución individuales (core al 50%) cubren cada celda.
# Visualizar esta superficie revela la gradación del solapamiento entre
# los albatros de Laysan de las tres colonias del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee la rejilla con N_IND desde el GeoPackage generado por
# export_ud_in_grid.R. Lee la costa mundial, la ZEE de México y las
# áreas marinas protegidas como contexto geográfico. Filtra las celdas
# sin solapamiento para evitar saturar el mapa. mapea N_IND con la
# paleta inferno. Construye el mapa con ggplot2 y lo exporta como PNG.
#
# Entradas:
# data/processed/ud_in_grid.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/ud_in_grid_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - El bounding box hardcodeado cubre el Pacífico de la península de
#   Baja California donde se ubican las colonias de albatros
# - La ZEE se transforma de CEA a WGS84 para compatibilidad espacial
# ==========================================


# ==== CONFIGURACIÓN ====

library(rnaturalearth)
# Proporciona ne_countries() para descargar la línea de costa mundial
# como contexto geográfico base del mapa

library(rnaturalearthdata)
# Proporciona los datos cartográficos base de Natural Earth para la
# descarga de límites políticos mundiales

library(sf)
# Proporciona st_read para importar geometrías desde GeoPackage y
# shapefile, y st_transform para reproyectar la ZEE a WGS84

library(tidyverse)
# Proporciona ggplot2 para construir el mapa y dplyr para filtrar
# las celdas de la rejilla sin solapamiento

# Ruta del GeoPackage con la rejilla KDE que contiene el conteo de
# individuos (N_IND) por celda generado por export_ud_in_grid.R
input_ud_gpkg_path <- "data/processed/ud_in_grid.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que proporcionan contexto de conservación marina existente
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México para
# delimitar la jurisdicción marítima mexicana en el mapa
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG que almacenará el mapa del conteo de individuos
# por celda en la rejilla KDE para el reporte del segundo artículo
output_figure_path <- "reports/figures/ud_in_grid_map.png"

# Escala de la línea de costa mundial; "medium" balancea el detalle
# geográfico con la velocidad de descarga desde Natural Earth
coastline_scale <- "medium"

# Sistema de referencia espacial objetivo (WGS84, EPSG:4326) para
# reproyectar la ZEE desde su proyección CEA original y mantener
# compatibilidad con los demás datos geográficos del mapa
target_crs <- 4326

# Colores para las capas de referencia geográfica del mapa
coast_fill_color <- "gray90"
coast_line_color <- "gray50"
eez_line_color <- "#1E3A8A"
mpa_line_color <- "#166534"

# Grosor de las líneas de las capas de referencia para mantener
# legibilidad en el mapa sin distraer de la capa principal de N_IND
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Opción de la paleta secuencial perceptualmente uniforme para la
# escala continua de N_IND que ofrece buena discriminación visual
viridis_option <- "inferno"

# Nombre de la leyenda de color que describe la escala de N_IND
color_legend_name <- "Number of individuals"

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte del segundo artículo
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la rejilla KDE con el conteo de individuos (N_IND) por celda
# desde el GeoPackage generado por src/export_ud_in_grid.R; contiene la
# superficie continua de solapamiento de áreas de distribución núcleo
ud_grid_sf <- st_read(input_ud_gpkg_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto espacial
# de las zonas de conservación marina en la región de estudio
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima donde ocurre el solapamiento de albatros
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas donde al menos un
# individuo tiene su área de distribución núcleo; se omiten 205 mil
# celdas con N_IND igual a cero que saturarían el mapa sin agregar
# información sobre el patrón de solapamiento espacial
grid_positive_sf <- ud_grid_sf |>
  filter(N_IND > 0)

# Transforma la ZEE de su proyección original CEA a coordenadas
# geográficas WGS84 para que coincida con el sistema de referencia de
# la costa, las AMP y el bounding box hardcodeado del mapa
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas durante el graficado con geom_sf cuando el paquete s2
# encuentra geometrías complejas o anillos con orientación mixta
sf_use_s2(FALSE)

# Define los límites del mapa centrados en el Pacífico de la península
# de Baja California donde se ubican las colonias de albatros de Laysan
# en las islas Guadalupe, Clarion y San Benedicto
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35

# Construye el mapa temático con las celdas de la rejilla KDE
# coloreadas por el conteo de individuos sobre la costa, la ZEE y las
# Áreas Marinas Protegidas como contexto geográfico regional
plot_ud_grid <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # islas de las colonias de albatros en el mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa principal de las celdas con al menos un individuo coloreadas
  # por el conteo de áreas de distribución núcleo que se superponen
  # en cada celda de la rejilla KDE
  geom_sf(
    data = grid_positive_sf,
    mapping = aes(fill = N_IND),
    color = NA
  ) +

  # Escala secuencial de color con paleta inferno que mapea N_IND
  # desde valores bajos en tonos oscuros hasta valores altos en tonos
  # brillantes para revelar la gradación del solapamiento espacial
  # de áreas de distribución individuales
  scale_fill_viridis_c(
    option = viridis_option,
    direction = -1,
    name = color_legend_name
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sobre las celdas de
  # solapamiento de albatros en el Pacífico mexicano
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde sin
  # relleno para mostrar las zonas de conservación existentes en el
  # contexto del solapamiento de áreas de distribución de albatros
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Limita la extensión del mapa al bounding box hardcodeado que
  # cubre la región del Pacífico mexicano desde la península de Baja
  # California hasta la latitud de las islas de las colonias
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que elimina el fondo gris predeterminado y enfatiza
  # las capas espaciales del mapa sin distracciones visuales
  theme_minimal() +

  # Etiquetas del mapa en inglés para integrarse al reporte del
  # segundo artículo del proyecto sobre riesgo de captura incidental
  labs(
    title = "Number of individuals using each grid cell",
    subtitle = "Laysan Albatross — Guadalupe, Clarion and San Benedicto islands",
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior del mapa y ajusta el
  # ancho de la barra de color para mejorar la legibilidad
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa del conteo de individuos por celda de la rejilla KDE
# como PNG con resolución de publicación para incluirlo en el reporte
# del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_ud_grid,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
