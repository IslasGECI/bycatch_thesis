# ==========================================
# Título: Graficar las Áreas Naturales Protegidas de México
#
# Contexto (Por qué):
# Las Áreas Naturales Protegidas (ANP) son fundamentales para la
# conservación de especies marinas. Visualizarlas permite contextualizar
# las zonas de protección existentes en el territorio mexicano.
#
# Descripción (Qué / Cómo):
# El script carga el shapefile de ANP de México, lo convierte en un
# objeto sf y genera una figura estática utilizando ggplot2 que se
# guarda como archivo PNG.
#
# Entradas:
# data/external/232_ANP-ITRF08_04072025.shp
#
# Salidas:
# reports/figures/mexico_pna.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# El shapefile contiene 232 áreas naturales protegidas.
# Se utiliza el sistema de referencia ITRF08.
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
