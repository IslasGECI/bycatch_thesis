library(rnaturalearth)
library(sf)
library(ggplot2)

percent <- 25
input_directory <- "data/processed/"
output_directory <- "reports/figures/"

# Load Mexico geometry
mex <- ne_countries(scale = "medium",
                    country = "Mexico",
                    returnclass = "sf")

# Load home ranges from GeoPackage
filename_intersection <- paste0(input_directory, "vessel_seabird_kernel_intersection_", percent, ".gpkg")
intersection_sf <- st_read(filename_intersection)

# Plot the intersection over the Mexico map
print(
  ggplot() +
    geom_sf(
      data = union_vessel_home_range_sf,
      fill = "cornflowerblue",
      color = NA,
      alpha = 0.4
    ) +
    geom_sf(
      data = union_seabird_home_range_sf,
      fill = "lightgreen",
      color = NA,
      alpha = 0.4
    ) +
    geom_sf(
      data = intersection_sf,
      fill = "pink",
      color = NA
    ) +
    geom_sf(
      data = mex,
      fill = "beige",
      color = "brown"
    ) +
    ggtitle(paste0(percent, "% Union of Kernel Home Ranges")) +
    theme_minimal()
)

# Save union plot to PNG
png_filename_union <- paste0(output_directory, "kernel_overlap_home_ranges_union_", percent, ".png")
ggsave(png_filename_union,
       width = 10,
       height = 8,
       dpi = 300)

# Plot the intersection over the Mexico map
print(
  ggplot() +
    geom_sf(
      data = union_vessel_home_range_sf,
      fill = "cornflowerblue",
      color = NA,
      alpha = 0.4
    ) +
    geom_sf(
      data = union_seabird_home_range_sf,
      fill = "lightgreen",
      color = NA,
      alpha = 0.4
    ) +
    geom_sf(
      data = intersection_sf,
      fill = "pink",
      color = NA
    ) +
    geom_sf(
      data = mex,
      fill = "beige",
      color = "brown"
    ) +
    coord_sf(
      xlim = c(-124, -110),
      ylim = c(25, 34),
      expand = FALSE
    ) +
    ggtitle(paste0(percent, "% Union of Kernel Home Ranges")) +
    theme_minimal()
)

# Save union plot to PNG
png_filename_union <- paste0(output_directory, "kernel_overlap_home_ranges_union_", percent, "_zoom.png")
ggsave(png_filename_union,
       width = 10,
       height = 8,
       dpi = 300)
