# Developer Manual (AGENTS.md)

This document provides a workflow-oriented guide to the technical architecture, operational procedures, and engineering standards for the `bycatch_thesis` project.

---

## Phase 1: Environment Setup & Operations

### Build System
- **Primary**: `make` (Makefile-driven).
- **Docker**: `docker-compose run --rm islasgeci` or build image from `Dockerfile`.
- **Container image**: `islasgeci/bycatch_thesis:latest`.

### Initial Configuration
- **Credentials**: Set `BITBUCKET_USERNAME` and `BITBUCKET_PASSWORD` as environment variables for data access.
- **Docker Registry**: Set `DOCKER_USERNAME`/`DOCKER_PASSWORD` for pushing images.

### Key Operational Commands
```bash
make reports/first_paper.pdf  # Build first article
make reports/second_paper.pdf # Build second article
make articles                # Build all articles
make maps                    # Build Mexico map figures only
make clean                   # Remove all generated files
make format                  # Style R code with styler

# Build artifacts incrementally, one PNG at a time:
make reports/figures/gps_albatross_50_percent_individual_kde_ars_guadalupe.png
make reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe.png
make reports/figures/gps_albatross_50_percent_representative_assessment_ars_guadalupe.png

# Verify bycatch functions exist in installed package:
Rscript -e "library(bycatch); exists('create_individual_kde', where='package:bycatch', mode='function')"
```

---

## Phase 2: Data Lifecycle & Acquisition

### 1. Data Acquisition
- **Download**: `make data/raw/gps-albatros-guadalupe.csv` (uses `descarga_datos`).
- **External Dependencies**: `docker pull islasgeci/vessel_data:latest`.

### 2. Integrity Rules
- **Raw Data**: Must remain strictly **immutable** in `data/raw/`.
- **Processed Data**: Resides in `data/processed/`, shaped specifically for modeling.

### 3. Traceability
- **analyses.json**: The authoritative map of data-script-report relationships.
- **Makefile**: Defines the specific rules for transforming data into results.

### 4. Pipeline Pattern (bycatch v0.9.0+)
The bycatch package splits computation and visualization into two phases:
- `create_*()`: Performs computation, writes intermediate artifact to `data/processed/` (`.rds`, `.gpkg`, `.csv`).
- `render_*()`: Reads intermediate artifact, produces PNG in `reports/figures/`.

Makefile targets follow the same split: an intermediate artifact target (e.g. `data/processed/ud_polygons_guadalupe.gpkg`) feeds into the PNG target (`reports/figures/gps_albatross_50_percent_individual_kde_ars_guadalupe.png`).

### 5. Make Dependency Gotchas
- **`.PHONY` targets without recipes**: Make will not cascade to their prerequisites unless a recipe (even `@true`) exists. Always verify that group targets (`results_first_paper`, `results_second_paper`, etc.) have a recipe when listed in `.PHONY`.
- **Source file dependencies**: Rules that concatenate glob patterns (e.g. `cat papers/first-paper/1?_*.md`) must list the actual files as prerequisites using `$(wildcard ...)`. Otherwise Make won't detect edits to source files.
- **Intermediate artifact prerequisites**: PNG render targets depend on intermediate `.gpkg` or `.rds` files, not on the raw CSV data. The dependency chain is: raw data → `create_*()` → intermediate → `render_*()` → PNG.
- **Option flag availability**: The `get_domain_specific_options()` parser defines a fixed set of flags. As of bycatch v0.9.1 it includes `--gpkg-path` and `--rds-path` (added for render functions). Earlier versions do not.

---

## Phase 3: Development & Coding Standards

### 1. Repository Architecture (Class 3)
Scripts and content must be placed according to the project map:
- `src/`: R analysis scripts.
- `reports/figures/`: Generated visualizations.
- `references/`: BibTeX and articles.
- `1?_*.md` / `2?_*.md`: Manuscript sources (Paper 1 and 2).

### 2. Coding in R
- **Style**: Tidyverse.
- **Linear Rule**: Write linear code in analysis scripts; avoid complex loops or functions.
- **Language**: English for code (variables/functions); Spanish for comments.
- **Documentation**: Comment **every line** in Spanish, focusing on the "why".

### 3. Script Structure
Every script in `src/` must follow this header format:
```r
# ==========================================
# Título: (1 línea)
# Contexto (Por qué): (2–4 líneas)
# Descripción (Qué / Cómo): (3–6 líneas)
# Entradas: (Uno por línea)
# Salidas: (Uno por línea)
# Dependencias: (Un paquete por línea)
# Notas: (Opcional, máximo 4 bullets)
# ==========================================
```

