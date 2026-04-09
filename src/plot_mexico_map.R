# ==========================================
# Propósito: Cargar y graficar el shapefile
#           Mexico_e_islas_wgs84.shp
# Entradas: Archivo shapefile en data/external/
# Salidas: Visualización geográfica del shapefile
# Dependencias: sf, tidyverse
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
