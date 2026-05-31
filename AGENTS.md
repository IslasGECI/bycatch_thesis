# Developer Manual (AGENTS.md)

Workflow-oriented guide to the technical architecture, operational procedures, and engineering standards for the `bycatch_thesis` project.

## Environment Setup & Operations

### Build System
- **Primary**: `make` (Makefile-driven).
- **Docker**: `docker-compose run --rm islasgeci` or `docker exec bycatch_thesis_ci <command>` for running ad-hoc commands inside the already-running container.
- **Container image**: `islasgeci/bycatch_thesis:latest`.

### Initial Configuration
- **Credentials**: Set `BITBUCKET_USERNAME` and `BITBUCKET_PASSWORD` for data access.
- **Docker Registry**: Set `DOCKER_USERNAME`/`DOCKER_PASSWORD` for pushing images.

### Key Operational Commands
```bash
make reports/first_paper.pdf
make reports/second_paper.pdf
make articles
make maps
make clean
make format                                  # Style R code with styler
docker exec bycatch_thesis_ci make <target>  # Run a make target inside the container
docker exec bycatch_thesis_ci Rscript src/foo.R  # Run a script inside the container
```

### Make Dependency Gotchas
- **`.PHONY` targets without recipes**: Make will not cascade to their prerequisites unless a recipe (even `@true`) exists. Always verify that group targets have a recipe when listed in `.PHONY`.
- **Source file dependencies**: Rules that concatenate glob patterns (e.g. `cat papers/first-paper/1?_*.md`) must list actual files as prerequisites using `$(wildcard ...)`.
- **Intermediate artifact prerequisites**: PNG render targets depend on intermediate `.gpkg` or `.rds` files, not on raw CSV data. The chain is: raw data → `create_*()` → intermediate → `render_*()` → PNG.

## Data Lifecycle

- **Raw Data**: Immutable in `data/raw/`.
- **Processed Data**: In `data/processed/`, shaped for modeling.
- **Traceability**: `analyses.json` maps data-script-report relationships; `Makefile` defines transformation rules.
- **Pipeline Pattern**: Computation (`create_*()`) writes to `data/processed/`; visualization (`render_*()`) reads intermediate artifacts and writes PNGs to `reports/figures/`.
- **Custom scripts**: Some figures bypass the `bycatch` package and use `src/` scripts directly (e.g., `export_kba_mpa_intersection.R`, `plot_potential_kba_guadalupe.R`, `plot_kba_mpa_intersection.R`).

## Development & Coding Standards

### Script Structure (src/)
Every script must follow this header structure in Spanish, using imperative form (no infinitives):
```
# ==========================================
# Título: (1 línea)
# Contexto (Por qué): (2–4 líneas)
# Descripción (Qué / Cómo): (3–6 líneas)
# Entradas: (Uno por línea, sin bullets)
# Salida: (Uno por línea, sin bullets)
# Dependencias: (Un paquete por línea)
# Notas: (Opcional, máximo 4 bullets)
# ==========================================
```
Then: `# ==== CONFIGURACIÓN ====`, `# ==== ENTRADAS ====`, `# ==== PROCESAMIENTO / ANÁLISIS ====`, `# ==== SALIDA ====`.

### Style Rules
- **Full style reference**: https://islas.dev/guia_de_estilo/STYLEGUIDE
- **Code**: English variables, Tidyverse, linear (no functions/loops/if), comment every line in Spanish focusing on why.
- **Comments**: Spanish, per-line, explaining logic/reasoning not mechanics.
- **Script names**: Start with a verb, letters and numbers only.
- **Output**: Each script writes exactly one output file.

### Repository Content
- **Text only**: CSV, JSON, SVG, TeX, Markdown. No binaries > 1 MB.
- **Images**: Only if ≤ 256 px and necessary. PNGs excluded from git via `.gitignore`.

## Validation, Testing & Commits

### Quality Assurance
- `make check` runs spellcheck and manuscript style checks.
- **Spellcheck**: Passing for both English and Spanish.
- **Style**: ≤ 25 words per sentence, ≤ 200 words per paragraph.

### Commits (Gitmoji)
- Format: `[Emoji] [Imperative Verb] [Summary]` with blank line then body explaining why.
- Emoji examples: ➕ feature, 🗺️ map, 🎨 style/format, ✅ task tracking, 📝 docs.

## Task Management: The Gold Workflow

GitHub Issues define Golds (collections of related tasks). TODO.md is the active workspace showing only the current Gold. Tasks are completed one at a time using TDD cycles (Red → Green → Refactor). Completed tasks are checked off in TODO.md and synced to the GitHub Issue.

- **Gold**: A GitHub Issue with a set of related tasks.
- **TODO.md**: Shows ONLY the current Gold's tasks.
- **Switching Golds**: Replace TODO.md with the new issue's tasks after syncing completed ones.

## Documentation Map

| File | Audience | Focus |
|------|----------|-------|
| `README.md` | End Users | What the project is and how to use it |
| `AGENTS.md` | Developers | How to build, code, and contribute (this file) |
| `DOCS.md` | Developers | API, CLI, and data model reference |
| `CHANGELOG.md` | Developers | Version history following SemVer |
| `TODO.md` | Team | Current active Gold and backlog |
