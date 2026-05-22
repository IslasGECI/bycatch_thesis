# ==========================================
# Título: Grafica el shapefile de México e islas
#
# Contexto (Por qué):
# Para contextualizar los análisis de movimiento de albatros, se necesita
# una visualización base del territorio mexicano que muestre tanto el
# territorio continental como las islas.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de México e islas en formato WGS84, lo convierte en
# un objeto sf y genera una figura estática con ggplot2 que se guarda
# como archivo PNG.
#
# Entradas:
# data/external/Mexico_e_islas_wgs84.shp
#
# Salida:
# reports/figures/mexico_map.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - El shapefile ya está en coordenadas WGS84 (EPSG:4326)
# - theme_minimal() mantiene la figura limpia y reproducible
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar shapefiles como objetos sf
library(tidyverse) # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del shapefile de México e islas en coordenadas geográficas WGS84
mexico_shapefile_path <- "data/external/Mexico_e_islas_wgs84.shp"
# Ruta del archivo PNG que almacenará el mapa base de México
mexico_figure_path <- "reports/figures/mexico_map.png"

# Colores y estilo del mapa base de México
fill_color <- "lightblue" # Color de relleno para el territorio mexicano
line_color <- "darkblue" # Color del contorno que delimita el territorio
line_size <- 0.3 # Grosor de línea fino para mantener legibilidad

# Dimensiones y resolución de la figura de salida
fig_width <- 8
fig_height <- 6
fig_dpi <- 300


# ==== ENTRADAS ====
# Importa el shapefile de México e islas como un objeto sf; el archivo
# ya está en coordenadas geográficas WGS84 (EPSG:4326)
shape_data <- st_read(mexico_shapefile_path)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye el mapa base de México con una capa de polígonos simple
# que muestra el territorio continental y las islas del país
plot <- ggplot() +
  # Capa de la geometría de México con colores definidos
  geom_sf(
    data = shape_data,
    fill = fill_color,
    color = line_color,
    size = line_size
  ) +
  # Estilo limpio que enfatiza la geometría espacial sin distracciones
  theme_minimal() +
  # Título descriptivo para el mapa base del proyecto
  labs(title = "México y sus islas")


# ==== SALIDA ====
# Exporta el mapa base como PNG para integrarse con el sistema de
# reportes del proyecto y servir como contexto geográfico de fondo
ggsave(
  filename = mexico_figure_path,
  plot = plot,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
