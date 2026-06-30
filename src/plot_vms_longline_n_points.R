# ==========================================
# Título: Grafica el conteo de puntos VMS de palangre por celda
#
# Contexto (Por qué):
# El GeoPackage con los z-scores de Getis-Ord Gi* contiene el conteo
# de puntos VMS de palangre por celda de la rejilla del KDE individual.
# El conteo abarca varios órdenes de magnitud (1 a 70 mil). Winsorizar
# el conteo en p5 y p95 elimina la cola inferior y recorta la cola
# superior para que la escala de color se concentre en el rango
# central donde ocurre la mayor parte de la actividad pesquera.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con el conteo de puntos VMS de palangre y los
# z-scores de Getis-Ord Gi* por celda. Lee la costa mundial, la ZEE
# de México y las áreas marinas protegidas como contexto geográfico.
# Filtra las celdas sin puntos VMS. Winsoriza el conteo en p5 y p95,
# re-filtra las celdas con valor cero tras la winsorización. Mapea
# el conteo winsorizado con paleta inferno y escala lineal. Construye
# el mapa con ggplot2 y lo exporta como PNG.
#
# Entradas:
# data/processed/vms_longline_hotspot.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/vms_longline_n_points_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - El bounding box hardcodeado cubre el Pacífico de la península de
#   Baja California donde se concentra el tráfico VMS
# - La ZEE se transforma de CEA a WGS84 para compatibilidad espacial
# - Solo se grafican celdas con al menos un punto VMS
# - La winsorización elimina celdas por debajo del percentil 5 y
#   recorta las celdas por encima del percentil 95
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
# las celdas de la rejilla sin puntos VMS

# Ruta del GeoPackage con el conteo de puntos VMS de palangre y los
# z-scores de Getis-Ord Gi* por celda, generado por
# src/compute_vms_by_gear_hotspot.R
input_vms_hotspot_gpkg_path <- "data/processed/vms_longline_hotspot.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que proporcionan contexto de conservación marina existente
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México para
# delimitar la jurisdicción marítima mexicana en el mapa
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG que almacenará el mapa del conteo de puntos
# VMS de palangre por celda para el reporte del segundo artículo
output_figure_path <- "reports/figures/vms_longline_n_points_map.png"

# Nombre de la columna que contiene el conteo de puntos VMS de
# palangre por celda en el GeoPackage de entrada
n_points_column_name <- "n_points_vms_longline"

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
# legibilidad en el mapa sin distraer de la capa principal de VMS
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Opción de la paleta secuencial perceptualmente uniforme para la
# escala continua del conteo de puntos VMS
viridis_option <- "inferno"

# Nombre de la leyenda de color que describe la escala de conteo
color_legend_name <- "Number of VMS longline points"

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte del segundo artículo
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la rejilla con el conteo de puntos VMS de palangre y los
# z-scores de Getis-Ord Gi* desde el GeoPackage generado por
# src/compute_vms_by_gear_hotspot.R; contiene la columna con el
# conteo crudo de puntos por celda
vms_hotspot_sf <- st_read(input_vms_hotspot_gpkg_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto espacial
# de las zonas de conservación marina en la región de estudio
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima donde ocurre la congestión VMS
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas donde al menos un
# punto VMS de palangre fue registrado; se omiten las celdas sin
# puntos que saturarían el mapa sin agregar información sobre la
# distribución espacial de la congestión de embarcaciones
grid_positive_sf <- vms_hotspot_sf |>
  filter(.data[[n_points_column_name]] > 0)

# Calcula los percentiles 5 y 95 del conteo de puntos VMS solo entre
# las celdas con al menos un punto para evitar que los ceros sesguen
# los umbrales de la winsorización
p5 <- quantile(grid_positive_sf[[n_points_column_name]], probs = 0.05)
p95 <- quantile(grid_positive_sf[[n_points_column_name]], probs = 0.95)

# Winsoriza el conteo de puntos: pisa los valores por debajo de p5
# con 0 y recorta los valores por encima de p95 al valor de p95;
# así la escala de color se concentra en el rango central 5-95%
grid_positive_sf <- grid_positive_sf |>
  mutate(
    !!n_points_column_name := case_when(
      .data[[n_points_column_name]] < p5 ~ 0,
      .data[[n_points_column_name]] > p95 ~ p95,
      TRUE ~ .data[[n_points_column_name]]
    )
  ) |>
  filter(.data[[n_points_column_name]] > 0)

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
# de Baja California donde se concentra el tráfico VMS de palangre en
# la ZEE del Pacífico mexicano
bbox_lon_min <- -125
bbox_lon_max <- -105
bbox_lat_min <- 15
bbox_lat_max <- 35

# Construye el mapa temático con las celdas de la rejilla coloreadas
# por el conteo de puntos VMS de palangre sobre la costa, la ZEE y
# las Áreas Marinas Protegidas como contexto geográfico regional
plot_vms_n_points <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # zonas de pesca de palangre en el Pacífico mexicano
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa principal de las celdas con al menos un punto VMS coloreadas
  # por el conteo winsorizado de puntos de palangre con escala lineal
  # que revela la congestión relativa en cada celda de la rejilla
  geom_sf(
    data = grid_positive_sf,
    mapping = aes(fill = .data[[n_points_column_name]]),
    color = NA
  ) +

  # Escala secuencial de color con paleta inferno que mapea el conteo
  # de puntos VMS winsorizado con escala lineal para revelar la
  # congestión relativa de embarcaciones en cada celda de la rejilla
  scale_fill_viridis_c(
    option = viridis_option,
    direction = -1,
    name = color_legend_name
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sobre las celdas de
  # congestión VMS en el Pacífico mexicano
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde sin
  # relleno para mostrar las zonas de conservación existentes en el
  # contexto de la congestión de embarcaciones pesqueras
  geom_sf(
    data = mexico_mpa_sf,
    fill = NA,
    color = mpa_line_color,
    linewidth = mpa_line_width
  ) +

  # Limita la extensión del mapa al bounding box hardcodeado que
  # cubre la región del Pacífico mexicano desde la península de Baja
  # California hasta las latitudes del tráfico VMS de palangre
  coord_sf(
    xlim = c(bbox_lon_min, bbox_lon_max),
    ylim = c(bbox_lat_min, bbox_lat_max),
    expand = FALSE
  ) +

  # Estilo limpio que elimina el fondo gris predeterminado y enfatiza
  # las capas espaciales del mapa sin distracciones visuales
  theme_minimal() +

  # Etiquetas del mapa en inglés para integrarse al reporte del
  # segundo artículo del proyecto sobre riesgo de captura incidental,
  # con el título que describe el conteo crudo de puntos VMS
  labs(
    title = "Number of VMS longline points per grid cell",
    subtitle = "Vessel Monitoring System — Pacific Mexico EEZ (2014–2025)",
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

# Exporta el mapa del conteo de puntos VMS de palangre por celda como
# PNG con resolución de publicación para incluirlo en el reporte del
# segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_vms_n_points,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
