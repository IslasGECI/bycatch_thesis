# ==========================================
# Título: Grafica México usando datos de Natural Earth
#
# Contexto (Por qué):
# En lugar de depender de un shapefile local, se pueden obtener los datos
# geográficos de México directamente desde la base de datos Natural Earth.
# Esto simplifica la gestión de datos espaciales y garantiza información
# actualizada.
#
# Descripción (Qué / Cómo):
# Utiliza el paquete rnaturalearth para descargar los límites políticos de
# México en formato sf, genera una figura estática con ggplot2 y la exporta
# como archivo PNG.
#
# Entradas:
# (ninguna: los datos se obtienen del paquete rnaturalearth)
#
# Salida:
# reports/figures/mexico_naturalearth.png
#
# Dependencias:
# rnaturalearth
# rnaturalearthdata
# sf
# tidyverse
#
# Notas:
# - Natural Earth proporciona datos cartográficos de dominio público
# - rnaturalearth facilita la descarga directa de geometrías a objetos sf
# - ggsave() mantiene consistencia con el resto de scripts del proyecto
# ==========================================


# ==== CONFIGURACIÓN ====
library(rnaturalearth)      # Proporciona ne_countries() para descargar límites políticos
library(rnaturalearthdata)  # Proporciona los datos cartográficos base de Natural Earth
library(sf)                 # Proporciona la clase sf para manejar geometrías espaciales
library(tidyverse)          # Proporciona ggplot2 para construir visualizaciones declarativas

# Ruta del archivo PNG de salida con el mapa de México desde Natural Earth
output_figure_path <- "reports/figures/mexico_naturalearth.png"

# Colores para la visualización del territorio mexicano
fill_color <- "lightblue"   # Color de relleno que destaca el territorio en el mapa
line_color <- "darkblue"    # Color de contorno para definir los límites políticos
line_size <- 0.3            # Grosor de línea moderado para mantener legibilidad

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
# Construye un mapa base de México utilizando los límites políticos
# descargados de la base de datos Natural Earth
plot_mexico <- ggplot(mexico_sf) +
  # Capa de la geometría de México con colores definidos
  geom_sf(
    fill = fill_color,
    color = line_color,
    size = line_size
  ) +
  # Estilo limpio que enfatiza la geometría espacial sin distracciones
  theme_minimal() +
  # Título descriptivo simple para el mapa base
  labs(title = "México")


# ==== SALIDA ====
# Exporta el mapa base de México como PNG para integrarse con el sistema
# de reportes del proyecto
ggsave(
  filename = output_figure_path,
  plot = plot_mexico,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
