# ==========================================
# Debug plot EEZ and bounding box overlap
# ==========================================

library(sf)
library(tidyverse)

# ==== CONFIGURATION ====
input_shapefile_path <- "data/external/Exclusive_economic_zone_Mexico.shp"
output_figure_path <- "reports/figures/mexico_eez_bbox_union.png"
output_layer_name <- "mexico_eez_bbox"

bbox_lon_min <- -170
bbox_lon_max <- -110
bbox_lat_min <- 10
bbox_lat_max <- 55

# ==== INPUTS ====
mexico_eez_sf <- st_read(input_shapefile_path, quiet = TRUE)

# Transform geometry to geographic coordinates
mexico_eez_wgs84 <- mexico_eez_sf |>
  st_transform(4326)

# ==== CREATE BOUNDING BOX ====
bounding_box_polygon <- st_bbox(
  c(
    xmin = bbox_lon_min,
    xmax = bbox_lon_max,
    ymin = bbox_lat_min,
    ymax = bbox_lat_max
  ),
  crs = 4326
) |>
  st_as_sfc()

# ==== PLOT ====
plot_debug <- ggplot() +
  geom_sf(
    data = mexico_eez_wgs84,
    fill = "#93C5FD",
    color = "#1E3A8A",
    alpha = 0.5
  ) +
  geom_sf(
    data = bounding_box_polygon,
    fill = NA,
    color = "red",
    linewidth = 1
  ) +
  coord_sf() +
  theme_minimal()

# ==== OUTPUT ====
ggsave(
  filename = output_figure_path,
  plot = plot_debug,
  width = 8,
  height = 6,
  dpi = 300
)

mexico_eez_bbox <- st_intersection(
  mexico_eez_wgs84,
  bounding_box_polygon
)

