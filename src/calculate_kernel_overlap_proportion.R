library(rnaturalearth)
library(sf)
library(ggplot2)

percent <- 25

# Load home ranges from GeoPackage
filename_multiple_polygons <- paste0("seabird_home_ranges_", percent, ".gpkg")
combined_home_ranges_sf <- st_read(filename_multiple_polygons)

# Load home ranges from GeoPackage
filename_union <- paste0("seabird_kernel_union_", percent, ".gpkg")
union_seabird_home_range_sf <- st_read(filename_union)

# Load home ranges from GeoPackage
filename_intersection <- paste0("vessel_seabird_kernel_intersection_", percent, ".gpkg")
intersection_sf <- st_read(filename_intersection)

area_intersection <- st_area(intersection_sf)
area_vessel       <- st_area(union_vessel_home_range_sf)
area_seabird      <- st_area(union_seabird_home_range_sf)

# Overlap proportions
prop_vessel_overlap  <- area_intersection / area_vessel
prop_seabird_overlap <- area_intersection / area_seabird
