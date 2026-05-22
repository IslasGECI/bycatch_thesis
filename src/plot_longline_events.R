# ==========================================
# Título: Grafica los eventos de palangre del Pacífico Norte
#
# Contexto (Por qué):
# Los eventos de pesca con palangre representan una amenaza potencial
# para las aves marinas. Visualizar su distribución espacial permite
# identificar las zonas de mayor presión pesquera en la región.
#
# Descripción (Qué / Cómo):
# Carga el archivo CSV con eventos de palangre de Global Fishing Watch,
# filtra los registros con coordenadas de inicio válidas y genera un mapa
# de puntos clasificados por tipo de evento: setting (calado) y hauling
# (virado). Superpone los eventos sobre una capa de costa mundial y
# exporta la figura como PNG para su inclusión en reportes.
#
# Entradas:
# data/external/oorg_2025_geci_longline_events_v20260402.csv
#
# Salida:
# reports/figures/longline_events_map.png
#
# Dependencias:
# tidyverse
# rnaturalearth
# rnaturalearthdata
#
# Notas:
# - Los puntos representan la posición de inicio de cada evento
# - La transparencia evita la saturación visual por la densidad de puntos
# ==========================================


# ==== CONFIGURACIÓN ====
library(tidyverse)          # Proporciona readr para importar datos y ggplot2 para graficar
library(rnaturalearth)      # Proporciona datos vectoriales de costa mundial
library(rnaturalearthdata)  # Extiende rnaturalearth con resolución media de costa

# Rutas de archivos de entrada y salida
input_csv_path <- "data/external/oorg_2025_geci_longline_events_v20260402.csv"
output_png_path <- "reports/figures/longline_events_map.png"

# Parámetros de visualización para manejar la alta densidad de puntos
point_alpha <- 0.1          # Transparencia para evitar saturación por sobreposición
point_size <- 0.5           # Tamaño pequeño para mantener legibilidad del mapa

# Dimensiones y resolución de la figura de salida
fig_width <- 10             # Ancho en pulgadas consistente con otros mapas del proyecto
fig_height <- 6             # Alto en pulgadas que mantiene proporción cartográfica
fig_dpi <- 300              # Resolución adecuada para publicaciones en reportes


# ==== ENTRADAS ====
# Carga el archivo CSV con los eventos de pesca de palangre
longline_data <- read_csv(input_csv_path, show_col_types = FALSE)

# Importa la capa de costa mundial como fondo geográfico del mapa
world_coastline <- ne_countries(scale = "medium", returnclass = "sf")


# ==== PROCESAMIENTO / ANÁLISIS ====
# Filtra las filas con coordenadas de inicio completas para evitar
# errores de graficación por valores ausentes en posición geográfica
events_filtered <- longline_data |>
  filter(
    !is.na(start_lat),
    !is.na(start_lon)
  )

# Construye el mapa temático con fondo de costa y eventos de palangre
# coloreados por tipo: setting (calado de la línea) y hauling (virado)
longline_map <- ggplot() +
  # Capa base de costa mundial como referencia geográfica
  geom_sf(
    data = world_coastline,
    fill = "gray90",
    color = "gray50",
    linewidth = 0.2
  ) +
  # Capa de puntos de eventos con transparencia para densidad variable
  geom_point(
    data = events_filtered,
    mapping = aes(
      x = start_lon,
      y = start_lat,
      color = label
    ),
    alpha = point_alpha,
    size = point_size
  ) +
  # Asigna colores distintivos a cada tipo de evento pesquero
  scale_color_manual(
    values = c(
      "setting" = "#1f77b4",
      "hauling" = "#d62728"
    ),
    labels = c(
      "setting" = "Calado",
      "hauling" = "Virado"
    )
  ) +
  # Extensión espacial fija que cubre el Pacífico Norte desde México
  # hasta la línea de cambio de fecha, abarcando el área de estudio
  coord_sf(
    xlim = c(-175, -105),
    ylim = c(5, 55),
    expand = FALSE
  ) +
  # Etiquetas del mapa en español para integrarse al contexto del reporte
  labs(
    title = "Eventos de pesca con palangre en el Pacífico Norte",
    subtitle = "Datos de Global Fishing Watch",
    color = "Tipo de evento",
    x = "Longitud",
    y = "Latitud"
  ) +
  # Tema minimalista que reduce el ruido visual del mapa
  theme_minimal()


# ==== SALIDA ====
# Exporta la figura como PNG al directorio de figuras del reporte
ggsave(
  filename = output_png_path,
  plot = longline_map,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
