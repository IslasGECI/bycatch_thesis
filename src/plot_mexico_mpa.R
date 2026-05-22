# ==========================================
# Título: Grafica las áreas marinas protegidas de México
#
# Contexto (Por qué):
# Las Áreas Marinas Protegidas (AMP) representan las zonas donde la
# actividad humana está regulada para proteger ecosistemas marinos.
# Visualizarlas permite identificar zonas de posible refugio para albatros.
#
# Descripción (Qué / Cómo):
# Lee un GeoPackage que contiene la diferencia espacial entre las Áreas
# Naturales Protegidas y el territorio mexicano, lo que resulta en las
# áreas marinas protegidas. Genera una figura estática con ggplot2 y
# la exporta como PNG.
#
# Entradas:
# data/processed/mexico_mpa.gpkg (capa: mexico_mpa)
#
# Salida:
# reports/figures/mexico_mpa.png
#
# Dependencias:
# glue
# sf
# tidyverse
#
# Notas:
# - glue() construye el texto del caption con información de la ruta del insumo
# - geom_sf() preserva la proyección original del objeto sf
# ==========================================


# ==== CONFIGURACIÓN ====
library(glue) # Proporciona glue() para interpolar variables en los mensajes del gráfico
library(sf) # Proporciona st_read para importar geometrías desde GeoPackage
library(tidyverse) # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del GeoPackage que contiene la diferencia espacial ANP − México
input_gpkg_path <- "data/processed/mexico_mpa.gpkg"
# Nombre de la capa dentro del GeoPackage que almacena la geometría de las AMP
input_layer_name <- "mexico_mpa"
# Ruta del archivo PNG de salida con el mapa de áreas marinas protegidas
output_figure_path <- "reports/figures/mexico_mpa.png"

# Colores para la visualización de las áreas marinas protegidas
fill_color <- "#9AD0EC" # Color de relleno que destaca las AMP en el mapa
line_color <- "#185ADB" # Color de contorno para definir los límites de las AMP
line_size <- 0.3 # Grosor de línea moderado para mantener legibilidad

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====
# Importa la capa espacial desde el GeoPackage generado previamente con
# la diferencia espacial entre las ANP y el territorio de México
mexico_mpa <- st_read(
  dsn = input_gpkg_path,
  layer = input_layer_name,
  quiet = TRUE
)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye un mapa sencillo que resalta la geometría de las áreas marinas
# protegidas resultante de la operación de diferencia espacial
plot_amp <- ggplot() +
  # Capa de la geometría de las AMP con colores definidos
  geom_sf(
    data = mexico_mpa,
    fill = fill_color,
    color = line_color,
    size = line_size
  ) +
  # Preserva la proyección geográfica original del objeto sf
  coord_sf() +
  # Estilo limpio que enfatiza la geometría espacial sin distracciones
  theme_minimal() +
  # Etiquetas descriptivas para identificar la capa y su origen
  labs(
    title = "Diferencia espacial ANP − México",
    subtitle = "Geometría resultante (ANP menos territorio de México)",
    caption = glue("Fuente: {input_gpkg_path} / capa: {input_layer_name}")
  )


# ==== SALIDA ====
# Exporta el mapa de áreas marinas protegidas como PNG para integrarse
# con el sistema de reportes del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_amp,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
