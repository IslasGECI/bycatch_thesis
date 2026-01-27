# Materials

## Site description

Seabirds nest on the islands.
The islands are protected natural areas.

Seabirds are marine organisms and are only found on land to reproduce.
To install remote tracking devices on seabirds, it is more feasible to do so when they are nesting,
that is, when they are located on an island.

We attached GPS units to 48 Laysan albatross individuals on Guadalupe Island from 2014 to 2018, and
to 10 individuals in 2025.
Additionally, we attached GPS units to 26 individuals on Clarion Island from 2018 to 2022.

### Guadalupe Island

Guadalupe Island is located 300 km west of the coast of Baja California.
It is an oceanic island of volcanic origin.
It has an area of 244 km$^2$.
It measures 30 km at its longest part from the southern end to the northern end.

Guadalupe Island hosts the largest breeding colony of Laysan albatrosses in the eastern Pacific
[@hernandez2019sexual].

### Isla Clarion

Clarion Island is the most remote of Mexico's Revillagigedo Islands.
It is located 700 kilometres from the Mexican mainland.
It has a tropical climate.
It has an area of 19.8 km$^2$.
It measures 8.6 km at its longest part from the eastern end to the western end.

### Feeding areas

The feeding area of the Laysan albatrosses nesting on Guadalupe Island and Clarion Island is affected by
the California Current.
Additionally, the entire study area is affected by El Niño and La Niña events.

### Time period

The data were collected from 2014 to 2025.
During this period, the study site was affected by the "Blob".

A time period of more than a decade allows us to account for interannual variability in the use of
key areas by Laysan albatrosses.

## Study species or system

We are studying the key area used by Laysan albatrosses in the Mexican Pacific and its overlap with
protected natural areas (ANP).
In particular, we focus on the albatrosses that nest on Guadalupe Island and Clarion Island.

Albatrosses are seabirds.
Seabirds are marine organisms.
They are on land only during their reproductive stage.
During the reproductive and nesting season, they make foraging trips.
They are at the nest, make a foraging trip, and return to the nest.

Seabirds are top predators and serve as umbrella species.
If the ANPs serve to protect these species, we can infer that they serve to protect the marine
ecosystem.

## Ethical considerations and permits

The study was conducted under the permits from the following institutions: Ministry of the Interior,
Ministry of Environment and Natural Resources, and the National Commission for Protected Natural
Areas.

No albatross individuals were harmed during the study.

## Data collection

We attached the GPS to the albatrosses.
The GPS loggers were attached to the albatross individuals with Tesa tape (#4651, Tesa AG, Hamburg,
Germany).

In Guadalupe Island we used the following GPS devices:
From 2014 to 2016: model GiSPy-4SB by TechnoSmart (Italy).
From 2017 to 2018: i-gotU model GT-120 by Mobile Action (Taiwan).
From 2019 to 2023: XXX
In 2025: GPS datalogger with accelerometer and UHF model AxyTrek Remote by TechnoSmart (Italy).

In Clarion Island, from 2018 to 2022 we used the following GPS devices:
i-gotU model GT-120 by Mobile Action (Taiwan).
CatLog-S, Catnip Technologies (China).
CatLog-S2, Perthold Engineering (USA).

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
| 2015 | 10 |

A total of 26 individuals were tracked in Clarion Island between 2018 and 2022.

| Year | Number of individuals |
| ---- | --------------------- |
| 2018 | 7 |
| 2019 | 9 |
| 2020 | 6 |
| 2022 | 4 |

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
We do not know if the key areas used by the albatrosses during the non-reproductive season are
different.
However, it is during the reproductive season when the population could be most vulnerable.
