# Issue #47: Update after renames in bycatch_code


The following `Makefile` targets and function calls will break after a rename in bycatch_code and must be updated:

| Current call | After Phase 1 | Affected Makefile target(s) |
|---|---|---|
| `bycatch::plot_potential_site(...)` | `bycatch::render_potential_kba(...)` | `gps_albatross_50_percent_potential_site_ars_*.png` |
| `bycatch::plot_representative_assess(...)` | `bycatch::render_representative_assessment(...)` | `gps_albatross_50_percent_representative_assess_ars_*.png` |
| `bycatch::plot_individual_kernels(...)` | `bycatch::render_individual_kde(...)` | `gps_albatross_50_percent_individuals_kernel_ars_*.png` |

After Phase 2, the `render_*` function signatures will change further
(they will accept `--artifact-path` instead of `--data-path` and
`--config-path`). This will require additional updates in
`bycatch_thesis/Makefile` at that time.

