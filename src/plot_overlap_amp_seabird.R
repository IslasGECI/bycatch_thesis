# ==========================================
# Propósito: Graficar la superposición espacial overlap_amp_seabird_25.gpkg
#            junto con el continente (México), el polígono AMP (amp_mexico.gpkg)
#            y el kernel de aves marinas (seabird_kernel_union_{percent}.gpkg),
#            generando dos figuras: una general y otra con zoom regional.
# Entradas:  data/processed/overlap_amp_seabird_25.gpkg
#            data/processed/amp_mexico.gpkg
#            data/processed/seabird_kernel_union_{percent}.gpkg
# Salidas:   reports/figures/overlap_amp_seabird.png
#            reports/figures/overlap_amp_seabird_zoom.png
# Dependencias: sf, tidyverse, rnaturalearth, glue
# ==========================================

# ==== CARGAR PAQUETES ====
library(sf)
library(tidyverse)
library(glue)
library(rnaturalearth)

# ==== CONFIGURACIÓN ====
percent <- 25
input_dir <- "data/processed"
output_dir <- "reports/figures"

amp_path <- glue("{input_dir}/amp_mexico.gpkg")
amp_layer <- "amp_mexico"

seabird_path <- glue("{input_dir}/seabird_kernel_union_{percent}.gpkg")

overlap_path <- glue("{input_dir}/overlap_amp_seabird_{percent}.gpkg")
overlap_layer <- "overlap_amp_seabird"

output_figure_general <- glue("{output_dir}/overlap_amp_seabird.png")
output_figure_zoom <- glue("{output_dir}/overlap_amp_seabird_zoom.png")

fill_mexico <- "#F0E5CF"
line_mexico <- "#8B5E3C"
fill_amp <- "#3B82F6"
fill_seabird <- "#22C55E"
fill_overlap <- "#EF4444"
alpha_fill <- 0.35
line_size <- 0.2
fig_width <- 10
fig_height <- 8
fig_dpi <- 300

# ==== IMPORTAR DATOS ====
amp_sf <- st_read(dsn = amp_path, layer = amp_layer, quiet = TRUE)
seabird_sf <- st_read(dsn = seabird_path, quiet = TRUE)
overlap_sf <- st_read(dsn = overlap_path, layer = overlap_layer, quiet = TRUE)

mexico_sf <- ne_countries(
  scale = "medium",
  country = "Mexico",
  returnclass = "sf"
)

# ==== PREPARAR GEOMETRÍAS ====
amp_sf <- amp_sf |> st_make_valid()
target_crs <- st_crs(amp_sf)

seabird_sf <- seabird_sf |>
  st_transform(target_crs) |>
  st_make_valid()

overlap_sf <- overlap_sf |>
  st_transform(target_crs) |>
  st_make_valid()

mexico_sf <- mexico_sf |>
  st_transform(target_crs) |>
  st_make_valid()

# ==== VISUALIZACIÓN GENERAL ====
plot_general <- ggplot() +
  geom_sf(data = mexico_sf, fill = fill_mexico, color = line_mexico, linewidth = line_size) +
  geom_sf(data = seabird_sf, fill = fill_seabird, color = NA, alpha = alpha_fill) +
  geom_sf(data = amp_sf, fill = fill_amp, color = NA, alpha = alpha_fill) +
  geom_sf(data = overlap_sf, fill = fill_overlap, color = NA, alpha = 0.7) +
  theme_minimal() +
  labs(
    title = glue("Superposición ANP vs. Kernel de Aves Marinas ({percent}%)"),
    subtitle = "Vista general - México y sus zonas de solapamiento",
    caption = glue("Fuentes: {basename(amp_path)}, {basename(seabird_path)}, {basename(overlap_path)}")
  )

# ==== VISUALIZACIÓN ZOOM ====
# Se muestra un recorte espacial con coordenadas específicas
plot_zoom <- ggplot() +
  geom_sf(data = mexico_sf, fill = fill_mexico, color = line_mexico, linewidth = line_size) +
  geom_sf(data = seabird_sf, fill = fill_seabird, color = NA, alpha = alpha_fill) +
  geom_sf(data = amp_sf, fill = fill_amp, color = NA, alpha = alpha_fill) +
  geom_sf(data = overlap_sf, fill = fill_overlap, color = NA, alpha = 0.7) +
  coord_sf(
    xlim = c(-124, -110),
    ylim = c(25, 34),
    expand = FALSE
  ) +
  theme_minimal() +
  labs(
    title = glue("Superposición ANP vs. Kernel de Aves Marinas ({percent}%)"),
    subtitle = "Vista con zoom - Región noroeste de México",
    caption = glue("Fuentes: {basename(amp_path)}, {basename(seabird_path)}, {basename(overlap_path)}")
  )

# ==== GUARDAR SALIDAS ====
# Figura general
ggsave(
  filename = output_figure_general,
  plot = plot_general,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)

# Figura con zoom
ggsave(
  filename = output_figure_zoom,
  plot = plot_zoom,
  width = fig_width,
  height = fig_height,
  dpi = fig_dpi
)
