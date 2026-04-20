# ==========================================
# Título: Graficar México usando Natural Earth
#
# Contexto (Por qué):
# En lugar de depender de un shapefile local, es posible obtener los datos
# geográficos de México directamente desde la base de datos Natural Earth.
# Esto simplifica la gestión de datos espaciales y garantiza datos actualizados.
#
# Descripción (Qué / Cómo):
# El script utiliza el paquete rnaturalearth para descargar los límites
# políticos de México en formato sf, genera una figura estática usando
# ggplot2 y la exporta como archivo PNG.
#
# Entradas:
# (ninguno - los datos se obtienen del paquete rnaturalearth)
#
# Salidas:
# reports/figures/mexico_naturalearth.png
#
# Dependencias:
# sf
# tidyverse
# rnaturalearth
# rnaturalearthdata
#
# Notas:
# Natural Earth proporciona datos cartográficos de dominio público.
# El paquete rnaturalearth facilita la descarga directa a objetos sf.
# Se utiliza ggsave() en lugar de png()/dev.off() para consistencia.
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)

# ==== CONFIGURACIÓN ====
output_figure_path <- "reports/figures/mexico_naturalearth.png"
fill_color <- "lightblue"
line_color <- "darkblue"
line_size <- 0.3
fig_width <- 8
fig_height <- 6
fig_dpi <- 300

# ==== OBTENER DATOS ====
mexico_sf <- ne_countries(country = "Mexico", returnclass = "sf")

# ==== VISUALIZACIÓN ====
plot_mexico <- ggplot(mexico_sf) +
  geom_sf(fill = fill_color, color = line_color, size = line_size) +
  theme_minimal() +
  labs(title = "México")

# ==== GUARDAR SALIDA ====
ggsave(
  filename = output_figure_path,
  plot = plot_mexico,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)