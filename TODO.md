# Issue #48: Hot-spot analysis of VMS trajectories using the KDE grid partition

We will do Trajectory Hot-Spot (THS) analysis (Nikitopoulos et al. 2018) of
VMS fishing vessel data, using the empty grid from the KDE as a spatial
partition.

## Data

- Vessel trajectories: `data/external/vessel_data_pacific_2014.csv`
  (1.4M rows, seg_id, point_in_seg, datetime, lat, lon, hours)
- Empty grid: from `individual_kde_guadalupe.rds` → KDE_surface (estUDm)
- Longline events: `oorg_2025_geci_longline_events_*.csv` to be analysed
  with `kernelUD()` on the same grid

## Scripts

### 1. `src/export_vms_in_grid.R`
- **Input:** `data/external/vessel_data_pacific_2014.csv`,
  `data/processed/individual_kde_guadalupe.rds`
- **Output:** `data/processed/vms_in_grid.gpkg`
- **What it does:**
  1. Read the VMS CSV
  2. Read the KDE RDS, extract `KDE_surface` (`estUDm`),
     convert to `SpatialPixelsDataFrame` with `estUDm2spixdf()`,
     then to `sf` polygons
  3. Reproject VMS points to the grid CRS
  4. Count points per grid cell with `sf::st_intersects()`
  5. Write the grid with point counts as GeoPackage

### 2. `src/compute_vms_hotspot.R`
- **Input:** `data/processed/vms_in_grid.gpkg`
- **Output:** `data/processed/vms_hotspot_guadalupe.gpkg`
- **What it does:**
  1. Read the grid with point counts
  2. Build Queen contiguity weights matrix with `spdep::poly2nb()`
  3. Compute Getis-Ord Gi* z-scores with `spdep::localG()`
  4. Write the grid with z-scores as GeoPackage

## Makefile targets

```
data/processed/vms_in_grid.gpkg: \
  data/external/vessel_data_pacific_2014.csv \
  data/processed/individual_kde_guadalupe.rds
	$(checkDirectories)
	Rscript src/export_vms_in_grid.R

data/processed/vms_hotspot_guadalupe.gpkg: \
  data/processed/vms_in_grid.gpkg
	$(checkDirectories)
	Rscript src/compute_vms_hotspot.R
```

## Decisions log
- **Data:** VMS vessel trajectories (not longline events)
- **Grid:** From `individual_kde_guadalupe.rds` → `KDE_surface`
- **CRS:** Reproject VMS points to the grid CRS
- **Attribute:** Count of VMS points per cell (not hours)
- **Temporal partition:** None (2D, aggregated over all time)
- **Spatial weights:** Queen contiguity
- **Package pattern:** Scripts in `src/`, not in `bycatch`
