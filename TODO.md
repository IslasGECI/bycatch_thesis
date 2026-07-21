# The Gold

Create binary hotspot map and KBA + hotspot overlay map for GFW apparent fishing effort.

## Plan

### Task 1: Create binary hotspot map script

Create `src/plot_gfw_apparent_fishing_effort_hotspot_binary.R` following the same pattern as `src/plot_gfw_longline_hotspot_binary.R`.

- **Input**: `data/processed/gfw_apparent_fishing_effort_hotspot.gpkg` (columns: `cell_id`, `geometry`, `sum_gfw_apparent_fishing_hours`, `gi_star_z_score`, `gi_star_p_value`)
- **Filter**: Keep only cells where `sum_gfw_apparent_fishing_hours > 0`
- **Classification**: `is_hot_spot = gi_star_z_score >= 1.96`
- **Colors**: Orange (`#E67E22`) for hot spots, green (`#2ECC71`) for non-hot-spots
- **Map context**: World coastline (Natural Earth), EEZ bounding box from `data/processed/mexico_eez_bounding_box_zoom_in.json`
- **Output**: `reports/figures/gfw_apparent_fishing_effort_hotspot_binary_map.png`
- **Dependencies**: `rnaturalearth`, `rnaturalearthdata`, `sf`, `tidyverse`

### Task 2: Add Makefile rule for binary map

```makefile
# Grafica el mapa binario de hot spots de esfuerzo pesquero de GFW
reports/figures/gfw_apparent_fishing_effort_hotspot_binary_map.png: \
  data/processed/gfw_apparent_fishing_effort_hotspot.gpkg \
  data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_gfw_apparent_fishing_effort_hotspot_binary.R
```

### Task 3: Create KBA + hotspot overlay map script

Create `src/plot_kba_and_gfw_apparent_fishing_effort_hotspot.R` following the same pattern as `src/plot_kba_and_gfw_longline_hotspot.R`.

- **Inputs**:
  - `data/processed/kba_polygons_all.gpkg`
  - `data/processed/gfw_apparent_fishing_effort_hotspot.gpkg`
  - `data/processed/kba_gfw_apparent_fishing_effort_hotspot_intersection.gpkg`
  - `data/processed/mexico_mpa.gpkg`
  - `data/external/Exclusive_economic_zone_Mexico.shp`
- **Output**: `reports/figures/kba_and_gfw_apparent_fishing_effort_hotspot_map.png`
- **Dependencies**: `rnaturalearth`, `rnaturalearthdata`, `sf`, `tidyverse`

### Task 4: Add Makefile rule for KBA overlay map

```makefile
# Grafica el mapa combinado de KBA y hot spots de esfuerzo pesquero de GFW
reports/figures/kba_and_gfw_apparent_fishing_effort_hotspot_map.png: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/gfw_apparent_fishing_effort_hotspot.gpkg \
  data/processed/kba_gfw_apparent_fishing_effort_hotspot_intersection.gpkg \
  data/processed/mexico_mpa.gpkg \
  data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_and_gfw_apparent_fishing_effort_hotspot.R
```

---

# Backlog not part of the current Gold

The items listed below are not part of the current Gold. They are backlog items kept for future cycles.

- GFW apparent fishing effort: filter by specific gear types (longline, trawler, etc.)
