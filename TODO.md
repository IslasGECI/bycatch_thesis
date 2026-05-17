# Issue #47: Update Makefile after bycatch_code renames

`bycatch_code` renamed six public functions (current HEAD). The
`bycatch_thesis/Makefile` must be updated to match.

## Rename map

### 1. `bycatch::plot_potential_site` → `bycatch::render_potential_kba`

**Recipe calls** (replace function name only):

| Line | Current | Fixed |
|------|---------|-------|
| 121 | `bycatch::plot_potential_site(...)` | `bycatch::render_potential_kba(...)` |
| 136 | `bycatch::plot_potential_site(...)` | `bycatch::render_potential_kba(...)` |

**Filenames** (rename target + all prerequisite references):

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 51, 117–128 | `...potential_site_ars_guadalupe.png` | `...potential_kba_ars_guadalupe.png` |
| 61, 132–143 | `...potential_site_ars_all.png` | `...potential_kba_ars_all.png` |

---

### 2. `bycatch::plot_representative_assess` → `bycatch::render_representative_assessment`

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 149 | `bycatch::plot_representative_assess(...)` | `bycatch::render_representative_assessment(...)` |
| 161 | `bycatch::plot_representative_assess(...)` | `bycatch::render_representative_assessment(...)` |

**Filenames:**

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 52, 145–155 | `...representative_assess_ars_guadalupe.png` | `...representative_assessment_ars_guadalupe.png` |
| 62, 157–167 | `...representative_assess_ars_all.png` | `...representative_assessment_ars_all.png` |

---

### 3. `bycatch::plot_individual_kernels` → `bycatch::render_individual_kde`

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 173 | `bycatch::plot_individual_kernels(...)` | `bycatch::render_individual_kde(...)` |
| 184 | `bycatch::plot_individual_kernels(...)` | `bycatch::render_individual_kde(...)` |
| 195 | `bycatch::plot_individual_kernels(...)` | `bycatch::render_individual_kde(...)` |

**Filenames:**

| Line(s) | Current | Suggested |
|---------|---------|-----------|
| 50, 169–178 | `...individuals_kernel_ars_guadalupe.png` | `...individual_kde_ars_guadalupe.png` |
| 60, 191–200 | `...individuals_kernel_ars_all.png` | `...individual_kde_ars_all.png` |
| 69, 180–189 | `...individuals_kernel_ars_clarion.png` | `...individual_kde_ars_clarion.png` |

### 4. `bycatch::filter_data_between_dates` → `bycatch::create_filtered_gps_between_dates`

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 257 | `bycatch::filter_data_between_dates(...)` | `bycatch::create_filtered_gps_between_dates(...)` |

---

### 5. `bycatch::write_trips` → `bycatch::create_trips`

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 291 | `bycatch::write_trips(...)` | `bycatch::create_trips(...)` |
| 299 | `bycatch::write_trips(...)` | `bycatch::create_trips(...)` |

---

### 6. `bycatch::write_trips_summary` → `bycatch::create_trips_summary`

**Recipe calls:**

| Line | Current | Fixed |
|------|---------|-------|
| 313 | `bycatch::write_trips_summary(...)` | `bycatch::create_trips_summary(...)` |
| 321 | `bycatch::write_trips_summary(...)` | `bycatch::create_trips_summary(...)` |

## Scope

| Change type | Count |
|-------------|-------|
| `Rscript -e` function calls to rename (items 1–3) | 7 |
| `Rscript -e` function calls to rename (items 4–6) | 5 |
| Output filename / target name renames (items 1–3) | 7 |
| Total | ~19 |

## Upcoming Makefile impact

### Sprint 5 — Render functions now read pre-computed artifacts

`render_*` functions no longer run the R6 class pipeline. Instead,
each reads a pre-computed artifact:

| Function | Reads | Writes |
|---|---|---|
| `render_representative_assessment` | `.rds` cache (`rds-path`) | `.png` |
| `render_potential_kba` | `.gpkg` KBA polygons (`gpkg-path`) | `.png` |
| `render_individual_kde` | `.gpkg` UDPolygons (`gpkg-path`) | `.png` |

The options list for all three now requires only `rds-path` or
`gpkg-path` in addition to `output-path`. The `data-path` and
`config-path` arguments are no longer needed for render calls.

### (Removed — the `options` convention is permanent)

All Level 2 functions (`create_*`, `render_*`) permanently use the
`(options)` list pattern via `get_domain_specific_options()`. No
signature cleanup sprint is planned.

### Sprint 6 — Internal restructuring (no Makefile impact)

Sprint 6 removed the R6 class `Track2KBA_Wrapper`, consolidated all
`compute_*` functions into `R/compute.R`, and inlined `compute_cache`
into `create_processed_data`. No exported function signatures changed.
The Makefile does not need updating for Sprint 6.

