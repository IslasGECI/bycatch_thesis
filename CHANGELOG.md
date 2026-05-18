# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- PNG filenames updated to match renamed functions:
  - `individuals_kernel` to `individual_kde`
  - `representative_assess` to `representative_assessment`
  - `potential_site` to `potential_kba`
- Paper image paths updated in `15_results.md`, `25_results.md`, and `first_paper.mustache`
- `first_paper.mustache` dependency fixed: now tracks source `.md` files via `$(wildcard)`

### Removed

- Clarion individual KDE PNG target (unreferenced in any paper, function removed)

[v0.1.0]: https://github.com/IslasGECI/bycatch_thesis/releases/tag/v0.1.0
