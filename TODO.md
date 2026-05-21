# WORKING ON: Update Makefile for bycatch v0.9.2 pipeline changes

The `bycatch` R package has undergone a major pipeline refactoring
(v0.9.2-dev). Several exported functions changed their signatures,
output formats, and/or were removed entirely. The Makefile must be
updated to match.

## Summary of `bycatch` API changes

| What | Before (v0.9.0/0.9.1) | After (v0.9.2) |
|------|-----------------------|-----------------|
| `create_processed_data` | Exported function | **Removed** |
| `create_individual_kde` | Writes GeoPackage (UDPolygons only) | Writes RDS (`KDE_surface`, `UDPolygons`, `tracks`) |
| `create_individual_kde` options | `--config-path`, `--data-path`, `--output-path`, `--percentage-distribution`, `--smoothing-method` | **+`--trips-summary-path`** (required) |
| `create_potential_kba` options | `--rds-path`, **`--config-path`**, **`--data-path`**, `--output-path`, `--percentage-distribution`, **`--smoothing-method`**, `--population-size` | `--rds-path`, `--output-path`, `--percentage-distribution`, `--population-size` only (drops 3 flags) |
| `render_individual_kde` option | `--gpkg-path` | `--rds-path` |
| `create_trips_summary` | unchanged CLI | unchanged CLI |
| `create_representative_assessment` | Reads `assessment_summary`/`assessment_detail` RDS, writes CSV+datapackage.json | Reads individual KDE RDS, runs `repAssess`, writes assessment RDS |

## Required Makefile changes

### 1. Replace `create_processed_data` with two-step pipeline

Each `cache_<site>.rds` target was built by `create_processed_data`.
It must be **split** into two targets:

```makefile
# Step 1: Cache individual KDE (fast, no bootstrap)
data/processed/individual_kde_<site>.rds: \
    data/processed/trips_geographic_points_<site>.csv \
    config_trips_<site>.json \
    data/processed/trips_summary_<site>.csv     # NEW dependency
	$(checkDirectories)
	Rscript -e "bycatch::create_individual_kde(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_<site>.csv \
		--config-path config_trips_<site>.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--trips-summary-path data/processed/trips_summary_<site>.csv \
		--output-path $@

# Step 2: Run bootstrap assessment
data/processed/cache_<site>.rds: \
    data/processed/individual_kde_<site>.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_representative_assessment(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_<site>.rds \
		--percentage-distribution 50 \
		--n-iterations 314 \
		--output-path $@
```

> The `create_representative_assessment` function now **runs repAssess** itself
> (it replaced `create_processed_data`). Downstream consumers (`create_potential_kba`,
> `render_representative_assessment`) still read `cache_<site>.rds` and are unchanged.

### 2. Drop flags from `create_potential_kba` targets

Remove `--config-path`, `--data-path`, and `--smoothing-method`:

```makefile
data/processed/kba_polygons_guadalupe.gpkg: \
    data/processed/cache_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_potential_kba(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/cache_guadalupe.rds \
		--percentage-distribution 50 \
		--population-size 4390 \
		--output-path $@
```

### 3. Update `create_individual_kde` to RDS output

Replace `ud_polygons_<site>.gpkg` with `individual_kde_<site>.rds`.
Add `--trips-summary-path` dependency and flag.
Update the `render_individual_kde` target to read `--rds-path`:

```makefile
# Before:
data/processed/ud_polygons_guadalupe.gpkg: \
    data/processed/trips_geographic_points_guadalupe.csv \
    config_trips_guadalupe.json
# After:
data/processed/individual_kde_guadalupe.rds: \
    data/processed/trips_geographic_points_guadalupe.csv \
    config_trips_guadalupe.json \
    data/processed/trips_summary_guadalupe.csv
	...
	Rscript -e "bycatch::create_individual_kde(...)" \
		...
		--trips-summary-path data/processed/trips_summary_guadalupe.csv \
		--output-path $@
```

### 4. Update `render_individual_kde` to use `--rds-path`

```makefile
reports/figures/gps_albatross_50_percent_individual_kde_ars_guadalupe.png: \
    data/processed/individual_kde_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_individual_kde(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_guadalupe.rds \
		--output-path $@
```

### 5. Update target dependencies in `results_first_paper` / `results_second_paper`

Replace `.gpkg` references with `.rds`:

```makefile
results_first_paper: \
    ...
    data/processed/individual_kde_guadalupe.rds        # was ud_polygons_guadalupe.gpkg
    ...
```

### 6. No change needed for `create_trips_summary`

The `create_trips_summary` CLI signature (`--data-path`, `--config-path`,
`--output-path`) is unchanged.
