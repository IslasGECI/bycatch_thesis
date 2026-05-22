# ==========================================
# Título: Grafica la zona económica exclusiva de México
#
# Contexto (Por qué):
# La Zona Económica Exclusiva (ZEE) define el espacio marítimo donde
# México posee derechos soberanos para la gestión de recursos marinos.
# Visualizar este polígono permite contextualizar análisis espaciales
# como distribución de biodiversidad o actividades pesqueras.
#
# Descripción (Qué / Cómo):
# Carga el shapefile de la ZEE de México, lo convierte en un objeto sf
# y genera una figura estática con ggplot2 que se exporta como PNG para
# su inclusión en reportes del proyecto.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salida:
# reports/figures/mexico_eez.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - Se utiliza geom_sf() para mantener la geometría original del shapefile
# - coord_sf() preserva la proyección geográfica del objeto sf
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf)         # Proporciona st_read para importar shapefiles como objetos Simple Features
library(tidyverse)  # Proporciona ggplot2 para construir gráficos declarativos

# Ruta del shapefile de la Zona Económica Exclusiva de México
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
# Ruta del archivo PNG que almacenará la figura de la ZEE
output_figure_path <- "reports/figures/mexico_eez.png"

# Colores para la visualización de la ZEE en el mapa
fill_color <- "#9AD0EC"    # Color de relleno que resalta la superficie marítima
line_color <- "#0C4A6E"    # Color del contorno para definir el límite de la ZEE
line_size <- 0.3           # Grosor del borde para visibilidad sin saturar el mapa

# Dimensiones y resolución de la figura de salida
fig_width <- 8             # Ancho en pulgadas consistente con otros mapas del proyecto
fig_height <- 6            # Alto en pulgadas que mantiene proporción cartográfica
fig_dpi <- 300             # Resolución adecuada para reportes y publicaciones


# ==== ENTRADAS ====
# Importa el shapefile de la ZEE como objeto sf para operaciones espaciales
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Construye una visualización simple que resalta la geometría de la ZEE
# usando ggplot2 con un enfoque declarativo y minimalista
plot_mexico_eez <- ggplot() +
  # Capa de la geometría de la ZEE con colores definidos en configuración
  geom_sf(
    data = mexico_eez_sf,
    fill = fill_color,
    color = line_color,
    linewidth = line_size
  ) +
  # Preserva la proyección geográfica original del objeto sf
  coord_sf() +
  # Estilo limpio que enfatiza la geometría espacial sin decoraciones
  theme_minimal() +
  # Etiquetas del mapa con la fuente de los datos espaciales
  labs(
    title = "Zona Económica Exclusiva de México",
    caption = "Geoportal: Zonas de Refugio Pesquero. TNC México"
  )


# ==== SALIDA ====
# Exporta la figura como PNG para mantener consistencia con otros
# mapas del proyecto y permitir su uso en reportes o publicaciones
ggsave(
  filename = output_figure_path,
  plot = plot_mexico_eez,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
