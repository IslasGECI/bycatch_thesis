# ==========================================
# Título: Grafica la máscara binaria de ZEE del Pacífico mexicano sobre la rejilla del KDE
#
# Contexto (Por qué):
# La máscara binaria de ZEE clasifica cada celda de la rejilla del
# KDE como 1 si está dentro de la ZEE del Pacífico mexicano y fuera
# del Golfo de California, y 0 en cualquier otro caso. Visualizar
# esta máscara permite verificar la cobertura espacial de la ZEE
# sobre el área de distribución del albatros de Laysan.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con la máscara binaria de ZEE por celda de la
# rejilla del KDE. Importa el polígono de la ZEE de México, las
# Áreas Marinas Protegidas y la línea de costa mundial. Transforma
# la ZEE a coordenadas geográficas WGS84. Construye un mapa con
# ggplot2 que superpone las celdas coloreadas según la máscara
# binaria, la ZEE, las AMP y la costa. Usa el bounding box
# hardcodeado de la región del Pacífico mexicano como extensión.
#
# Entradas:
# data/processed/eez_mask_in_grid.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/mexico_mpa.gpkg
#
# Salida:
# reports/figures/eez_mask_in_grid.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Las celdas con valor 1 se colorean en celeste (#7DD3FC)
# - Las celdas con valor 0 se colorean en gris claro (gray90)
# - La ZEE se transforma de NSIDC EASE-Grid Global a WGS 84
# - El mapa no incluye leyenda porque el título explica los colores
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta rnaturalearth para descargar los límites políticos
# mundiales desde Natural Earth como fondo cartográfico
library(rnaturalearth)

# Adjunta rnaturalearthdata para tener disponibles los datos
# cartográficos base de Natural Earth a distintas escalas
library(rnaturalearthdata)

# Adjunta sf para leer archivos geoespaciales y transformar
# sistemas de referencia de coordenadas
library(sf)

# Adjunta tidyverse para manipulación de datos con dplyr y
# construcción de gráficos con ggplot2
library(tidyverse)

# Ruta del GeoPackage con la máscara binaria de ZEE por celda
# de la rejilla del KDE generado por export_eez_mask_in_grid.R
input_mask_gpkg_path <- "data/processed/eez_mask_in_grid.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México
# que proporciona el contorno marítimo de referencia
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que muestra las zonas marinas bajo protección legal
input_mpa_gpkg_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del archivo PNG que almacenará el mapa de la máscara
# binaria de ZEE sobre la rejilla del KDE
output_figure_path <- "reports/figures/eez_mask_in_grid.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"

# Sistema de referencia espacial para la reproyección de la ZEE
# a coordenadas geográficas WGS84
target_crs <- 4326

# Colores para las capas del mapa
coast_fill_color <- "gray90"
# Color de relleno gris claro para el continente que no compite
# visualmente con las celdas de la rejilla
coast_line_color <- "gray50"
# Color del contorno de la línea de costa para definir claramente
# los límites terrestres
eez_line_color <- "#1E3A8A"
# Color azul oscuro del contorno de la ZEE para distinguirla de
# las celdas celestes de la máscara
mpa_line_color <- "#166534"
# Color verde oscuro del contorno de las AMP para mantener
# consistencia visual con los mapas de hot spot del proyecto
mask_value_one_fill_color <- "#7DD3FC"
# Color celeste para las celdas dentro de la ZEE del Pacífico
# mexicano y fuera del Golfo de California
mask_value_zero_fill_color <- "#C8D8D0"
# Color gris con matiz azul-verdoso para las celdas fuera de la
# ZEE o dentro del Golfo de California, distinguible del relleno
# gris neutro de la costa

# Grosor de las líneas en las capas del mapa
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la máscara binaria de ZEE por celda desde el GeoPackage
# generado por export_eez_mask_in_grid.R que contiene la columna
# in_eez_outside_gulf con valores 0 y 1
eez_mask_grid_sf <- st_read(input_mask_gpkg_path, quiet = TRUE)

# Importa el shapefile de la Zona Económica Exclusiva de México
# para dibujar su contorno como referencia geográfica de la
# jurisdicción marítima mexicana
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México desde el
# GeoPackage generado por export_mexico_mpa_to_gpkg.R para
# mostrar el contexto de protección legal en el mapa
mexico_mpa_sf <- st_read(input_mpa_gpkg_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth
# a la escala indicada para usar como fondo de costa en el mapa
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Transforma la ZEE del CRS original del shapefile a coordenadas
# geográficas WGS84 para que coincida con el sistema de referencia
# de las demás capas y con los límites del bounding box
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Convierte la columna numérica in_eez_outside_gulf a caracter
# para que scale_fill_manual pueda mapear los valores discretos
# 0 y 1 a los colores gris y celeste respectivamente
eez_mask_grid_sf <- eez_mask_grid_sf |>
  mutate(
    mask_category = as.character(in_eez_outside_gulf)
  )

# Define los límites del mapa centrados en el Pacífico de la
# península de Baja California que cubren la ZEE del Pacífico
# mexicano donde se ubican las colonias de albatros de Laysan
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35

# Construye el mapa temático con cuatro capas espaciales que
# muestran la clasificación binaria de ZEE sobre la rejilla
# del KDE con contexto geográfico de costa, ZEE y AMP
plot_eez_mask <- ggplot() +

  # Capa base de costa mundial como referencia geográfica
  # regional para ubicar visualmente la extensión del mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de las celdas de la rejilla coloreadas según la
  # máscara binaria: celeste para dentro de ZEE fuera del
  # Golfo de California y gris azul-verdoso para fuera o
  # dentro del Golfo
  geom_sf(
    data = eez_mask_grid_sf,
    mapping = aes(fill = mask_category),
    color = NA
  ) +

  # Escala discreta de colores que asigna gris claro a las
  # celdas fuera de la ZEE (valor 0) y celeste a las celdas
  # dentro de la ZEE fuera del Golfo (valor 1), sin mostrar
  # leyenda porque el título y subtítulo explican los colores
  scale_fill_manual(
    values = c(
      "0" = mask_value_zero_fill_color,
      "1" = mask_value_one_fill_color
    ),
    guide = "none"
  ) +

  # Capa del contorno de la ZEE de México sin relleno para
  # verificar visualmente que el límite de las celdas celestes
  # coincida con la frontera marítima de la ZEE del Pacífico
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa del contorno de las Áreas Marinas Protegidas sin
  # relleno para mantener la consistencia visual con los mapas
  # de hot spot del segundo artículo del proyecto
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Limita la extensión del mapa al bounding box centrado en
  # el Pacífico de la península de Baja California donde se
  # ubican las colonias de albatros de Laysan del proyecto
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que enfatiza las capas espaciales sin
  # distracciones visuales innecesarias
  theme_minimal() +

  # Etiquetas del mapa en inglés con título descriptivo de
  # los colores de la máscara y subtítulo que explica el
  # significado de cada color en la clasificación binaria
  labs(
    title = "EEZ Mask Grid — Gulf of California Excluded",
    subtitle = paste0(
      "Gray: outside Pacific EEZ or inside GoC. ",
      "Blue: inside Pacific EEZ and outside GoC."
    ),
    x = "Longitude",
    y = "Latitude"
  )


# ==== SALIDA ====

# Exporta el mapa de la máscara binaria de ZEE como PNG con
# resolución de publicación para incluirlo en el reporte de
# resultados obsoletos del proyecto como referencia diagnóstica
ggsave(
  filename = output_figure_path,
  plot = plot_eez_mask,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
