# Bycatch risk assessment of the Laysan albatross in the Mexican Pacific

## What it does

This project analyzes how the foraging areas of Laysan albatrosses overlap with commercial fishing zones in the Mexican Pacific. It produces maps, risk estimates, and scientific manuscripts as PDFs and figures.

## How to use it

The main outputs are two scientific articles:

1. **First paper** — identifies key seabird areas (KBAs) and evaluates their coverage by marine protected areas
2. **Second paper** — quantifies spatial overlap between albatross space use and fishing activity

To generate the first article:

```bash
make reports/first_paper.pdf
```

To generate the second article:

```bash
make reports/second_paper.pdf
```

To generate all figures and articles:

```bash
make articles
```

To build only the Mexico reference maps:

```bash
make maps
```

## Before you start

You need access credentials for the data sources:

- **BITBUCKET_USERNAME** and **BITBUCKET_PASSWORD** — for downloading seabird GPS tracking data

## Run the project

**With Docker (recommended):**

```bash
docker-compose run --rm islasgeci
```

Inside the container, run any `make` command.

**Without Docker:**

Install R and the required packages from `Dockerfile`, then run:

```bash
make articles
```

## Coming soon

- Bycatch risk maps from vessel monitoring system (VMS) data
- Interaction hotspot identification from AIS vessel trajectories
- Behavioral classification of foraging versus transit events
