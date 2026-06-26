# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Albatross utilization distribution (UD) overlap pipeline: continuous N_IND surface via `track2KBA::findSite()`, joint albatross-longline index (UDOI), and UDOI computation script
- EEZ mask grid (`data/processed/eez_mask_in_grid.gpkg`) for filtering KDE cells inside Pacific Mexico EEZ
- `src/export_ud_in_grid.R` — exports N_IND count per KDE grid cell from representative assessment
- `src/export_ud_vms_longline_udoi.R` — computes the sum-normalized product of N_IND and VMS longline counts per cell, masked to EEZ
- `src/compute_udoi.R` — calculates the Utilization Distribution Overlap Index (UDOI) from the joint probability grid and writes statistics to JSON
- `src/plot_ud_vms_longline_udoi.R` — maps the joint index with coastline, EEZ, and MPA context; reads UDOI value from JSON for dynamic title
- `data/processed/udoi.json` — computed UDOI statistics with full precision
- `reports/figures/ud_vms_longline_udoi_map.png` — joint albatross-longline index map
- EEZ mask applied to UDOI computation: both inputs zeroed outside Pacific Mexico EEZ before normalization
- All new figures and JSON registered as Makefile prerequisites for the second paper PDF
- GFW longline hot-spot analysis pipeline: long-format event reshaping, grid counting, Getis-Ord Gi* computation, continuous and binary hot-spot maps
- Binary hot-spot classification map (`gfw_longline_hotspot_binary_map_all.png`) for GFW longline fishing events
- Obsolete-results archive (`papers/obsolete-results/`) with build target `reports/obsolete_results.pdf`
- Build rules for `gps_albatross_geographic_points_raw_all.png` and `gps_albatross_geographic_points_raw_guadalupe.png`
- Gulf of California KML boundary file (`data/raw/gulf_of_california.kml`)
- GFW longline hot-spot binary map as prerequisite of the second paper PDF

### Changed

- All figures consolidated to all-colony (`_all`) versions; single-colony Guadalupe figures removed
- Raw GPS points figure moved from active supplementary to obsolete-results archive
- Duplicate figures between first and second papers removed from the second paper
- Obsolete figure descriptions moved from supplementary to archive
- UDOI computation now masks inputs by EEZ before normalization, making the index conditional on the Pacific Mexico EEZ
- UDOI map title dynamically reads the computed UDOI percentage from JSON instead of hardcoding

### Removed

- Six Guadalupe-only figure Makefile targets (`*ars_guadalupe*`, `*raw_guadalupe*`, `*by_trip_guadalupe*`)
- `mexico_eez_bounding_box_zoom_in.png` reference from active manuscripts (only in archive)
- `gps_albatross_geographic_points_raw_all.png` reference from first paper supplementary
- Dangling Makefile target `reports/figures/gulf_of_california.png`

### Fixed

- `plot_mexico_map.R` and `plot_mexico_pna.R`: added `quiet = TRUE` to `st_read()` calls to suppress verbose output
- Second paper PDF prerequisites now include all referenced PNGs
- All Makefile PNG targets now have corresponding references in `papers/**/*.md`
- Added missing Makefile prerequisite for the GFW longline hot-spot binary map in the second paper target

## [v0.2.0] - 2026-05-30

### Added

- Custom KBA map for Guadalupe without MPA overlay (red polygon contour on EEZ and coastline)
- Custom KBA-MPA intersection map showing protected fraction of the potential KBA site
- KBA-MPA intersection computation script (`src/export_kba_mpa_intersection.R`)
- KBA-MPA intersection figure script (`src/plot_kba_mpa_intersection.R`)
- KBA red polygon figure script (`src/plot_potential_kba_guadalupe.R`)
- Map of longline fishing events from Global Fishing Watch data
- KBA and KBA-MPA figures registered in `results_first_paper` group target

### Changed

- Makefile and analyses.json synchronised with current pipeline
- Pipeline intermediate artifacts renamed: `cache_*.rds` to `representative_assessment_*.rds`, `ud_polygons_*.gpkg` to `individual_kde_*.rds`
- `create_processed_data` split into `create_individual_kde` + `create_representative_assessment`
- All `src/` scripts reformatted to match the ISLAS style guide (linear code, Spanish per-line comments, imperative headers, 4 standard sections)
- KBA map bounding box unified to zoom-in extent for visual consistency between companion figures
- MPA layer colour changed from blue to green; EEZ changed to outline-only on intersection map

### Fixed

- Stale default paths in standalone scripts
- Missing Make rule for `data/processed/cache_guadalupe.rds` intermediate target

## [v0.1.0] - 2026-05-17

### Added

- DOCS.md with Makefile target reference and pipeline stage documentation
- First CHANGELOG.md entry

### Fixed

- Makefile now regenerates mustache templates when source `.md` files are edited
- `results_first_paper` now declares missing Mexico EEZ zoom images as prerequisites
- Clarion individual KDE PNG removed from Makefile (function removed upstream, no paper references it)

### Changed

- Makefile updated to use bycatch v0.9.0 renamed functions:
  - `write_trips` to `create_trips`
  - `write_trips_summary` to `create_trips_summary`
  - `plot_individual_kernels` to `create_individual_kde` + `render_individual_kde`
  - `plot_representative_assess` to `create_processed_data` + `render_representative_assessment`
  - `plot_potential_site` to `create_potential_kba` + `render_potential_kba`
- Pipeline split into compute (`create_*`) and visualize (`render_*`) phases with intermediate artifacts in `data/processed/`
- PNG filenames updated to match renamed functions
- Paper image paths updated in `15_results.md`, `25_results.md`, and `first_paper.mustache`
- `first_paper.mustache` dependency fixed: now tracks source `.md` files via `$(wildcard)`

### Removed

- Clarion individual KDE PNG target (unreferenced in any paper, function removed)

[Unreleased]: https://github.com/IslasGECI/bycatch_thesis/compare/v0.2.0...HEAD
[v0.2.0]: https://github.com/IslasGECI/bycatch_thesis/releases/tag/v0.2.0
[v0.1.0]: https://github.com/IslasGECI/bycatch_thesis/releases/tag/v0.1.0
