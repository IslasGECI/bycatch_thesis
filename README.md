# Bycatch risk assessment of the Laysan albatross in the Mexican Pacific

## Overview

This repository hosts the code and analytical workflows supporting a doctoral thesis on seabird–fishery interactions in the Mexican Pacific.
The project aims to quantify bycatch risk by integrating seabird tracking data, fisheries data, and spatial analysis.

Bycatch is a global conservation issue: approximately 25% of total fisheries catch is incidental, and albatrosses are highly vulnerable to longline and trawl fisheries.
Despite high fishing activity, significant information gaps remain in the Mexican Pacific.

## Research question

What is the bycatch risk of the Laysan albatross associated with commercial fishing in the Mexican Pacific?

**Hypothesis:**
Laysan albatross foraging areas overlap with fishing zones, increasing bycatch risk.

## Project structure

The project is organized into three analytical components:

* **Chapter I:** Identify key seabird areas and evaluate protection under MPAs
* **Chapter II:** Quantify spatial overlap with fisheries (potential risk)
* **Chapter III:** Identify behavioral interactions (effective risk)

## Data

* Seabird GPS tracking data
* Vessel Monitoring System (VMS) data (CONAPESCA)
* AIS data (Global Fishing Watch)

## Methods

* Kernel Density Estimation (utilization distributions)
* Spatial overlap metrics
* Behavioral classification (foraging vs transit)
* Fishing activity inference from vessel trajectories

## Workflow

1. Process tracking and vessel data
2. Estimate seabird space use
3. Quantify spatial overlap
4. Identify interaction events and risk

## Outputs

* Maps of key seabird areas
* Overlap and risk estimates
* Interaction hotspots
