library(rnaturalearth)
library(sf)
library(ggplot2)

percent <- 25

# Load Mexico geometry
mex <- ne_countries(scale = "medium",
                    country = "Mexico",
                    returnclass = "sf")

# Load home ranges from GeoPackage
filename_multiple_polygons <- paste0("seabird_home_ranges_", percent, ".gpkg")
combined_home_ranges_sf <- st_read(filename_multiple_polygons)

# Plot both on the same map
print(
  ggplot() +
    geom_sf(
      data = mex,
      fill = "beige",
      color = "brown"
    ) +
    geom_sf(
      data = combined_home_ranges_sf,
      aes(fill = seabird_id),
      color = NA,
      alpha = 0.5
    ) +
    ggtitle(paste0(
      percent, "% Kernel Density of Fishing seabirds off Mexico"
    )) +
    theme_minimal() +
    guides(fill = "none")  # Optional: remove legend if too many seabirds
)
png_filename_multiple_polygons <- paste0("kernel_seabird_home_ranges_map_", percent, ".png")
ggsave(
  png_filename_multiple_polygons,
  width = 10,
  height = 8,
  dpi = 300
)


# Load home ranges from GeoPackage
filename_union <- paste0("seabird_kernel_union_", percent, ".gpkg")
union_home_range_sf <- st_read(filename_union)

# Plot the union over the Mexico map
print(
  ggplot() +
    geom_sf(
      data = union_home_range_sf,
      fill = "lightgreen",
      color = NA,
      alpha = 0.5
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
png_filename_union <- paste0("kernel_seabird_home_ranges_union_", percent, ".png")
ggsave(png_filename_union,
       width = 10,
       height = 8,
       dpi = 300)
