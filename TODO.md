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

After bycatch_code Phase 2 (write/render separation), `render_*`
function signatures will change further — they will accept
`--artifact-path` instead of `--data-path` and `--config-path`.
This will require additional Makefile updates at that time.

Sprint 7 will change `create_*` signatures from the current
`options`-list convention to explicit parameters (`data_path`,
`config_path`, `output_path`, etc.).

