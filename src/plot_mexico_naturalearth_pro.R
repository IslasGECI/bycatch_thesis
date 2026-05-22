# ==========================================
# Título: Grafica México usando Natural Earth con elementos cartográficos
#
# Contexto (Por qué):
# Para producir mapas profesionales es útil añadir elementos cartográficos
# como escala gráfica y flecha de norte. Este script extiende el mapa base
# de México con estos elementos utilizando ggspatial.
#
# Descripción (Qué / Cómo):
# Utiliza rnaturalearth para descargar los límites políticos de México en
# formato sf, genera una figura con ggplot2 que incluye escala, flecha de
# norte y un tema personalizado, y la exporta como PNG.
#
# Entradas:
# (ninguna: los datos se obtienen del paquete rnaturalearth)
#
# Salida:
# reports/figures/mexico_naturalearth_pro.png
#
# Dependencias:
# ggspatial
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Natural Earth proporciona datos cartográficos de dominio público
# - rnaturalearth facilita la descarga directa de geometrías a objetos sf
# - ggspatial añade escala y flecha de norte al mapa
# - coord_sf() establece los límites geográficos del mapa
# ==========================================


# ==== CONFIGURACIÓN ====
library(ggspatial) # Proporciona annotation_scale y annotation_north_arrow
library(rnaturalearth) # Proporciona ne_countries() para descargar límites políticos
library(rnaturalearthdata) # Proporciona los datos cartográficos base de Natural Earth
library(sf) # Proporciona la clase sf para manejar geometrías espaciales
library(tidyverse) # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del archivo PNG de salida con el mapa profesional de México
output_figure_path <- "reports/figures/mexico_naturalearth_pro.png"

# Colores para el mapa de México con estilo profesional
fill_color <- "antiquewhite" # Color de relleno claro para el territorio
line_color <- "gray30" # Color de contorno para los límites políticos
line_size <- 0.3 # Grosor de línea moderado

# Límites geográficos del mapa en coordenadas WGS84 (EPSG:4326)
map_xlim <- c(-118, -86) # Rango de longitud (oeste a este)
map_ylim <- c(12, 33) # Rango de latitud (sur a norte)

# Colores para los elementos decorativos del mapa
grid_line_color <- "gray50" # Color de las líneas de la cuadrícula
grid_line_type <- "dashed" # Estilo de línea punteada para la cuadrícula
grid_line_size <- 0.3 # Grosor de las líneas de la cuadrícula
panel_bg_color <- "aliceblue" # Color de fondo del panel del mapa
panel_border_color <- "gray30" # Color del borde del panel

# Estilo del título y subtítulo del mapa
title_size <- 14 # Tamaño de fuente del título principal
title_face <- "bold" # Negrita para el título principal
title_hjust <- 0.5 # Centrado horizontal del título
subtitle_size <- 10 # Tamaño de fuente del subtítulo
subtitle_hjust <- 0.5 # Centrado horizontal del subtítulo

# Posición de la escala gráfica y la flecha de norte
scale_location <- "bl" # Esquina inferior izquierda (bottom-left)
scale_width <- 0.5 # Proporción del ancho del mapa que ocupa la escala
north_location <- "br" # Esquina inferior derecha (bottom-right)
north_pad_x <- 0.5 # Margen horizontal de la flecha (pulgadas)
north_pad_y <- 0.5 # Margen vertical de la flecha (pulgadas)

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====
# Descarga los límites políticos de México desde Natural Earth usando el
# paquete rnaturalearth; returnclass = "sf" devuelve un objeto sf listo
# para graficar con ggplot2
mexico_sf <- ne_countries(country = "Mexico", returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye un mapa profesional de México con elementos cartográficos
# adicionales como escala gráfica y flecha de norte
plot_mexico <- ggplot(data = mexico_sf) +
  # Capa de la geometría de México con colores definidos
  geom_sf(
    fill = fill_color,
    color = line_color,
    size = line_size
  ) +
  # Barra de escala gráfica en la esquina inferior izquierda del mapa
  annotation_scale(
    location = scale_location,
    width_hint = scale_width
  ) +
  # Flecha indicadora del norte verdadero en la esquina inferior derecha
  annotation_north_arrow(
    location = north_location,
    which_north = "true",
    pad_x = unit(north_pad_x, "in"),
    pad_y = unit(north_pad_y, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  # Limita la extensión del mapa a la región de México sin márgenes
  coord_sf(
    xlim = map_xlim,
    ylim = map_ylim,
    expand = FALSE
  ) +
  # Etiquetas del mapa en español con título y subtítulo descriptivos
  labs(
    title = "México",
    subtitle = "Límites políticos obtenidos de Natural Earth",
    x = "Longitud",
    y = "Latitud"
  ) +
  # Personalización del tema con cuadrícula punteada y fondo claro
  theme(
    panel.grid.major = element_line(
      color = grid_line_color,
      linetype = grid_line_type,
      linewidth = grid_line_size
    ),
    panel.background = element_rect(fill = panel_bg_color),
    panel.border = element_rect(
      color = panel_border_color,
      fill = NA
    ),
    plot.title = element_text(
      hjust = title_hjust,
      size = title_size,
      face = title_face
    ),
    plot.subtitle = element_text(
      hjust = subtitle_hjust,
      size = subtitle_size
    )
  )


# ==== SALIDA ====
# Exporta el mapa profesional de México como PNG para integrarse con el
# sistema de reportes del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_mexico,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