### 4. Repository Content Policy
- **Text Only**: Only plain text files allowed (CSV, JSON, SVG, TeX).
- **Binary Limits**: Images only if ≤ 256px and necessary. No files > 1 MB.

---

## Phase 4: Validation, Testing & Commits

### 1. Quality Assurance (CI)
Before pushing to `develop`, ensure your prose meets these standards:
- **Spellcheck**: Passing for both English and Spanish.
- **Constraint**: ≤ 25 words per sentence; ≤ 200 words per paragraph.

### 2. Testing
- **Reproducibility**: All results must be reproducible from the raw data.
- **Naming**: Test files must start with `test_` and use alphanumeric names.

### 3. Commitment (Gitmoji)
Commits must follow the project's semantic style:
- **Format**: `[Emoji] [Imperative Verb] [Summary]`
- **Example**: `✨ Add kernel density estimation for Clarion Island`
- **Priority**: Explain **why** the change was made in the message body.

---

## Documentation Strategy Summary

| File | Level | Audience | Focus |
| :--- | :--- | :--- | :--- |
| `README.md` | **User** | General Users | What the project is and how to use it. |
| `AGENTS.md` | **Developer** | Developers | How to build, code, and contribute (this file). |
| `TODO.md`   | **Roadmap** | Team | What needs to be done next. |

---

## Task Management: The Gold Workflow

This project uses a **"Gold" workflow** inspired by Test-Driven Development's concept of *grabbing for the gold* (Kent Beck, *TDD By Example*).

In TDD, **"the gold"** is a clear specification of target behavior reached through small, incremental steps: Red → Green → Refactor.

This project applies that same concept to task management:

### Definitions

| Term | Meaning |
|------|---------|
| **Gold** | A GitHub Issue containing a collection of related tasks that represent a target behavior or deliverable |
| **TODO.md** | The active workspace that shows ONLY the tasks for the Gold you're currently working on |
| **Task** | One small, completable step toward reaching the Gold |

### How It Works

```
┌─────────────────────────────────────────────────┐
│        GitHub Issues (Permanent Gold Store)     │
├─────────────────────────────────────────────────┤
│ Issue #1: "Write Methods Section" [GOLD]        │
│   ├── [ ] Add site selection justification      │
│   └── [ ] Explain oceanographic context         │
│                                                 │
│ Issue #2: "ANP Intersection Analysis" [GOLD]    │
│   ├── [ ] Define overlap index formula          │
│   └── [ ] Specify vector vs raster approach     │
└─────────────────────────────────────────────────┘
                        ↓
              (You pick a Gold to work on)
                        ↓
┌─────────────────────────────────────────────────┐
│         TODO.md (Active Workspace)              │
│  = The Gold you're grabbing for RIGHT NOW       │
├─────────────────────────────────────────────────┤
│ # WORKING ON: Issue #2 - ANP Intersection       │
│                                                 │
│ - [ ] Define overlap index formula              │
│ - [ ] Specify vector vs raster approach         │
│                                                 │
│ # DONE                                          │
│ - [x] (completed tasks)                         │
└─────────────────────────────────────────────────┘
                        ↓
              [TDD Cycle: Red-Green-Refactor]
              [Complete one task at a time]
              [Until you reach the Gold]
```

### The Workflow

1. **Choose a Gold**: Pick a GitHub Issue to work on
2. **Load TODO.md**: Copy that issue's tasks into TODO.md (replacing previous content)
3. **Grab for the Gold**: Work through each task using TDD cycles
4. **Mark Progress**: Check off tasks in both TODO.md and the GitHub Issue
5. **Switching Golds**: When done (or changing focus), replace TODO.md with the new issue's tasks
6. **Cleanup**: Before switching Golds, ensure all completed tasks in TODO.md are marked as complete in the GitHub Issue (the Permanent Gold Store), then clear TODO.md.

### Why This Works

| Benefit | Explanation |
|---------|--------------|
| **Focus** | TODO.md shows only ONE Gold at a time — no clutter |
| **Clarity** | The Gold (Issue) defines exactly what "done" looks like |
| **TDD-Aligned** | Small tasks = small increments = Red-Green-Refactor |
| **Traceability** | GitHub Issues are permanent; TODO.md is ephemeral workspace |
| **Flexibility** | Switch Golds anytime by updating TODO.md |

### Summary

> **GitHub Issues are Golds. TODO.md is the Gold you're grabbing for right now.**

