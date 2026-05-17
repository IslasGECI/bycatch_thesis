# Issue #47: Update Makefile after bycatch_code renames

`bycatch_code` v0.9.0 renamed six public functions and restructured
the pipeline. The `bycatch_thesis/Makefile` must be updated to match.

## Rename map

### 1. `bycatch::plot_potential_site` → `bycatch::render_potential_kba`

This step no longer computes KDE/KBA inline. A separate
`create_potential_kba` step must generate the `.gpkg` first.

**Recipe calls** (replace function name AND arguments):

| Line | Current | Fixed |
|------|---------|-------|
| 121 | `bycatch::plot_potential_site(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_guadalupe.csv` `--config-path config_trips_guadalupe.json` `--percentage-distribution 50` `--n-iterations 314` `--population-size 4390` `--smoothing-method scale_ARS` `--output-path $@` | `bycatch::render_potential_kba(bycatch::get_domain_specific_options())` `--gpkg-path <KBA-gpkg-for-guadalupe>` `--output-path $@` |
| 136 | same pattern with `_all` data, `config_trips_all.json`, `--population-size 4437` | `bycatch::render_potential_kba(bycatch::get_domain_specific_options())` `--gpkg-path <KBA-gpkg-for-all>` `--output-path $@` |

**Filenames** (rename target + all prerequisite references):

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 51, 117–128 | `...potential_site_ars_guadalupe.png` | `...potential_kba_ars_guadalupe.png` |
| 61, 132–143 | `...potential_site_ars_all.png` | `...potential_kba_ars_all.png` |

---

### 2. `bycatch::plot_representative_assess` → `bycatch::render_representative_assessment`

This step no longer computes bootstrap/assessment inline. A separate
`create_representative_assessment` step must generate the `.rds` cache
first.

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 149 | `bycatch::plot_representative_assess(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_guadalupe.csv` `--config-path config_trips_guadalupe.json` `--percentage-distribution 50` `--n-iterations 314` `--smoothing-method scale_ARS` `--output-path $@` | `bycatch::render_representative_assessment(bycatch::get_domain_specific_options())` `--rds-path <processed-data-rds-for-guadalupe>` `--output-path $@` |
| 161 | same pattern with `_all` data, `config_trips_all.json`, `--n-iterations 314` | `bycatch::render_representative_assessment(bycatch::get_domain_specific_options())` `--rds-path <processed-data-rds-for-all>` `--output-path $@` |

**Filenames:**

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 52, 145–155 | `...representative_assess_ars_guadalupe.png` | `...representative_assessment_ars_guadalupe.png` |
| 62, 157–167 | `...representative_assess_ars_all.png` | `...representative_assessment_ars_all.png` |

---

### 3. `bycatch::plot_individual_kernels` → `bycatch::render_individual_kde`

This step no longer computes KDE inline. A separate
`create_individual_kde` step must generate the `.gpkg` first.

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 173 | `bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_guadalupe.csv` `--config-path config_trips_guadalupe.json` `--percentage-distribution 50` `--smoothing-method scale_ARS` `--output-path $@` | `bycatch::render_individual_kde(bycatch::get_domain_specific_options())` `--gpkg-path <UD-gpkg-for-guadalupe>` `--output-path $@` |
| 184 | same pattern with `_clarion` data, `config_trips_clarion.json` | `bycatch::render_individual_kde(bycatch::get_domain_specific_options())` `--gpkg-path <UD-gpkg-for-clarion>` `--output-path $@` |
| 195 | same pattern with `_all` data, `config_trips_all.json` | `bycatch::render_individual_kde(bycatch::get_domain_specific_options())` `--gpkg-path <UD-gpkg-for-all>` `--output-path $@` |

**Filenames:**

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 50, 169–178 | `...individuals_kernel_ars_guadalupe.png` | `...individual_kde_ars_guadalupe.png` |
| 60, 191–200 | `...individuals_kernel_ars_all.png` | `...individual_kde_ars_all.png` |
| 69, 180–189 | `...individuals_kernel_ars_clarion.png` | `...individual_kde_ars_clarion.png` |

