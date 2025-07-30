library(sf)

percent <- 25

# Load the unioned layers
input_directory <- "data/processed/"
filename_vessel <- paste0(input_directory, "vessel_kernel_union_", percent, ".gpkg")
union_vessel_home_range_sf <- st_read(filename_vessel)

filename_seabird <- paste0(input_directory, "seabird_kernel_union_", percent, ".gpkg")
union_seabird_home_range_sf <- st_read(filename_seabird)

# Ensure valid geometry (important before spatial operations)
union_vessel_home_range_sf <- st_make_valid(union_vessel_home_range_sf)
union_seabird_home_range_sf <- st_make_valid(union_seabird_home_range_sf)

# Compute the spatial intersection
intersection_sf <- st_intersection(union_vessel_home_range_sf, union_seabird_home_range_sf)

# Save the result
output_directory <- "data/processed/"
filename_intersection <- paste0(output_directory, "overlap_kernel_intersection_", percent, ".gpkg")
st_write(intersection_sf, filename_intersection, append = FALSE)

# Optional: plot it
plot(st_geometry(intersection_sf), main = paste0(percent, "% Vessel–Seabird Kernel Intersection"))
