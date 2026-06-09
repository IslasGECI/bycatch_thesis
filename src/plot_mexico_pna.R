# ==========================================
# Título: Grafica las áreas naturales protegidas de México
#
# Contexto (Por qué):
# Las Áreas Naturales Protegidas (ANP) son fundamentales para la
# conservación de especies marinas. Visualizarlas permite contextualizar
# las zonas de protección existentes en el territorio mexicano.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de ANP de México, lo convierte en un objeto sf y
# genera una figura estática con ggplot2 que se guarda como PNG.
#
# Entradas:
# data/external/232_ANP-ITRF08_04072025.shp
#
# Salida:
# reports/figures/mexico_pna.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - El shapefile contiene 232 áreas naturales protegidas
# - El sistema de referencia del insumo es ITRF08
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar shapefiles como objetos sf
library(tidyverse) # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del shapefile de Áreas Naturales Protegidas de México en formato ITRF08
pna_shapefile_path <- "data/external/232_ANP-ITRF08_04072025.shp"
# Ruta del archivo PNG que almacenará el mapa de las ANP
pna_figure_path <- "reports/figures/mexico_pna.png"

# Colores para la visualización de las áreas naturales protegidas
fill_color <- "lightblue" # Color de relleno para las ANP en el mapa
line_color <- "darkblue" # Color de contorno que delimita cada ANP
line_size <- 0.3 # Grosor de línea fino para mantener legibilidad

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====
# Importa el shapefile de Áreas Naturales Protegidas como un objeto sf;
# el archivo contiene 232 polígonos en el sistema de referencia ITRF08
shape_data <- st_read(pna_shapefile_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye el mapa de las Áreas Naturales Protegidas con una capa de
# polígonos que muestra la distribución espacial de las ANP en México
plot <- ggplot() +
  # Capa de la geometría de las ANP con colores definidos
  geom_sf(
    data = shape_data,
    fill = fill_color,
    color = line_color,
    size = line_size
  ) +
  # Estilo limpio que enfatiza la geometría espacial sin distracciones
  theme_minimal() +
  # Etiquetas descriptivas con título, subtítulo y fuente de los datos
  labs(
    title = "232 Áreas Naturales Protegidas en México",
    subtitle = "Fecha del shapefile: julio 2025",
    caption = paste0(
      "Información espacial de las Áreas Naturales Protegidas: ",
      "https://sig.conanp.gob.mx/"
    )
  )


# ==== SALIDA ====
# Exporta el mapa de las ANP como PNG para integrarse con el sistema
# de reportes del proyecto
ggsave(
  filename = pna_figure_path,
  plot = plot,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
