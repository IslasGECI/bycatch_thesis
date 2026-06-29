# ==========================================
# Título: Grafica la clasificación por percentiles del índice UDOI combinado
#
# Contexto (Por qué):
# El índice UDOI combinado de albatros-palangre-arrastre está
# discretizado en cuatro clases por percentiles. Visualizar las clases
# revela la gradación del riesgo de captura incidental de forma
# inmediata sin necesidad de interpretar una escala continua.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage con la clasificación UDOI por celda de la rejilla
# KDE generado por export_ud_vms_all_gear_class.R. Lee la
# costa mundial, la ZEE de México y las áreas marinas protegidas como
# contexto geográfico. Filtra las celdas sin solapamiento para no
# saturar el mapa. Mapea las clases 1 a 4 con una escala discreta
# verde‑amarillo‑naranja‑rojo. Construye el mapa con ggplot2 y lo
# exporta como PNG.
#
# Entradas:
# data/processed/ud_vms_all_gear_class.gpkg
# data/processed/mexico_mpa.gpkg
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/ud_vms_all_gear_classification_map.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Las clases 1 a 4 representan los cuatro niveles de riesgo por percentiles de UDOI > 0
# - La clase 0 se omite del mapa porque representa 99 % de las celdas
# - Los colores siguen la secuencia verde (bajo) a rojo (alto)
# - No se necesita archivo JSON porque el título es estático
# ==========================================


# ==== CONFIGURACIÓN ====

# Adjunta rnaturalearth para descargar la línea de costa mundial
# como contexto geográfico base del mapa desde Natural Earth
library(rnaturalearth)

# Adjunta rnaturalearthdata para acceder a los datos cartográficos
# base de límites políticos mundiales predescargados
library(rnaturalearthdata)

# Adjunta sf para importar geometrías desde GeoPackage y shapefile,
# y para reproyectar la ZEE de CEA a coordenadas geográficas WGS84
library(sf)

# Adjunta tidyverse para ggplot2 (construcción del mapa), dplyr
# (filtrado de celdas) y forcats (manejo de factores discretos)
library(tidyverse)

# Ruta del GeoPackage con la clasificación por percentiles del índice
# UDOI combinado generado por export_ud_vms_all_gear_class.R
input_class_gpkg_path <- "data/processed/ud_vms_all_gear_class.gpkg"

# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
# que proporcionan contexto de conservación marina existente
input_mpa_path <- "data/processed/mexico_mpa.gpkg"

# Ruta del shapefile de la Zona Económica Exclusiva de México para
# delimitar la jurisdicción marítima mexicana en el mapa
input_eez_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"

# Ruta del archivo PNG que almacenará el mapa de clasificación por
# percentiles para el reporte del segundo artículo
output_figure_path <- "reports/figures/ud_vms_all_gear_classification_map.png"

# Escala de la línea de costa mundial; "medium" balancea el detalle
# geográfico con la velocidad de descarga desde Natural Earth
coastline_scale <- "medium"

# Sistema de referencia espacial objetivo (WGS84, EPSG:4326) para
# reproyectar la ZEE y mantener compatibilidad con los demás datos
target_crs <- 4326

# Colores para las capas de referencia geográfica del mapa
coast_fill_color <- "gray90"
coast_line_color <- "gray50"
eez_line_color <- "#1E3A8A"
mpa_line_color <- "#166534"

# Grosor de las líneas de las capas de referencia para mantener la
# legibilidad sin distraer de la capa principal de clasificación
coast_line_width <- 0.2
eez_line_width <- 0.3
mpa_line_width <- 0.3

# Mapeo de cada clase a un color y una etiqueta en la leyenda para
# la escala discreta de riesgo que sigue la convención de semáforo
# donde el verde indica riesgo mínimo y el rojo riesgo máximo
class_colors <- c("1" = "green", "2" = "yellow", "3" = "orange", "4" = "red")

# Etiquetas descriptivas de cada clase para la leyenda del mapa que
# explican el nivel de riesgo de cada percentil de manera intuitiva
class_labels <- c("Minimal", "Low", "Medium", "High")

