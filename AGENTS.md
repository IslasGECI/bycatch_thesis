# bycatch_thesis

LaTeX thesis on Laysan albatross bycatch interactions with commercial fishing in the Mexican Pacific.

## Build system

- **Primary**: `make` (Makefile-driven)
- **Docker**: `docker-compose run --rm islasgeci` or build image from `Dockerfile`
- **Container image**: `islasgeci/bycatch_thesis:latest` (extends `islasgeci/bycatch`)

## Key commands

```bash
make reports/first_paper.pdf  # Build first article
make reports/second_paper.pdf # Build second article
make articles                # Build all articles
make maps                    # Build Mexico map figures only
make clean                   # Remove all generated files
make format                  # Style R code with styler
shellspec                    # Run shell tests (ShellSpec)
```

## Project structure

- **Markdown sources**: `1?_*.md` (paper 1), `2?_*.md` (paper 2) — concatenated by Makefile
- **Reports output**: `reports/*.pdf`, `reports/*.docx`
- **R analysis scripts**: `src/*.R`
- **R package**: `bycatch::` functions from `IslasGECI/bycatch_code`
- **Figures**: `reports/figures/*.png`
- **Processed data**: `data/processed/*.csv`
- **Raw data**: `data/raw/` (downloaded via `descarga_datos` tool)

## Data

- **Source**: Private Bitbucket repos (requires `BITBUCKET_USERNAME`/`BITBUCKET_PASSWORD`)
- **Download**: `make data/raw/gps-albatros-guadalupe.csv` etc. uses `descarga_datos`
- **Vessel data** (for paper 2): `docker pull islasgeci/vessel_data:latest`

## CI checks (on `develop` branch)

- **Spellcheck**: Spanish (`0?_*.md`) and English (`1?_*.md`)
- **Sentence length**: ≤25 words per sentence
- **Paragraph length**: ≤200 words per paragraph
- **Spellcheck config**: `.github/config/.spellcheck.yml`

## Markdown conventions

- Spanish prose: `0?_*.md` files
- English prose: `1?_*.md` files
- Wordlist: `.github/config/.wordlist.txt`

## Docker requirements

- `BITBUCKET_USERNAME` and `BITBUCKET_PASSWORD` env vars (secrets in CI)
- `DOCKER_USERNAME`/`DOCKER_PASSWORD` for pushing images
