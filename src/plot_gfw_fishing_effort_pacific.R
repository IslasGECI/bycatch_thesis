# ==========================================
# Título: Verifica la distribución espacial del esfuerzo pesquero de GFW filtrado
#
# Contexto (Por qué):
# El script de filtrado espacial retiene puntos dentro de la ZEE del
# Pacífico mexicano y fuera del Golfo de California. Generar un mapa
# de verificación permite confirmar visualmente que el filtro espacial
# funciona correctamente antes de proceder al conteo por celda.
#
# Descripción (Qué / Cómo):
# Lee el CSV filtrado de esfuerzo pesquero aparente de GFW con
# coordenadas Lat y Lon. Convierte cada fila a un punto geográfico.
# Lee la costa mundial, la ZEE de México y las áreas marinas
# protegidas como contexto geográfico. Mapea los puntos coloreados
# por horas de pesca aparente con paleta inferno y escala log1p.
# Exporta el mapa como PNG de verificación temporal.
#
# Entradas:
# data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/gfw_fishing_effort_pacific_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Script temporal de verificación; no se agrega al Makefile
# - El bounding box cubre el Pacífico mexicano completo
# ==========================================


# ==== CONFIGURACIÓN ====

library(rnaturalearth)
# Proporciona ne_countries() para descargar la línea de costa mundial
# como contexto geográfico base del mapa

library(rnaturalearthdata)
# Proporciona los datos cartográficos base de Natural Earth para la
# descarga de límites políticos mundiales

library(sf)
# Proporciona st_read para importar geometrías y st_transform para
# reproyectar la ZEE a WGS84

library(tidyverse)
# Proporciona ggplot2 para construir el mapa, dplyr para filtrar y
# readr para importar el CSV de esfuerzo pesquero

# Ruta del CSV filtrado de esfuerzo pesquero aparente de GFW que
# contiene coordenadas Lat y Lon por fila
input_gfw_fishing_effort_csv_path <- "data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG de salida para el mapa de verificación
output_figure_path <- "reports/figures/gfw_fishing_effort_pacific_map.png"

# Escala de la línea de costa mundial
coastline_scale <- "medium"

# Sistema de referencia espacial objetivo (WGS84)
target_crs <- 4326

# Colores para las capas de referencia geográfica del mapa
coast_fill_color <- "gray90"
coast_line_color <- "gray50"
eez_line_color <- "#1E3A8A"
mpa_line_color <- "#166534"

# Grosor de las líneas de las capas de referencia
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Opción de la paleta secuencial para la escala de horas de pesca
viridis_option <- "inferno"

# Nombre de la leyenda de color
color_legend_name <- "Apparent Fishing Hours"

# Tamaño y transparencia de los puntos de esfuerzo pesquero en el
# mapa para manejar la alta densidad de puntos sin saturación
fishing_point_size <- 0.5
fishing_point_alpha <- 0.6

# Dimensiones y resolución de la figura de salida
fig_width <- 10
fig_height <- 8
fig_dpi <- 150


# ==== ENTRADAS ====

# Lee el CSV filtrado de esfuerzo pesquero aparente de GFW que
# contiene las coordenadas de latitud y longitud por fila
gfw_fishing_effort_table <- read_csv(
  input_gfw_fishing_effort_csv_path,
  show_col_types = FALSE
)

# Importa las Áreas Marinas Protegidas de México como contexto
# de conservación marina en el mapa
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para delimitar la
# jurisdicción marítima mexicana
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth
# para usarlos como fondo de costa en el mapa
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra las filas con coordenadas completas para evitar errores
# de georreferenciación durante la conversión a objeto espacial
gfw_fishing_effort_clean <- gfw_fishing_effort_table |>
  filter(!is.na(Lat) & !is.na(Lon))

# Convierte la tabla de puntos de pesca a un objeto sf geográfico
# en WGS84 usando las columnas Lon y Lat como coordenadas
gfw_fishing_effort_sf <- st_as_sf(
  gfw_fishing_effort_clean,
  coords = c("Lon", "Lat"),
  crs = target_crs,
  remove = FALSE
)

# Transforma la ZEE de su proyección original a coordenadas
# geográficas WGS84 para compatibilidad con los demás datos
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Desactiva la validación S2 para evitar errores por geometrías
# complejas durante el graficado con geom_sf
sf_use_s2(FALSE)

# Define los límites del mapa centrados en el Pacífico mexicano
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35

# Construye el mapa de verificación con los puntos de esfuerzo
# pesquero coloreados por horas de pesca aparente sobre la costa,
# la ZEE y las AMP como contexto geográfico regional
plot_gfw_effort <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # zonas de pesca en el Pacífico mexicano
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sin ocultar los
  # puntos de esfuerzo pesquero que caen dentro de ella
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde
  # sin relleno para mostrar las zonas de conservación existentes
  # en el contexto de la distribución de esfuerzo pesquero
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Capa principal de los puntos de esfuerzo pesquero coloreados
  # por horas de pesca aparente con paleta inferno; se ubica como
  # la capa superior para verificar visualmente el filtrado espacial
  geom_sf(
    data = gfw_fishing_effort_sf,
    aes(color = `Apparent Fishing Hours`),
    size = fishing_point_size,
    alpha = fishing_point_alpha
  ) +

  # Escala secuencial de color con paleta inferno y transformación
  # log1p para comprimir la cola superior de horas de pesca
  scale_color_viridis_c(
    option = viridis_option,
    direction = -1,
    trans = "log1p",
    name = color_legend_name
  ) +

  # Limita la extensión del mapa al bounding box del Pacífico
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que enfatiza las capas espaciales del mapa
  theme_minimal() +

  # Etiquetas del mapa para la verificación del filtrado
  labs(
    title = "GFW apparent fishing effort — Pacific Mexico EEZ",
    subtitle = paste(nrow(gfw_fishing_effort_sf), "points after spatial filter"),
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior del mapa
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa de verificación como PNG temporal para confirmar
# que el filtrado espacial retiene correctamente los puntos del
# Pacífico mexicano
ggsave(
  filename = output_figure_path,
  plot = plot_gfw_effort,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
