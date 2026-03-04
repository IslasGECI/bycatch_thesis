library(sp)
library(adehabitatHR)
library(dplyr)
library(sf)

percent <- 25
input_directory <- "data/processed/"
output_directory <- "data/processed/"

# Load data
filename_seabird_data <- paste0(input_directory, "trips_geographic_points.csv")
seabird_data <- read.csv(filename_seabird_data)

# Ensure seabird_id is a factor and not NA
filtered_seabird_data <- seabird_data |>
  filter(
    !is.na(X),
    !is.na(Y),
    !is.na(tripID),
    lubridate::year(date) == 2014
  ) |>
  mutate(seabird_id = as.factor(tripID))

# Get list of unique seabirds
seabirds <- unique(filtered_seabird_data$seabird_id)

# Initialize a list to store the polygons
home_ranges <- list()

for (v in seabirds) {
  # Subset data for seabird
  seabird_subset <- filtered_seabird_data[filtered_seabird_data$seabird_id == v, ]
  # Skip if too few points
  if (nrow(seabird_subset) < 30) next # adjust threshold if needed
  # Create a SpatialPointsDataFrame
  coordinates(seabird_subset) <- ~ X + Y
  # Add seabird ID as a factor (required for kernelUD)
  seabird_subset$seabird_id <- as.factor(seabird_subset$tripID)
  # Set the projection (optional but recommended)
  proj4string(seabird_subset) <- CRS("+proj=longlat +datum=WGS84")
  # Estimate UD
  kud <- tryCatch(
    kernelUD(seabird_subset["seabird_id"], h = "href"),
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

# Add seabird ID as a column (if needed)
home_ranges_sf <- Map(function(sf_obj, id) {
  sf_obj$seabird_id <- id
  sf_obj
}, home_ranges_sf, names(home_ranges_sf))

# Bind into single sf object
combined_home_ranges_sf <- do.call(rbind, home_ranges_sf)

plot(combined_home_ranges_sf["seabird_id"], main = paste0("seabird Kernel Density (", percent, "%)"))
filename_multiple_polygons <- paste0(output_directory, "seabird_home_ranges_", percent, ".gpkg")
st_write(combined_home_ranges_sf, filename_multiple_polygons, append = FALSE) # or .shp


# Repair invalid geometries
combined_valid <- st_make_valid(combined_home_ranges_sf)

# Now compute the union
union_home_range <- st_union(combined_valid)


union_home_range_sf <- st_sf(geometry = union_home_range)
filename_union <- paste0(output_directory, "seabird_kernel_union_", percent, ".gpkg")
st_write(union_home_range_sf, filename_union, append = FALSE)
