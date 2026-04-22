# Materials

## Site description

Seabirds breed on islands, which are designated as protected natural areas.
Because seabirds are marine organisms that return to land only to reproduce, tracking devices were deployed during the breeding period at the colony.

We attached GPS units to 48 Laysan albatross individuals on Guadalupe Island between 2014 and 2018, and to 10 additional individuals in 2025.

### Guadalupe Island

Guadalupe Island is located 300 km west of the Baja California peninsula.
It is an oceanic island of volcanic origin, with an area of 244 km$^2$ and a maximum length of 30 km.
Its position within the California Current system enables the albatrosses breeding on the island to forage in productive waters, which is crucial for the breeding success of seabirds.

Guadalupe Island hosts the largest breeding colony of Laysan albatrosses in the eastern Pacific [@hernandez2019sexual].
The colony size makes it suitable for identifying population-level core use areas, as it represents a substantial fraction of the regional population.
Eastern Pacific colonies also exhibit distinct foraging patterns, supporting its representativeness for the region.

During the breeding season, Laysan albatrosses commute between the colony and the feeding areas.
This behavior allows repeated trips from a fixed location, enabling the identification of recurrent key-use areas from tracking data.

Studying individuals from this colony therefore enables the identification of core foraging areas and the assessment of their spatial overlap with Protected Natural Areas (ANPs), including the Guadalupe Island Biosphere Reserve.

### Feeding areas

The feeding area of the Laysan albatrosses nesting on Guadalupe Island is affected by the California Current.
Additionally, the entire study area is affected by El Niño Southern Oscillation (ENSO) events.

### Time period

The data were collected from 2014 to 2026.
During this period, the study site was affected by the "Blob".

A time period of more than a decade allows us to account for interannual variability in the use of key areas by Laysan albatrosses.

## Study species or system

We are studying the key area used by Laysan albatrosses in the Mexican Pacific and its overlap with protected natural areas (ANP).
In particular, we focus on the albatrosses that nest on Guadalupe Island.

Albatrosses are seabirds.
Seabirds are marine organisms.
They are on land only during their reproductive stage.
During the reproductive and nesting season, they make foraging trips.
They are at the nest, make a foraging trip, and return to the nest.

Seabirds are top predators and serve as umbrella species.
If the ANPs serve to protect these species, we can infer that they serve to protect the marine ecosystem.

## Ethical considerations and permits

The study was conducted under the permits from the following institutions:
Ministry of the Interior, Ministry of Environment and Natural Resources, and the National Commission for Protected Natural Areas.

No albatross individuals were harmed during the study.

## Data collection

We attached the GPS to the albatrosses.
The GPS loggers were attached to the albatross individuals with Tesa tape (#4651, Tesa AG, Hamburg, Germany).

In Guadalupe Island we used the following GPS devices: From 2014 to 2016: model GiSPy-4SB by Techno Smart (Italy).
From 2017 to 2018: i-gotU model GT-120 by Mobile Action (Taiwan).
From 2019 to 2023: XXX In 2025: GPS datalogger with accelerometer and UHF model Axy-Trek Remote by Techno Smart (Italy).

# Experimental design

## Specific questions

- We aim to identify the key areas used by Laysan albatrosses in the Mexican Pacific.
- We also aim to determine whether these key areas overlap with existing ANPs.

### Key areas used by Laysan albatrosses

From the GPS trajectories, we calculated kernel density estimation (KDE) to define the key areas.

The independent variable is the GPS locations of the albatrosses.
The dependent variable is the key areas used by the albatrosses.


A total of 114 individuals were tracked in Guadalupe Island between 2014 and 2025.

| Year | Number of individuals |
| ---- | --------------------- |
| 2014 | 15 |
| 2015 |  4 |
| 2016 |  2 |
| 2017 |  6 |
| 2018 | 20 |
| 2019 | 36 |
| 2020 |  5 |
| 2021 |  5 |
| 2022 |  4 |
| 2023 |  7 |
| 2025 | 10 |

### Overlap of key areas with ANPs

We calculated the overlap index to quantify the overlap of the key areas with the ANP polygons.

The independent variables are the key areas used by the albatrosses and the ANP polygons.
The dependent variable is the overlap index.

## Studies that support your methodology

We based our methodology on [@beal2021track2kba].

# Data analysis

## Data processing

We used the R package track2KBA.

Records are every 10 minutes.

## Statistical analyses

## Limitations and assumptions

One limitation is that the GPS data only correspond to the reproductive season.
We do not know if the key areas used by the albatrosses during the non-reproductive season are different.
However, it is during the reproductive season when the population could be most vulnerable.
