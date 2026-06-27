# ==========================================
# Título: Grafica el índice conjunto albatros-palangre-arrastre (UDOI) por celda de la rejilla KDE
#
# Contexto (Por qué):
# El índice UDOI combina la concentración de albatros (N_IND) con la
# intensidad de pesca de palangre y arrastre (n_points) en un producto
# normalizado que es alto solo donde ambas variables coinciden.
# Visualizar este índice revela las zonas de riesgo de captura
# incidental para la pesca combinada.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con el producto normalizado UDOI por celda de la
# rejilla KDE generado por export_ud_vms_longline_trawler_udoi.R. Lee
# el JSON con el valor del índice UDOI. Lee la costa mundial, la ZEE
# de México y las áreas marinas protegidas como contexto geográfico.
# Filtra las celdas sin coincidencia albatros-pesca para evitar
# saturar el mapa. Mapea UDOI con la paleta inferno. Construye el
# mapa con ggplot2 y lo exporta como PNG.
#
# Entradas:
# data/processed/ud_vms_longline_trawler_udoi.gpkg
# data/processed/longline_trawler_udoi.json
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/ud_vms_longline_trawler_udoi_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
# jsonlite
#
# Notas:
# - Solo 1833 celdas tienen udoi_value mayor que cero
# - El bounding box hardcodeado cubre el Pacífico de la península de
#   Baja California donde se ubican las colonias de albatros
# - La ZEE se transforma de CEA a WGS84 para compatibilidad espacial
# - El título incluye el UDOI desde data/processed/longline_trawler_udoi.json
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
# las celdas de la rejilla sin coincidencia albatros-pesca

library(jsonlite)
# Proporciona fromJSON para leer el valor del índice UDOI desde el
# archivo JSON generado por src/compute_longline_trawler_udoi.R

# Ruta del GeoPackage con el índice conjunto UDOI por celda generado
# por export_ud_vms_longline_trawler_udoi.R como medida de riesgo
# conjunto para palangre y arrastre
input_udoi_gpkg_path <- "data/processed/ud_vms_longline_trawler_udoi.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que proporcionan contexto de conservación marina existente
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México para
# delimitar la jurisdicción marítima mexicana en el mapa
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo JSON con las estadísticas del índice UDOI generado
# por src/compute_longline_trawler_udoi.R para mostrar el valor
# calculado en el título
input_udoi_json_path <- "data/processed/longline_trawler_udoi.json"

# Ruta del archivo PNG que almacenará el mapa del índice UDOI por
# celda en la rejilla KDE para el reporte del segundo artículo
output_figure_path <- "reports/figures/ud_vms_longline_trawler_udoi_map.png"

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
# legibilidad en el mapa sin distraer de la capa principal de UDOI
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Opción de la paleta secuencial perceptualmente uniforme para la
# escala continua de UDOI que ofrece buena discriminación visual
viridis_option <- "inferno"

# Nombre de la leyenda de color que describe la escala del índice
# conjunto albatros-palangre-arrastre (UDOI) en valores crudos sin
# transformar
color_legend_name <- "UDOI"

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte del segundo artículo
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la rejilla KDE con el índice conjunto UDOI por celda desde
# el GeoPackage generado por src/export_ud_vms_longline_trawler_udoi.R;
# contiene el producto normalizado de albatros con la suma de palangre
# y arrastre por celda
udoi_grid_sf <- st_read(input_udoi_gpkg_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto espacial
# de las zonas de conservación marina en la región de estudio
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima donde ocurre el riesgo de captura incidental
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")

# Importa las estadísticas del índice UDOI desde el archivo JSON para
# extraer el valor calculado del índice de solapamiento conjunto
udoi_stats <- fromJSON(input_udoi_json_path)


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas donde el índice
# UDOI es mayor que cero; se omiten 213 mil celdas sin coincidencia
# entre albatros y pesca que saturarían el mapa sin información
udoi_positive_sf <- udoi_grid_sf |>
  filter(udoi_value > 0)

# Transforma la ZEE de su proyección original CEA a coordenadas
# geográficas WGS84 para que coincida con el sistema de referencia de
# la costa, las AMP y el bounding box hardcodeado del mapa
mexico_eez_wgs84_sf <- mexico_eez_sf |>
  st_transform(target_crs)

# Extrae el valor del índice UDOI desde las estadísticas importadas
# y lo redondea a entero para mostrarlo como porcentaje en el título
udoi_percentage <- round(udoi_stats$udoi * 100)

# Construye el título del mapa con el valor calculado del UDOI como
# porcentaje redondeado para informar al lector del índice conjunto
udoi_title <- paste0(
  "Albatross-longline-trawler overlap index (UDOI = ", udoi_percentage, "%)"
)

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
# coloreadas por el índice UDOI sobre la costa, la ZEE y las
# Áreas Marinas Protegidas como contexto geográfico regional
plot_udoi_grid <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # islas de las colonias de albatros en el mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa principal de las celdas con índice UDOI positivo coloreadas
  # por el valor del producto normalizado de albatros con la suma de
  # palangre y arrastre que indica zonas de riesgo conjunto
  geom_sf(
    data = udoi_positive_sf,
    mapping = aes(fill = udoi_value),
    color = NA
  ) +

  # Escala secuencial de color con paleta inferno que mapea UDOI
  # desde valores bajos en tonos oscuros hasta valores altos en tonos
  # brillantes para revelar la gradación del riesgo conjunto en las
  # celdas donde coinciden albatros y pesca
  scale_fill_viridis_c(
    option = viridis_option,
    direction = -1,
    name = color_legend_name
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sobre las celdas de
  # riesgo conjunto de albatros y pesca en el Pacífico mexicano
  geom_sf(
    data = mexico_eez_wgs84_sf,
    fill = NA,
    color = eez_line_color,
    linewidth = eez_line_width
  ) +

  # Capa de las Áreas Marinas Protegidas solo con contorno verde sin
  # relleno para mostrar las zonas de conservación existentes en el
  # contexto del riesgo de captura incidental de albatros
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

  # Etiquetas del mapa en inglés con el valor calculado del índice
  # UDOI en el título para informar al lector del solapamiento conjunto
  labs(
    title = udoi_title,
    subtitle = "Laysan Albatross — Guadalupe, Clarion and San Benedicto islands",
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior del mapa y ajusta el
  # ancho de la barra de color para mejorar la legibilidad de los
  # valores del índice UDOI en la escala continua
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa del índice conjunto albatros-palangre-arrastre por
# celda de la rejilla KDE como PNG con resolución de publicación para
# incluirlo en el reporte del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_udoi_grid,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
