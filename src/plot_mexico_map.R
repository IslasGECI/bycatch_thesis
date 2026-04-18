# ==========================================
# Título: Graficar el Shapefile de México e Islas
#
# Contexto (Por qué):
# Para contextualizar los análisis de movimiento de albatros, es útil
# contar con una visualización base del territorio mexicano que muestre
# tanto el territorio continental como las islas.
#
# Descripción (Qué / Cómo):
# El script carga el shapefile de México e islas en formato WGS84,
# lo convierte en un objeto sf y genera una figura estática utilizando
# ggplot2 que se guarda como archivo PNG.
#
# Entradas:
# data/external/Mexico_e_islas_wgs84.shp
#
# Salidas:
# reports/figures/mexico_map.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# El shapefile ya está en coordenadas WGS84 (EPSG:4326).
# Se utiliza theme_minimal() para mantener la figura limpia.
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para manejar datos espaciales como Simple Features
library(tidyverse)  # Para manipulación de datos y visualización con ggplot2

# ==== CONFIGURACIÓN ====
mexico_shapefile_path <- "data/external/Mexico_e_islas_wgs84.shp" # Ruta al shapefile
mexico_figure_path <- "reports/figures/mexico_map.png" # Nombre del archivo con la figura

# ==== IMPORTAR Y PREPARAR DATOS ====
shape_data <- st_read(mexico_shapefile_path)

# ==== VISUALIZACIÓN DEL SHAPEFILE ====
plot <- ggplot() +
  geom_sf(data = shape_data, fill = "lightblue", color = "darkblue", size = 0.3) +
  theme_minimal() +
  labs(
    title = "México y sus islas"
  )

# ==== GUARDAR SALIDA ====
# Guarda el gráfico con buena resolución en la carpeta 'outputs'
ggsave(
  filename = mexico_figure_path,
  plot = plot,
  width = 8,
  height = 6,
  dpi = 300
)
