# ==========================================
# Título: Grafica los hot spots de palangre de GFW como mapa binario
#
# Contexto (Por qué):
# El mapa continuo de z-scores revela la gradación del
# estadístico Gi*, pero para una interpretación binaria de
# presencia o ausencia de hot spot se necesita una
# clasificación dicotómica basada en el umbral de 1.96.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con los z-scores de Getis-Ord Gi* por
# celda para los puntos de palangre de GFW. Filtra las celdas
# con al menos un punto de palangre para evitar saturar el
# mapa con celdas vacías. Clasifica cada celda como hot spot
# (z-score >= 1.96) o no hot spot (z-score < 1.96). Construye
# un mapa con ggplot2 usando naranja para hot spots y verde
# para no hot spots, y superpone la línea de costa mundial
# como contexto geográfico.
#
# Entradas:
# data/processed/gfw_longline_hotspot_all.gpkg
# data/processed/mexico_eez_bounding_box_zoom_in.json
#
# Salida:
# reports/figures/gfw_longline_hotspot_binary_map_all.png
#
# Dependencias:
# jsonlite
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Solo grafica celdas con al menos un punto de palangre
# - Hot spot definido como z-score >= 1.96 (p < 0.05 bilateral)
# - La paleta discreta usa naranja para hot spots y verde para
#   no hot spots, facilitando la interpretación binaria
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

# Ruta del GeoPackage con los z-scores de Getis-Ord Gi* para
# los puntos de palangre de GFW en la rejilla del KDE
input_gpkg_path <- "data/processed/gfw_longline_hotspot_all.gpkg"

# Ruta del archivo JSON con los límites del bounding box de zoom in para
# limitar la extensión del mapa a la región de la ZEE de México
input_bbox_json_path <- "data/processed/mexico_eez_bounding_box_zoom_in.json"

# Ruta del archivo PNG que almacenará el mapa binario de hot
# spots de palangre de GFW en el Pacífico mexicano
output_png_path <- "reports/figures/gfw_longline_hotspot_binary_map_all.png"

# Escala de la línea de costa mundial para el fondo del mapa
coastline_scale <- "medium"

# Umbral de z-score para identificar hot spots significativos
# 1.96 corresponde a p < 0.05 en una prueba bilateral
hot_spot_z_threshold <- 1.96

# Color naranja para las celdas clasificadas como hot spot
# (z-score >= 1.96) donde la presión pesquera se agrupa
# significativamente en el espacio
hot_spot_fill_color <- "#E67E22"

# Color verde para las celdas clasificadas como no hot spot
# (z-score < 1.96) donde la presión pesquera no muestra
# agrupación espacial significativa
non_hot_spot_fill_color <- "#2ECC71"

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
# el GeoPackage generado por src/compute_gfw_longline_hotspot.R
longline_hotspot_sf <- st_read(input_gpkg_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth
# para usarlos como fondo de costa en el mapa de hot spots de
# palangre en el Pacífico mexicano
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
# menos un punto de palangre de GFW y así evitar saturar la
# visualización con las celdas vacías que no aportan información
grid_nonzero <- longline_hotspot_sf |>
  filter(n_points_gfw_longline > 0) |>
  # Clasifica cada celda como hot spot o no hot spot según
  # el umbral de z-score >= 1.96 que corresponde a un nivel
  # de significancia del 95% en una prueba bilateral
  mutate(
    is_hot_spot = gi_star_z_score >= hot_spot_z_threshold
  )

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas durante el graficado con geom_sf
sf_use_s2(FALSE)

# Construye el mapa temático con las celdas coloreadas por
# la clasificación binaria de hot spot para resaltar las
# zonas de agrupación significativa de presión pesquera
hotspot_map <- ggplot() +

  # Capa base de costa mundial como referencia geográfica
  # para ubicar visualmente la región de estudio
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de las celdas con puntos de palangre coloreadas
  # según la clasificación binaria: naranja para hot spots
  # con agrupación significativa y verde para no hot spots
  # donde la presión pesquera no muestra patrón espacial
  geom_sf(
    data = grid_nonzero,
    mapping = aes(fill = is_hot_spot),
    color = NA
  ) +

  # Escala discreta de colores que asigna naranja a los hot
  # spots verdaderos y verde a los no hot spots, con etiquetas
  # descriptivas en español para la interpretación del mapa
  scale_fill_manual(
    values = c(
      "TRUE" = hot_spot_fill_color,
      "FALSE" = non_hot_spot_fill_color
    ),
    labels = c(
      "TRUE" = "Hot spot (z >= 1.96)",
      "FALSE" = "No hot spot (z < 1.96)"
    ),
    name = "Clasificación Gi*"
  ) +

  # Limita la extensión del mapa al bounding box de zoom in para
  # enfocar la visualización en la región de la ZEE de México
  # donde se concentran los puntos de palangre con congestión
  # significativa de eventos de pesca
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que enfatiza las capas espaciales
  theme_minimal() +

  # Etiquetas del mapa descriptivas del análisis binario de
  # hot spots para los eventos de palangre de Global Fishing
  # Watch en el Pacífico mexicano
  labs(
    title = "Hot spots de eventos de palangre de GFW",
    subtitle = "Clasificación binaria con umbral z >= 1.96",
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

# Exporta el mapa binario como PNG con resolución de publicación
# para su inclusión en reportes y presentaciones del proyecto de
# evaluación de riesgo de captura incidental de albatros
ggsave(
  filename = output_png_path,
  plot = hotspot_map,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
