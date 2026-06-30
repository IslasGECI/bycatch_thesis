# ==========================================
# Título: Visualiza los registros GPS de albatros en la ZEE del Pacífico mexicano
#
# Contexto (Por qué):
# Los datos de seguimiento GPS de albatros permiten estudiar patrones de
# movimiento y áreas de alimentación. Visualizarlos en el contexto de la
# ZEE de México, la costa y las áreas marinas protegidas facilita la
# interpretación espacial y la verificación de la calidad de los datos
# de seguimiento.
#
# Descripción (Qué / Cómo):
# Lee el shapefile de la ZEE de México, los puntos GPS de albatros y
# las áreas marinas protegidas. Descarga la costa mundial desde Natural
# Earth. Transforma la ZEE a WGS84, convierte los puntos GPS a sf y
# genera un mapa con ggplot2 que superpone las capas de referencia
# geográfica. Exporta la figura como PNG para su uso en reportes.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
# data/processed/gps_albatross_all.csv
# data/processed/mexico_mpa.gpkg
#
# Salida:
# reports/figures/mexico_eez_bounding_box_zoom_out.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Las coordenadas GPS están en WGS84; la ZEE se transforma a EPSG:4326
# - Los colores distinguen las tres colonias de albatros de Laysan
# ==========================================


# ==== CONFIGURACIÓN ====

library(jsonlite)
# Proporciona fromJSON para leer el bounding box de configuración

library(rnaturalearth)
# Proporciona ne_countries() para descargar la línea de costa mundial
# como contexto geográfico base del mapa

library(rnaturalearthdata)
# Proporciona los datos cartográficos base de Natural Earth para la
# descarga de límites políticos mundiales

library(sf)
# Proporciona st_read, st_transform y st_as_sf para operaciones
# espaciales y transformación de coordenadas

library(tidyverse)
# Proporciona ggplot2 para construir el mapa, readr para importar
# los datos GPS tabulares y dplyr para manipulación de datos

# Rutas de archivos de entrada
input_gps_path <- "data/processed/gps_albatross_all.csv"
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
input_mpa_path <- "data/processed/mexico_mpa.gpkg"
bbox_config_path <- "data/processed/bounding_box.json"

# Ruta del archivo PNG de salida
output_figure_path <- "reports/figures/mexico_eez_bounding_box_zoom_out.png"

# Carga los límites del bounding box regional desde el archivo JSON
# para definir la extensión del mapa en la vista de zoom out
bbox_config <- fromJSON(bbox_config_path)
bbox_lon_min <- bbox_config$bbox$lon_min
bbox_lon_max <- bbox_config$bbox$lon_max
bbox_lat_min <- bbox_config$bbox$lat_min
bbox_lat_max <- bbox_config$bbox$lat_max

# Escala de la línea de costa mundial; "medium" balancea el detalle
# geográfico con la velocidad de descarga desde Natural Earth
coastline_scale <- "medium"

# Sistema de referencia espacial objetivo (WGS84, EPSG:4326) para
# reproyectar la ZEE desde su proyección CEA original y mantener
# compatibilidad con los datos GPS y las capas de referencia
target_crs <- 4326

# Colores para las capas de referencia geográfica del mapa
coast_fill_color <- "gray90"
coast_line_color <- "gray50"
eez_line_color <- "#1E3A8A"
mpa_line_color <- "#166534"

# Grosor de las líneas de las capas de referencia para mantener
# legibilidad en el mapa sin distraer de la capa principal de
# puntos GPS
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Colores para los puntos GPS según la isla de origen
color_guadalupe <- "#8ECFB0"
color_clarion <- "#C6B7E2"
color_san_benedicto <- "#F4A7A1"

# Tamaño y transparencia de los puntos GPS en el mapa
gps_point_size <- 0.3
gps_point_alpha <- 0.7

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima mexicana en el mapa
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto espacial
# de las zonas de conservación marina en la región de estudio
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa los registros GPS de albatros desde el archivo CSV consolidado
# con las coordenadas y la isla de origen de cada punto de seguimiento
gps_tracks <- read_csv(input_gps_path, show_col_types = FALSE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Transforma la ZEE de su proyección original CEA a coordenadas
# geográficas WGS84 para que coincida con el sistema de referencia de
# la costa, las AMP y los datos GPS de albatros
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(target_crs)

# Convierte los registros GPS de tabla a puntos espaciales sf usando
# las columnas de longitud y latitud como coordenadas geográficas en
# el sistema de referencia WGS84
gps_points_sf <- gps_tracks |>
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = target_crs,
    remove = FALSE
  )

# Desactiva la validación S2 para evitar errores por geometrías
# inválidas durante el graficado con geom_sf cuando el paquete s2
# encuentra geometrías complejas o anillos con orientación mixta
sf_use_s2(FALSE)

# Construye el mapa temático con las capas de contexto geográfico y
# los puntos GPS de albatros coloreados por isla de origen
plot_map <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # islas de las colonias de albatros en el mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sin ocultar los
  # puntos GPS que caen dentro de ella
  geom_sf(
    data = mexico_eez_wgs84,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde sin
  # relleno para mostrar las zonas de conservación existentes en el
  # contexto de los movimientos de albatros
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Capa de los puntos GPS de albatros coloreados por isla de origen
  # para distinguir visualmente las trayectorias de cada colonia
  geom_sf(
    data = gps_points_sf,
    aes(color = island_name),
    size = gps_point_size,
    alpha = gps_point_alpha
  ) +

  # Asigna colores distintivos a cada colonia de albatros usando una
  # paleta cualitativa que facilita la diferenciación visual entre
  # las tres islas de origen en el mapa
  scale_color_manual(
    values = c(
      "Guadalupe" = color_guadalupe,
      "Clarion" = color_clarion,
      "San Benedicto" = color_san_benedicto
    )
  ) +

  # Limita la extensión del mapa al bounding box regional que cubre
  # el Pacífico Norte desde las islas de las colonias de albatros
  # hasta las rutas de forrajeo de larga distancia
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que elimina el fondo gris predeterminado y enfatiza
  # las capas espaciales del mapa sin distracciones visuales
  theme_minimal() +

  # Etiquetas del mapa en inglés para integrarse al reporte del
  # proyecto sobre riesgo de captura incidental de albatros
  labs(
    title = "Laysan albatross GPS tracks",
    subtitle = "Guadalupe, Clarion and San Benedicto colonies",
    color = "Island",
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior del mapa y ajusta el
  # ancho de la leyenda de color para mejorar la legibilidad
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa de los puntos GPS de albatros sobre la costa, la
# ZEE y las Áreas Marinas Protegidas como PNG con resolución de
# publicación para incluirlo en el reporte del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_map,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
