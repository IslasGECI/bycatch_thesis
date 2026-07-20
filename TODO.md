# The Gold

Filter GFW apparent fishing effort data to the Pacific Ocean EEZ (removing Gulf of California, Gulf of Mexico, Caribbean, Atlantic, etc.).

## Plan

### Task 1: Create spatial filter script

Create `src/remove_gulf_of_california_from_gfw_fishing_effort.R` following the same pattern as `src/remove_gulf_of_california_from_longline_events.R`.

- **Input**: `data/external/gfw_apparent_fishing_effort_in_mx_eez.csv` (75,840 rows, columns: `Lat`, `Lon`, `Time Range`, `Vessel ID`, `Flag`, `Vessel Name`, `Entry Timestamp`, `Exit Timestamp`, `Gear Type`, `Vessel Type`, `MMSI`, `IMO`, `CallSign`, `First Transmission Date`, `Last Transmission Date`, `Apparent Fishing Hours`)
- **Filter**: Keep only rows where the point falls inside layer 2 (NACIONAL, Marine=1) of `data/external/Exclusive_economic_zone_Mexico.shp` AND outside the Gulf of California polygon from `data/raw/gulf_of_california.kml`
- **Do not filter by**: `Gear Type`
- **Keep original column names** (`Lat`, `Lon` — no renaming)
- **Output**: `data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv` (61,390 rows after filtering)
- **Dependencies**: `sf`, `tidyverse`

### Task 2: Add Makefile rule

```makefile
data/processed/gfw_apparent_fishing_effort_in_eez_without_gulf_of_california.csv: \
  data/external/gfw_apparent_fishing_effort_in_mx_eez.csv \
  data/external/Exclusive_economic_zone_Mexico.shp \
  data/raw/gulf_of_california.kml
	$(checkDirectories)
	Rscript src/remove_gulf_of_california_from_gfw_fishing_effort.R
```

---

# Backlog not part of the current Gold

The items listed below are not part of the current Gold. They are backlog items kept for future cycles.

- GFW apparent fishing effort: grid counting per KDE cell (like `export_gfw_longline_in_grid.R`)
- GFW apparent fishing effort: Getis-Ord Gi* hotspot computation
- GFW apparent fishing effort: hotspot map visualization
- GFW apparent fishing effort: filter by specific gear types (longline, trawler, etc.)
