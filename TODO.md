# Issue #47: Update Makefile after bycatch_code renames

`bycatch_code` v0.8.0 renamed three public functions. The
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
| `Rscript -e` function calls to rename (items 1–3) | 9 |
| `Rscript -e` function calls to rename (items 4–6) | 4 |
| Output filename / target name renames (items 1–3) | 8 |
| Total | ~21 |

## Future impact

After bycatch_code Phase 2 (write/render separation), `render_*`
function signatures will change further — they will accept
`--artifact-path` instead of `--data-path` and `--config-path`.
This will require additional Makefile updates at that time.

Sprint 4 adds four new `create_*` exported functions (`create_processed_data`,
`create_individual_kde`, `create_potential_kba`, `create_representative_assessment`),
expanding the artifact pipeline beyond the current CLI entries. These follow the
current `options`-list convention; Sprint 7 will change their signatures to
explicit parameters (`data_path`, `config_path`, `output_path`, etc.).

### Sprint 3 — Plot layer added (2026-05-16)

Sprint 3 adds three internal `plot_*` functions in `R/plot.R`:
`plot_representative_assessment`, `plot_potential_kba`, and
`plot_individual_kde`. These are Level 1 Pure functions (in-memory ggplot2,
no I/O, no side effects). They are NOT exported — `render_*` functions will
be restructured in Sprint 5 to use them instead of `track2KBA` base-R
plots. No immediate Makefile impact.

### Sprint 4 — Cache exports added (2026-05-16)

Sprint 4 adds four exported `create_*` functions in `R/cli.R`:
`create_individual_kde`, `create_processed_data`, `create_potential_kba`,
and `create_representative_assessment`. These follow the current `options`-list
convention. The `create_potential_kba` test is inherently slow (~5 min) because
it calls `findSite`; it lives in `tests/testthat/test_cache.R` but may be moved
to `slow/` later.

