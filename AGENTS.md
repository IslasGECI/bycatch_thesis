# Developer Manual

This document outlines the technical architecture, operational guidelines, and engineering standards for the `bycatch_thesis` project.

---

## 1. Technical Overview

### Build System
- **Primary**: `make` (Makefile-driven).
- **Docker**: `docker-compose run --rm islasgeci` or build image from `Dockerfile`.
- **Container image**: `islasgeci/bycatch_thesis:latest` (extends `islasgeci/bycatch`).

### Key Commands
```bash
make reports/first_paper.pdf  # Build first article
make reports/second_paper.pdf # Build second article
make articles                # Build all articles
make maps                    # Build Mexico map figures only
make clean                   # Remove all generated files
make format                  # Style R code with styler
shellspec                    # Run shell tests (ShellSpec)
```

### Docker Requirements
- `BITBUCKET_USERNAME` and `BITBUCKET_PASSWORD` env vars (secrets in CI) for data access.
- `DOCKER_USERNAME`/`DOCKER_PASSWORD` for pushing images.

---

## 2. Architecture & Structure

This project follows the **Class 3 Repository Structure** inspired by Cookiecutter Data Science.

### Repository Layout
```
├── Dockerfile         <- Build the repository image.
├── Makefile           <- Orchestration for reports and data processing.
├── README.md          <- High-level overview and authoritative work definition.
├── AGENTS.md          <- Developer manual (this file).
├── TODO.md            <- Project backlog and roadmap.
├── analyses.json      <- Defines relationships between data, reports, and scripts.
├── data/
│   ├── external/      <- Third-party data.
│   ├── processed/     <- Processed data (CSV, GPKG, etc.).
│   └── raw/           <- Immutable original data.
├── references/        <- Articles, books, and BibTeX files.
├── reports/           <- Final outputs (PDF, Docx) and figures.
│   └── figures/       <- Generated visualizations.
├── src/               <- R analysis scripts and source code.
└── tests/             <- Shell and R tests for reproducibility.
```

### File Mappings
- **Markdown sources**: `1?_*.md` (Paper 1), `2?_*.md` (Paper 2) — concatenated by Makefile.
- **R analysis scripts**: `src/*.R`.
- **R package**: `bycatch::` functions from `IslasGECI/bycatch_code`.
- **Processed data**: `data/processed/*.csv`.

### Core Configuration
- **Makefile**: Must contain `all`, per-result blocks, and general-purpose phony rules.
- **analyses.json**: Authoritative source for data-script-report relationships.

---

## 3. Data Management

### Sources & Acquisition
- **Primary Source**: Private Bitbucket repos (requires credentials).
- **Download**: `make data/raw/gps-albatros-guadalupe.csv` uses the `descarga_datos` tool.
- **Vessel data**: `docker pull islasgeci/vessel_data:latest`.

### Integrity Rules
- **Raw data** must remain strictly immutable.
- **Processed data** should be shaped for analysis and modeling.
- Intermediate results belong in `data/processed/` or `reports/`.

---

## 4. Standards & Conventions

### Commit Messages
- Start with a **Gitmoji** (e.g., 🐛, ✨, ♻️).
- Use an imperative verb (e.g., "Add", "Fix").
- Prioritize explaining **why** the change was made.
- Limit lines to ≤ 80 characters.
- First line is a summary; separate from body with a blank line.

### Repository Content Rules
- Only **plain text** files (`csv`, `json`, `svg`, `tex`, etc.) are allowed.
- No binary files > 1 MB or > 10,000 lines.
- **Binary images** only if required for functionality and ≤ 256px. Prefer SVG.

### Coding Standards (R)
- **Style**: Tidyverse style.
- **Language**: English for variables/functions; Spanish for comments (focus on "why").
- **Script Structure**: Header, Configuration, Inputs, Process, and Output sections.
- **Linear Code Rule**: Prefer linear code; avoid functions/loops in main analysis scripts. Use file-based modularity.
- **Comment every line** in Spanish.

#### Script Header Format
```r
# ==========================================
# Título: (1 línea)
# Contexto (Por qué): (2–4 líneas)
# Descripción (Qué / Cómo): (3–6 líneas)
# Entradas: (Sin bullets, uno por línea)
# Salidas: (Sin bullets, uno por línea)
# Dependencias: (Un paquete por línea)
# Notas: (Opcional, máximo 4 bullets)
# ==========================================
```

### Documentation & Prose
- **Spanish prose**: `0?_*.md` files.
- **English prose**: `1?_*.md` files.
- **Wordlist**: Managed in `.github/config/.wordlist.txt`.

---

## 5. Quality Assurance

### CI Checks (on `develop` branch)
- **Spellcheck**: Spanish and English sources.
- **Sentence length**: ≤ 25 words.
- **Paragraph length**: ≤ 200 words.

### Testing Protocols
- **Reproducibility**: Tests must verify that results can be recreated from data.
- **Naming**: Tests start with `test_` and use only alphanumeric characters.

---

## 6. Documentation Strategy

| Filename | Audience | Contents | Domain | Cadence |
| :--- | :--- | :--- | :--- | :--- |
| **README.md** | User | **User Manual**: Overview, capabilities, and usage instructions. | Interface | Low |
| **AGENTS.md** | Developers | **Developer Manual**: Architecture, principles, and guidelines. | Architecture | Medium |
| **TODO.md** | Developers | **Backlog**: Pending tasks, bugs, and roadmap. | Roadmap | Very High |