### 4. `bycatch::filter_data_between_dates` → `bycatch::create_filtered_gps_between_dates`

Arguments unchanged.

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 257 | `bycatch::filter_data_between_dates(bycatch::get_domain_specific_options())` `--data-path data/raw/gps-albatros-guadalupe.csv` `--start 2025-01-01` `--end 2025-12-31` `--date-column-name date` `--output-path $@` | `bycatch::create_filtered_gps_between_dates(bycatch::get_domain_specific_options())` `--data-path data/raw/gps-albatros-guadalupe.csv` `--start 2025-01-01` `--end 2025-12-31` `--date-column-name date` `--output-path $@` |

---

### 5. `bycatch::write_trips` → `bycatch::create_trips`

Arguments unchanged.

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 291 | `bycatch::write_trips(bycatch::get_domain_specific_options())` `--data-path data/raw/gps-albatros-guadalupe.csv` `--config-path config_trips_guadalupe.json` `--output-path $@` | `bycatch::create_trips(bycatch::get_domain_specific_options())` `--data-path data/raw/gps-albatros-guadalupe.csv` `--config-path config_trips_guadalupe.json` `--output-path $@` |
| 299 | same pattern with `_clarion` data, `config_trips_clarion.json` | `bycatch::create_trips(bycatch::get_domain_specific_options())` `--data-path data/raw/gps-albatros-clarion.csv` `--config-path config_trips_clarion.json` `--output-path $@` |

---

### 6. `bycatch::write_trips_summary` → `bycatch::create_trips_summary`

Arguments unchanged.

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 313 | `bycatch::write_trips_summary(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_guadalupe.csv` `--config-path config_trips_guadalupe.json` `--output-path $@` | `bycatch::create_trips_summary(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_guadalupe.csv` `--config-path config_trips_guadalupe.json` `--output-path $@` |
| 321 | same pattern with `_clarion` data, `config_trips_clarion.json` | `bycatch::create_trips_summary(bycatch::get_domain_specific_options())` `--data-path data/processed/trips_geographic_points_clarion.csv` `--config-path config_trips_clarion.json` `--output-path $@` |

## New Makefile rules needed

The pipeline split means four new intermediate artifacts are needed:

| Artifact | Created by | Options | Consumed by |
|---|---|---|---|
| `.rds` cache (per island) | `create_processed_data` | `--data-path`, `--config-path`, `--percentage-distribution`, `--smoothing-method`, `--n-iterations`, `--output-path` | `create_potential_kba`, `create_representative_assessment` |
| `.gpkg` KBA polygons (per island) | `create_potential_kba` | `--rds-path`, `--config-path`, `--data-path`, `--percentage-distribution`, `--smoothing-method`, `--population-size`, `--output-path` | `render_potential_kba` |
| `.gpkg` UD polygons (per island) | `create_individual_kde` | `--data-path`, `--config-path`, `--percentage-distribution`, `--smoothing-method`, `--output-path` | `render_individual_kde` |
| `.csv` assessment detail (per island) | `create_representative_assessment` | `--rds-path`, `--output-path` | (not consumed by render) |

These are not `bycatch::` calls currently present in the Makefile.
They must be added as new targets and prerequisites.

### Proposed intermediate file names

| Island | `.rds` cache | `.gpkg` KBA | `.gpkg` UD | `.csv` assessment |
|---|---|---|---|---|
| Guadalupe | `data/processed/cache_guadalupe.rds` | `data/processed/kba_polygons_guadalupe.gpkg` | `data/processed/ud_polygons_guadalupe.gpkg` | `data/processed/assessment_detail_guadalupe.csv` |
| Clarion | `data/processed/cache_clarion.rds` | `data/processed/kba_polygons_clarion.gpkg` | `data/processed/ud_polygons_clarion.gpkg` | `data/processed/assessment_detail_clarion.csv` |
| All | `data/processed/cache_all.rds` | `data/processed/kba_polygons_all.gpkg` | `data/processed/ud_polygons_all.gpkg` | `data/processed/assessment_detail_all.csv` |

