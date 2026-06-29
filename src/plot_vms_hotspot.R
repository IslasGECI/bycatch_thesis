# ==========================================
# Título: Grafica los hot spots de congestión VMS
#
# Contexto (Por qué):
# Los z-scores de Getis-Ord Gi* miden la intensidad de
# congestión de embarcaciones pesqueras en cada celda.
# Visualizar la gradación espacial del estadístico permite
# interpretar dónde se concentra el tráfico VMS.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con los z-scores de Getis-Ord Gi* por
# celda. Filtra las celdas con al menos un punto VMS para
# evitar saturar el mapa con 213 mil celdas vacías. Mapea
# el z-score con escala log1p y paleta inferno para revelar
# la gradación en valores cercanos a cero y comprimir la cola
# superior. Superpone la línea de costa mundial como contexto
# geográfico. Exporta el mapa como PNG.
#
# Entradas:
# data/processed/vms_hotspot.gpkg
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/vms_hotspot_map.png
#
# Dependencias:
# tidyverse
# jsonlite
# rnaturalearth
# rnaturalearthdata
# sf
#
# Notas:
# - Solo grafica celdas con al menos un punto VMS (>213 mil
#   celdas vacías se omiten para mantener el mapa legible)
# - La escala de color usa log1p para comprimir la cola superior;
#   la leyenda muestra los valores en la escala original sin
#   mencionar la transformación
# - Los breaks de la leyenda incluyen 0.5, 1 y 2 como referencias
#   cercanas al umbral de significancia de z = 1.96
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta tidyverse para las funciones de manipulación de datos
# y construcción de gráficos del ecosistema tidyverse
library(tidyverse)

# Adjunta jsonlite para leer el bounding box de zoom in
library(jsonlite)

# Adjunta sf para leer el GeoPackage con los resultados THS
library(sf)

# Adjunta rnaturalearth para descargar la línea de costa mundial
library(rnaturalearth)

# Adjunta rnaturalearthdata para los datos cartográficos base
library(rnaturalearthdata)

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi*
input_gpkg_path <- "data/processed/vms_hotspot.gpkg"

# Ruta del archivo JSON con los límites del bounding box de zoom in para
# limitar la extensión del mapa a la región de la ZEE de México
input_bbox_json_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

# Ruta del archivo PNG que almacenará el mapa de hot spots
output_png_path <- "reports/figures/vms_hotspot_map.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"

# Opción de la paleta secuencial inferno para la escala de z-score
# 'inferno' ofrece una gradación oscuro→brillante perceptualmente
# uniforme que revela la continuidad del estadístico Getis-Ord Gi*
viridis_option <- "inferno"

# Nombre de la leyenda de color que describe el estadístico
# Getis-Ord Gi* sin mencionar la transformación log1p
color_legend_name <- "Getis-Ord Gi* z-score"

# Valores de la leyenda en la escala original que servirán como
# puntos de referencia para interpretar la intensidad del patrón
# espacial de congestión VMS; incluye 0.5, 1 y 2 cercanos al
# umbral de significancia de z = 1.96
legend_breaks <- c(0, 0.5, 1, 2, 5, 10, 50, 200)

# Color de relleno para la línea de costa mundial
coast_fill_color <- "gray90"

# Color del contorno de la línea de costa mundial
coast_line_color <- "gray50"

# Grosor de la línea de costa mundial
coast_line_width <- 0.2

# Dimensiones y resolución de la figura de salida
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la rejilla con los z-scores de Getis-Ord Gi* desde
# el GeoPackage generado por src/compute_vms_hotspot.R
vms_hotspot_sf <- st_read(input_gpkg_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth
# para usarlos como fondo de costa en el mapa de hot spots
world_coastline_sf <- ne_countries(
  scale = coastline_scale,
  returnclass = "sf"
)

# Carga los límites del bounding box de zoom in desde el archivo JSON
# para limitar la extensión del mapa a la región de la ZEE de México
bbox_config <- fromJSON(input_bbox_json_path)

# Extrae la longitud oeste del bounding box de zoom in
bbox_lon_min <- bbox_config$bbox$lon_min

# Extrae la longitud este del bounding box de zoom in
bbox_lon_max <- bbox_config$bbox$lon_max

# Extrae la latitud sur del bounding box de zoom in
bbox_lat_min <- bbox_config$bbox$lat_min

# Extrae la latitud norte del bounding box de zoom in
bbox_lat_max <- bbox_config$bbox$lat_max


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas con al
# menos un punto VMS y así evitar saturar la visualización
# con las 213 mil celdas vacías que no aportan información;
# la transformación log1p se aplica internamente en la escala
# de color para no requerir una columna precalculada
grid_nonzero <- vms_hotspot_sf |>
  filter(n_points_vms > 0)

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas durante el graficado con geom_sf
sf_use_s2(FALSE)

# Construye el mapa temático con las celdas coloreadas por
# el z-score con escala log1p para revelar la gradación
# espacial del estadístico Getis-Ord Gi* en toda su distribución
hotspot_map <- ggplot() +

  # Capa base de costa mundial como referencia geográfica
  # para ubicar visualmente la región de estudio
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de las celdas con puntos VMS coloreadas por el
  # z-score original; la escala aplica log1p internamente
  # para comprimir la cola superior y expandir la variación
  # en valores cercanos a cero sin modificar el dato original
  geom_sf(
    data = grid_nonzero,
    mapping = aes(fill = gi_star_z_score),
    color = NA
  ) +

  # Escala secuencial de color con paleta inferno que mapea
  # los z-scores transformados internamente con log1p para
  # comprimir la cola superior; los breaks y etiquetas se
  # muestran en la escala original sin mencionar la transformación
  scale_fill_viridis_c(
    option = "inferno",
    direction = -1,
    trans = "log1p",
    breaks = legend_breaks,
    name = color_legend_name
  ) +

  # Limita la extensión del mapa al bounding box de zoom in para
  # enfocar la visualización en la región de la ZEE de México
  # donde se concentran los puntos VMS con congestión significativa
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que enfatiza las capas espaciales
  theme_minimal() +

  # Etiquetas del mapa descriptivas del análisis THS
  labs(
    title = "Hot spots de congestión de embarcaciones pesqueras",
    subtitle = "Getis-Ord Gi* sobre datos VMS de 2014 a 2025 en el Pacífico Mexicano",
    x = "Longitud",
    y = "Latitud"
  ) +

  # Posiciona la leyenda en la parte inferior derecha para
  # no obstruir la visualización de las celdas en el mapa
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa como PNG con resolución de publicación para
# su inclusión en reportes y presentaciones del proyecto
ggsave(
  filename = output_png_path,
  plot = hotspot_map,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
