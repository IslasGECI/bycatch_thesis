# ==========================================
# Título: Graficar México usando Natural Earth con Elementos Cartográficos
#
# Contexto (Por qué):
# En lugar de depender de un shapefile local, es posible obtener los datos
# geográficos de México directamente desde la base de datos Natural Earth.
# Esto simplifica la gestión de datos espaciales y garantiza datos actualizados.
# Este script extiende el ejemplo básico añadiendo elementos cartográficos
# profesionales como escala, flecha de norte y tema mejorado.
#
# Descripción (Qué / Cómo):
# El script utiliza el paquete rnaturalearth para descargar los límites
# políticos de México en formato sf, genera una figura estática usando
# ggplot2 con elementos cartográficos profesionales (escala, norte) y la
# exporta como archivo PNG.
#
# Entradas:
# (ninguno - los datos se obtienen del paquete rnaturalearth)
#
# Salidas:
# reports/figures/mexico_naturalearth_pro.png
#
# Dependencias:
# sf
# tidyverse
# rnaturalearth
# rnaturalearthdata
# ggspatial
#
# Notas:
# Natural Earth proporciona datos cartográficos de dominio público.
# El paquete rnaturalearth facilita la descarga directa a objetos sf.
# Se utiliza ggspatial para añadir escala y flecha de norte.
# Se utiliza coord_sf() para establecer los límites del mapa.
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)

# ==== CONFIGURACIÓN ====
output_figure_path <- "reports/figures/mexico_naturalearth_pro.png"
fill_color <- "antiquewhite"
line_color <- "gray30"
line_size <- 0.3
fig_width <- 8
fig_height <- 6
fig_dpi <- 300

# ==== OBTENER DATOS ====
mexico_sf <- ne_countries(country = "Mexico", returnclass = "sf")

# ==== VISUALIZACIÓN ====
plot_mexico <- ggplot(data = mexico_sf) +
  geom_sf(fill = fill_color, color = line_color, size = line_size) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(
    location = "br",
    which_north = "true",
    pad_x = unit(0.5, "in"),
    pad_y = unit(0.5, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  coord_sf(xlim = c(-118, -86), ylim = c(12, 33), expand = FALSE) +
  labs(
    title = "México",
    subtitle = "Límites políticos obtenidos de Natural Earth",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme(
    panel.grid.major = element_line(color = "gray50", linetype = "dashed", size = 0.3),
    panel.background = element_rect(fill = "aliceblue"),
    panel.border = element_rect(color = "gray30", fill = NA),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )

# ==== GUARDAR SALIDA ====
ggsave(
  filename = output_figure_path,
  plot = plot_mexico,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)