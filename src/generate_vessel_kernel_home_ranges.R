library(sp)
library(adehabitatHR)
library(dplyr)
library(sf)

percent <- 25

# Load data
vessel_data <- read.csv("data_vessel_pacific_2014.csv")

# Ensure vessel_id is a factor and not NA
filtered_vessel_data <- vessel_data |>
  filter(
    !is.na(lon),
    !is.na(lat),
    !is.na(vessel_rnpa),
    distance_from_port_m > 60000,
    distance_from_shore_m > 60000
  ) |>
  mutate(vessel_id = as.factor(vessel_rnpa))

# Get list of unique vessels
vessels <- unique(filtered_vessel_data$vessel_id)

# Initialize a list to store the polygons
home_ranges <- list()

for (v in vessels) {
  # Subset data for vessel
  vessel_subset <- filtered_vessel_data[filtered_vessel_data$vessel_id == v, ]
  
  # Skip if too few points
  if (nrow(vessel_subset) < 30) next  # adjust threshold if needed
  
  # Create a SpatialPointsDataFrame
  coordinates(vessel_subset) <- ~ lon + lat

  
  # Add vessel ID as a factor (required for kernelUD)
  vessel_subset$vessel_id <- as.factor(vessel_subset$vessel_rnpa)

  # Set the projection (optional but recommended)
  proj4string(vessel_subset) <- CRS("+proj=longlat +datum=WGS84")
  
    
  # Estimate UD
  kud <- tryCatch(
    kernelUD(vessel_subset["vessel_id"], h = "href"),
    error = function(e) NULL
  )
  if (is.null(kud)) next
  
  # Extract percen% contour
  
  ver <- tryCatch(
    getverticeshr(kud, percent = percent),
    error = function(e) NULL
  )
  if (!is.null(ver)) {
    home_ranges[[as.character(v)]] <- ver
  }
}


# Convert each SpatialPolygonsDataFrame to sf
home_ranges_sf <- lapply(home_ranges, st_as_sf)

# Add vessel ID as a column (if needed)
home_ranges_sf <- Map(function(sf_obj, id) {
  sf_obj$vessel_id <- id
  sf_obj
}, home_ranges_sf, names(home_ranges_sf))

# Bind into single sf object
combined_home_ranges_sf <- do.call(rbind, home_ranges_sf)

plot(combined_home_ranges_sf["vessel_id"], main = paste0("Vessel Kernel Density (", percent, "%)"))
filename_multiple_polygons <- paste0("vessel_home_ranges_", percent, ".gpkg")
st_write(combined_home_ranges_sf, filename_multiple_polygons, append = FALSE)  # or .shp


# Repair invalid geometries
combined_valid <- st_make_valid(combined_home_ranges_sf)

# Now compute the union
union_home_range <- st_union(combined_valid)


union_home_range_sf <- st_sf(geometry = union_home_range)
filename_union <- paste0("vessel_kernel_union_", percent, ".gpkg")
st_write(union_home_range_sf, filename_union, append = FALSE)

