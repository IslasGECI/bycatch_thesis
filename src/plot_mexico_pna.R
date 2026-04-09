# ==========================================
# Propósito: Cargar y graficar el shapefile
#           232_ANP-ITRF08_04072025.shp
# Entradas: Archivo shapefile en data/external/
# Salidas: Visualización geográfica del shapefile
# Dependencias: sf, tidyverse
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para manejar datos espaciales como Simple Features
library(tidyverse)  # Para manipulación de datos y visualización con ggplot2

# ==== CONFIGURACIÓN ====
pna_shapefile_path <- "data/external/232_ANP-ITRF08_04072025.shp"  # Ruta al shapefile
pna_figure_path <- "reports/figures/mexico_pna.png" # Nombre del archivo con la figura

# ==== IMPORTAR Y PREPARAR DATOS ====
shape_data <- st_read(pna_shapefile_path)

# ==== VISUALIZACIÓN DEL SHAPEFILE ====
plot <- ggplot() +
  geom_sf(data = shape_data, fill = "lightblue", color = "darkblue", size = 0.3) +
  theme_minimal() +
  labs(
    title = "232 Áreas Naturales Protegidas en México",
    subtitle = "Fecha del Shapefile: Julio 2025",
    caption = "Información Espacial de las Áreas Naturales Protegidas: https://sig.conanp.gob.mx/"
  )

# ==== GUARDAR SALIDA ====
# Guarda el gráfico
ggsave(
  filename = pna_figure_path,
  plot = plot,
  width = 8,
  height = 6,
  dpi = 300
)
