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
shellspec                    # Run shell tests (ShellSpec)
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

| Level | File | Audience | Focus |
| :--- | :--- | :--- | :--- |
| **User** | `README.md` | General Users | What the project is and how to use it. |
| **Developer** | `AGENTS.md` | Developers | How to build, code, and contribute (this file). |
| **Roadmap** | `TODO.md` | Team | What needs to be done next. |
