# ==========================================
# Propósito: Leer un GeoPackage con la diferencia espacial ANP - México
#            y generar una figura estática en PNG sin usar control de flujo.
# Entradas:  data/processed/mexico_mpa.gpkg (capa: "mexico_mpa")
# Salidas:   reports/figures/mexico_mpa_YYYY-MM-DD.png
# Dependencias: sf, tidyverse, glue
# Notas:     Se usa ggplot2 con geom_sf() para visualizar la geometría resultante.
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)         # Para leer y manejar datos espaciales (Simple Features)
library(tidyverse)  # Para manipulación declarativa y gráficos con ggplot2
library(glue)       # Para construir cadenas de texto dinámicas

# ==== CONFIGURACIÓN ====
# -- Centralizar rutas y constantes facilita cambios y mantiene el script legible
input_gpkg_path <- "data/processed/mexico_mpa.gpkg"                 # Ruta de entrada
input_layer_name <- "mexico_mpa"                                    # Nombre de la capa en el GPKG
output_figure_path <- "reports/figures/mexico_mpa.png"              # Ruta de la figura
fill_color <- "#9AD0EC"                                             # Relleno para destacar el área
line_color <- "#185ADB"                                             # Color del contorno
line_size <- 0.3                                                    # Grosor del contorno
fig_width <- 8                                                      # Ancho de la figura (pulgadas)
fig_height <- 6                                                     # Alto de la figura (pulgadas)
fig_dpi <- 300                                                      # Resolución de salida

# ==== IMPORTAR DATOS ====
# Se lee la capa espacial desde el GeoPackage; quiet = TRUE suprime mensajes informativos
mexico_mpa <- st_read(dsn = input_gpkg_path, layer = input_layer_name, quiet = TRUE)

# ==== VISUALIZACIÓN ====
# Se construye un mapa sencillo que resalta la geometría resultante de la diferencia espacial
plot_amp <- ggplot() +
  geom_sf(data = mexico_mpa, fill = fill_color, color = line_color, size = line_size) +
  coord_sf() +                                # Mantiene la proyección del objeto sf sin distorsión
  theme_minimal() +                           # Estilo limpio para enfocarse en la geografía
  labs(
    title = "Diferencia espacial ANP − México",
    subtitle = "Geometría resultante (ANP menos territorio de México)",
    caption = glue("Fuente: {input_gpkg_path} / capa: {input_layer_name}")
  )

# ==== GUARDAR SALIDA ====
# Se exporta el gráfico en PNG con nombre versionado por fecha para trazabilidad
ggsave(
  filename = output_figure_path,
  plot = plot_amp,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
