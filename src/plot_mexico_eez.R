# ==========================================
# Título: Graficar la Zona Económica Exclusiva de México
#
# Contexto (Por qué):
# La Zona Económica Exclusiva (ZEE) define el espacio marítimo donde
# México posee derechos soberanos para la exploración, explotación
# y gestión de recursos marines. Visualizar este polígono permite
# contextualizar análisis espaciales como distribución de biodiversidad,
# áreas protegidas o actividades pesqueras.
#
# Descripción (Qué / Cómo):
# El script carga el shapefile de la ZEE de México, lo convierte
# en un objeto sf y genera una figura estática utilizando ggplot2
# que se guarda como archivo PNG.
#
# Entradas:
# data/external/Exclusive_economic_zone_Mexico.shp
#
# Salidas:
# reports/figures/mexico_eez.png
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# Se utiliza geom_sf() para mantener la geometría original.
# Se utiliza coord_sf() para mantener la proyección geográfica.
# La ZEE es la zona donde México tiene derechos soberanos sobre recursos marinos.
# ==========================================

# ==== HEADER ====
# Se cargan únicamente los paquetes necesarios para leer datos espaciales
# y construir gráficos declarativos con ggplot2
library(sf)         # Permite importar shapefiles como objetos Simple Features
library(tidyverse)  # Proporciona ggplot2 y herramientas de manipulación de datos


# ==== CONFIGURATION ====
# Centralizar rutas y constantes evita números mágicos y facilita mantenimiento
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"  # Ruta al shapefile EEZ
output_figure_path <- "reports/figures/mexico_eez.png"                      # Ruta de la figura generada

fill_color <- "#9AD0EC"    # Color de relleno que resalta la superficie marítima
line_color <- "#0C4A6E"    # Color del contorno para definir claramente el límite EEZ
line_size <- 0.3           # Grosor del borde para mantener visibilidad sin saturar el mapa

fig_width <- 8             # Ancho de la figura en pulgadas para exportación consistente
fig_height <- 6            # Alto de la figura para mantener proporción cartográfica
fig_dpi <- 300             # Resolución suficiente para reportes y publicaciones


# ==== INPUTS ====
# Se importa el shapefile como objeto sf para habilitar operaciones espaciales
# quiet = TRUE evita mensajes informativos que no aportan al flujo del pipeline
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)


# ==== PROCESS / ANALYSIS ====
# Se construye una visualización simple que resalta únicamente la geometría EEZ
# ggplot() permite una construcción declarativa del gráfico
plot_mexico_eez <- ggplot() +
  geom_sf(
    data = mexico_eez_sf,
    fill = fill_color,
    color = line_color,
    linewidth = line_size
  ) +
  coord_sf() +           # Mantiene la proyección geográfica del objeto sf
  theme_minimal() +      # Estilo limpio que enfatiza la geometría espacial
  labs(
    title = "Zona Económica Exclusiva de México",
    caption = "Geoportal: Zonas de Refugio Pesquero. TNC México"
  )

# ==== OUTPUT ====
# Se exporta la figura como PNG para mantener consistencia con otros outputs del proyecto
# La resolución alta permite su uso en reportes o publicaciones
ggsave(
  filename = output_figure_path,
  plot = plot_mexico_eez,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
