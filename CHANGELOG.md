# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/IslasGECI/bycatch_thesis/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/IslasGECI/bycatch_thesis/releases/tag/v0.1.0