## Paper references affected

The renamed PNGs are embedded in the paper markdown sources. These must
be updated in sync with the Makefile filename renames.

| File | Old path | New path |
|------|----------|----------|
| `papers/first-paper/15_results.md` | `...individuals_kernel_ars_guadalupe.png` | `...individual_kde_ars_guadalupe.png` |
| `papers/first-paper/15_results.md` | `...potential_site_ars_guadalupe.png` | `...potential_kba_ars_guadalupe.png` |
| `papers/first-paper/15_results.md` | `...representative_assess_ars_guadalupe.png` | `...representative_assessment_ars_guadalupe.png` |
| `papers/first-paper/first_paper.mustache` | (same 3 paths, inherited from template) | (same renames) |
| `papers/second-paper/25_results.md` | `...individuals_kernel_ars_all.png` | `...individual_kde_ars_all.png` |
| `papers/second-paper/25_results.md` | `...potential_site_ars_all.png` | `...potential_kba_ars_all.png` |
| `papers/second-paper/25_results.md` | `...representative_assess_ars_all.png` | `...representative_assessment_ars_all.png` |

## Execution plan

One PNG at a time. Each loop: Red → Green → commit.

1. `make <png>` fails (Red)
2. Implement minimum changes for that one PNG (Green)
3. Commit

The simplest PNG has the shortest dependency chain, so we start there
and build up. PNGs are grouped by the `create_*` function they need:

| Order | PNG | Old function | New `create_*` dep | `create_processed_data` needed? |
|-------|-----|-------------|-------------------|-------------------------------|
| 1 | `...individual_kde_ars_guadalupe.png` | `plot_individual_kernels` | `create_individual_kde` | No |
| 2 | `...individual_kde_ars_clarion.png` | `plot_individual_kernels` | `create_individual_kde` | No |
| 3 | `...individual_kde_ars_all.png` | `plot_individual_kernels` | `create_individual_kde` | No |
| 4 | `...representative_assessment_ars_guadalupe.png` | `plot_representative_assess` | `create_representative_assessment` | Yes |
| 5 | `...representative_assessment_ars_all.png` | `plot_representative_assess` | `create_representative_assessment` | Yes |
| 6 | `...potential_kba_ars_guadalupe.png` | `plot_potential_site` | `create_potential_kba` | Yes |
| 7 | `...potential_kba_ars_all.png` | `plot_potential_site` | `create_potential_kba` | Yes |

### Loop 1: `...individual_kde_ars_guadalupe.png`

Changes A–F in one shot for this single PNG:

| Letter | Change | Files affected |
|--------|--------|---------------|
| A | Rename `write_trips` → `create_trips` (Guadalupe recipe only) | `Makefile` line 291 |
| B | Add `ud_polygons_guadalupe.gpkg` target calling `create_individual_kde` | `Makefile` new rule |
| C | Update PNG target prerequisite: `.csv` → `.gpkg` | `Makefile` line 169 |
| D | Update PNG recipe: `render_individual_kde` with `--gpkg-path` | `Makefile` lines 173–178 |
| E | Rename PNG filename: `individuals_kernel` → `individual_kde` | `Makefile` lines 50, 169 (target name + preref ref) |
| F | Update paper image paths to match new PNG name | `papers/first-paper/15_results.md` (`.mustache` is auto-generated) |

Subsequent loops follow the same pattern but may also need to add
`create_processed_data` targets (when `cache_*.rds` is required).

## Scope

| Change type | Count |
|-------------|-------|
| `Rscript -e` function calls to rename (items 1–3) | 7 |
| `Rscript -e` function calls to rename (items 4–6) | 5 |
| Makefile output filename / target name renames (items 1–3) | 7 |
| Paper markdown image path renames (items 1–3) | 6 |
| New `create_*` targets to add (3 islands × ~4 functions) | ~12 |
| Total | ~37 |