# Nombre de la leyenda de color que describe la escala discreta de
# riesgo de captura incidental por percentil del índice UDOI
legend_title <- "Risk level"

# Dimensiones y resolución de la figura de salida en ppp (puntos por
# pulgada) para publicación en el reporte del segundo artículo
fig_width <- 10
fig_height <- 8
fig_dpi <- 300


# ==== ENTRADAS ====

# Importa la rejilla KDE con la clasificación por percentiles desde el
# GeoPackage generado por export_ud_vms_all_gear_class.R que
# contiene la columna entera udoi_class con valores de 0 a 4
class_grid_sf <- st_read(input_class_gpkg_path, quiet = TRUE)

# Importa las Áreas Marinas Protegidas de México como contexto
# espacial de las zonas de conservación marina en la región
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)

# Importa el shapefile de la ZEE de México para contextualizar la
# jurisdicción marítima donde ocurre el riesgo de captura incidental
mexico_eez_sf <- st_read(input_eez_shapefile_path, quiet = TRUE)

# Descarga los límites políticos mundiales desde Natural Earth para
# usarlos como fondo de costa en el mapa de la región de estudio
world_coastline_sf <- ne_countries(scale = coastline_scale, returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====

# Filtra la rejilla para conservar solo las celdas con clase mayor a
# cero porque las 213 mil celdas sin solapamiento saturarían el mapa
# sin agregar información sobre la gradación del riesgo por percentil
class_positive_sf <- class_grid_sf |>
  filter(udoi_class > 0)

# Convierte la columna udoi_class de entero a factor para que ggplot2
# la trate como escala discreta en lugar de continua y así usar
# scale_fill_manual con colores y etiquetas fijas por categoría
class_positive_sf <- class_positive_sf |>
  mutate(udoi_class = factor(udoi_class))

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
# coloreadas por la clase de percentil sobre la costa, la ZEE y las
# Áreas Marinas Protegidas como contexto geográfico regional
plot_classification_grid <- ggplot() +

  # Capa base de costa mundial como referencia geográfica regional
  # para ubicar visualmente la península de Baja California y las
  # islas de las colonias de albatros en el mapa
  geom_sf(
    data = world_coastline_sf,
    fill = coast_fill_color,
    color = coast_line_color,
    linewidth = coast_line_width
  ) +

  # Capa principal de las celdas con udoi_class positivo coloreadas
  # por el percentil al que pertenecen para mostrar la distribución
  # espacial del riesgo de captura incidental en la ZEE
  geom_sf(
    data = class_positive_sf,
    mapping = aes(fill = udoi_class),
    color = NA
  ) +

  # Escala discreta de color con verde, amarillo, naranja y rojo que
  # mapea las cuatro clases por percentil del índice UDOI de menor a
  # mayor riesgo para una interpretación intuitiva del mapa
  scale_fill_manual(
    values = class_colors,
    labels = class_labels,
    name = legend_title
  ) +

  # Capa de la ZEE de México solo con contorno sin relleno para
  # delimitar la jurisdicción marítima mexicana sobre las celdas de
  # riesgo de captura incidental en el Pacífico mexicano
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

  # Etiquetas del mapa en inglés con título estático que describe el
  # contenido del mapa sin depender de un archivo JSON externo
  labs(
    title = "Albatross bycatch risk class per KDE grid cell",
    subtitle = "Laysan Albatross — Guadalupe, Clarion and San Benedicto islands",
    x = "Longitude",
    y = "Latitude"
  ) +

  # Posiciona la leyenda en la parte inferior del mapa y ajusta el
  # espaciado entre elementos de la leyenda discreta para mejorar la
  # legibilidad de las cuatro categorías de riesgo de captura
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm")
  )


# ==== SALIDA ====

# Exporta el mapa de clasificación por percentiles del índice UDOI
# combinado como PNG con resolución de publicación para incluirlo en
# el reporte del segundo artículo del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_classification_grid,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
