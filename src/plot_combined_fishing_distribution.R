# ==========================================
# Título: Grafica la distribución combinada de pesca ponderada por UDOI
#
# Contexto (Por qué):
# La distribución combinada de pesca integra las intensidades de
# palangre y arrastre ponderadas por su UDOI individual, dando más
# peso al arte que más coincide espacialmente con los albatros.
# Visualizar esta superficie revela las zonas de mayor intensidad
# de pesca conjunta dentro de la ZEE del Pacífico mexicano.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de distribución combinada de pesca con la
# columna normalized_combined_fishing. Lee la costa mundial, la
# ZEE de México y las áreas marinas protegidas como contexto
# geográfico. Filtra las celdas sin intensidad de pesca para evitar
# saturar el mapa. Mapea la intensidad con la paleta inferno.
# Construye el mapa con ggplot2 y lo exporta como PNG.
#
# Entradas:
# data/processed/combined_fishing_distribution.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/combined_fishing_distribution_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - La distribución combinada pondera palangre y arrastre por su UDOI
#   individual antes de normalizar a masa de probabilidad unitaria
# - El bounding box hardcodeado cubre el Pacífico de la península de
#   Baja California donde se ubican las colonias de albatros
# - La ZEE se transforma de CEA a WGS84 para compatibilidad espacial
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
# las celdas de la rejilla sin intensidad de pesca

# Ruta del GeoPackage con la distribución combinada de pesca
# normalizada por celda generado por export_combined_fishing_distribution.R
input_fishing_gpkg_path <- "data/processed/combined_fishing_distribution.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que proporcionan contexto de conservación marina existente
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México para
# delimitar la jurisdicción marítima mexicana en el mapa
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG que almacenará el mapa de la distribución
# combinada de pesca por celda en la rejilla KDE
output_figure_path <- "reports/figures/combined_fishing_distribution_map.png"

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
# legibilidad en el mapa sin distraer de la capa principal de
# intensidad de pesca combinada
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Opción de la paleta secuencial perceptualmente uniforme para la
# escala continua de pesca que ofrece buena discriminación visual
viridis_option <- "inferno"

# Dirección de la escala de color: -1 invierte el orden para que los
# valores altos aparezcan en tonos brillantes sobre fondo oscuro
viridis_direction <- -1

# Nombre de la leyenda de color que describe la escala de intensidad
# de pesca combinada ponderada por UDOI
color_legend_name <- "Combined fishing intensity"

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte del segundo artículo
fig_width <- 10
fig_height <- 8
fig_dpi <- 300

# Límites del bounding box centrados en el Pacífico de la península
# de Baja California donde se ubican las colonias de albatros de
# Laysan en las islas Guadalupe, Clarion y San Benedicto
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35


# ==== ENTRADAS ====

# Importa la rejilla KDE con la distribución combinada de pesca por
# celda desde el GeoPackage generado por
# src/export_combined_fishing_distribution.R; contiene la superficie
# normalizada de intensidad conjunta de palangre y arrastre
combined_fishing_sf <- st_read(input_fishing_gpkg_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto espacial
# de las zonas de conservación marina en la región de estudio
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima donde ocurre la actividad pesquera
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas donde la
# distribución combinada de pesca es mayor que cero; se omiten las
# celdas sin intensidad de pesca que saturarían el mapa
fishing_positive_sf <- combined_fishing_sf |>
  filter(normalized_combined_fishing > 0)

# Transforma la ZEE de su proyección original CEA a coordenadas
# geográficas WGS84 para que coincida con el sistema de referencia de
# la costa, las AMP y el bounding box hardcodeado del mapa
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas durante el graficado con geom_sf cuando el paquete s2
# encuentra geometrías complejas o anillos con orientación mixta
sf_use_s2(FALSE)

# Construye el mapa temático con las celdas de la rejilla KDE
# coloreadas por la intensidad de pesca combinada sobre la costa,
# la ZEE y las Áreas Marinas Protegidas como contexto geográfico
plot_fishing_grid <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # islas de las colonias de albatros en el mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa principal de las celdas con intensidad de pesca positiva
  # coloreadas por la distribución combinada normalizada que integra
  # palangre y arrastre ponderados por su UDOI individual
  geom_sf(
    data = fishing_positive_sf,
    mapping = aes(fill = normalized_combined_fishing),
    color = NA
  ) +

  # Escala secuencial de color con paleta inferno que mapea la
  # intensidad de pesca combinada desde valores bajos en tonos
  # oscuros hasta valores altos en tonos brillantes
  scale_fill_viridis_c(
    option = viridis_option,
    direction = viridis_direction,
    name = color_legend_name
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sobre las celdas de
  # intensidad de pesca combinada en el Pacífico mexicano
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde sin
  # relleno para mostrar las zonas de conservación existentes en el
  # contexto de la intensidad de pesca combinada
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
    title = "UDOI-weighted combined fishing distribution",
    subtitle = "VMS longline and trawler — normalized probability mass",
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

# Exporta el mapa de la distribución combinada de pesca por celda de
# la rejilla KDE como PNG con resolución de publicación para incluirlo
# en el reporte del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_fishing_grid,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
