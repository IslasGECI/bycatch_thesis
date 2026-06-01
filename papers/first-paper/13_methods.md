# Materials

## Site description

Seabirds nest on the islands.
The islands are protected natural areas.

Seabirds are marine organisms and are only found on land to reproduce.
Tracking devices are installed while individuals are breeding on the island.

We attached GPS units to XXX Laysan albatross individuals on Guadalupe Island from 2014 to 2026.
Additionally, we attached GPS units to 26 individuals on Clarion Island from 2018 to 2022.

### Guadalupe Island

Guadalupe Island is located 300 km west of the coast of Baja California.
It is an oceanic island of volcanic origin.
It has an area of 244 km$^2$.
It measures 30 km at its longest part from the southern end to the northern end.

Guadalupe Island hosts the largest breeding colony of Laysan albatrosses in the eastern Pacific [@hernandez2019sexual].
Guadalupe Island hosts the biggest colony in the Mexican Pacific.
This paper is about albatrosses in the Mexican EEZ.
The other colonies within the Mexican EEZ are smaller and not successful.
To determine the core areas (and the overlap with MPA/ANP) we have to study the most relevant colonies.
The most relevant colony is Guadalupe Island.

### Clarion Island

Clarion Island is the most remote of Mexico's Revillagigedo Islands.
It is located 700 kilometres from the Mexican mainland.
It has a tropical climate.
It has an area of 19.8 km$^2$.
It measures 8.6 km at its longest part from the eastern end to the western end.

### Feeding areas

The core areas were determined by tracking albatrosses during the reproductive season.
When the albatrosses leave the nest, it is to feed themselves and bring food for the chick.
Their food availability and distribution (fish, squid, etc.) are determined by oceanographic factors.
The California Current enriches the water with nutrients, which makes food more available.
ENSO variability might increase or reduce food availability in certain areas.
This food availability will affect where the albatrosses feed, which will determine what the core areas are.

### Time period

The data were collected from 2014 to 2026.
We want to determine the core areas that are constant over time.
MPA (ANP) are constant over time.
If we are going to evaluate how effective they are to protect the core areas for the albatrosses, then we need a long time period to make sure we are obtaining persistent patterns.
A 12-year period (2014–2026) is long enough to evaluate MPA (ANP) effectiveness.
A shorter period might not be enough because of interannual variability.
We assess the degree of representativeness of the data.
We don't consider the interannual variability directly.
We just verify the time period is long enough to be representative despite the interannual variability.
All the data are pooled together without accounting for the year.

## Study species or system

We are studying the core area used by Laysan albatrosses in the Mexican Pacific and its overlap with protected natural areas (ANP).
In particular, we focus on the albatrosses that nest on Guadalupe Island and Clarion Island.
Laysan albatross is an umbrella species.
If we find that MPA/ANP adequately protect the core areas of Laysan albatross, we can be sure that MPA/ANP also protect multiple species.
Their trophic level tells us that if the Laysan albatross does well, it means that the lower trophic levels do well as well.

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
[[ Add specific permit IDs or agencies if possible ]]

No albatross individuals were harmed during the study.
[[ Explain how albatross are trapped. Is there a standard for this? ]]

## Data collection

GPS loggers have the appropriate accuracy and precision for the study.
Other devices, like GLS, are not accurate enough to determine core areas.
The 10-minute frequency allows recording multiple trips per individual per season.
We programmed the GPS to record one position every 10 minutes.
This frequency is high enough for the data to be representative and identify moments when the individual stops or goes slow.
This frequency is low enough for the battery to last the whole season and track multiple trips.
We attached the GPS to the albatrosses.
The GPS loggers were attached to the albatross individuals with Tesa tape (#4651, Tesa AG, Hamburg, Germany).
[[ Explain how the tape is attached. Is there a standard protocol for this? ]]

In Guadalupe Island we used the following GPS devices: From 2014 to 2016: model GiSPy-4SB by Techno Smart (Italy).
From 2017 to 2018: i-gotU model GT-120 by Mobile Action (Taiwan).
From 2019 to 2023: XXX.
From 2025 to 2026: GPS datalogger with accelerometer and UHF model Axy-Trek Remote by Techno Smart (Italy).

In Clarion Island, from 2018 to 2022 we used the following GPS devices: i-gotU model GT-120 by Mobile Action (Taiwan).
CatLog-S, Catnip Technologies (China).
CatLog-S2, Perthold Engineering (USA).

# Experimental design

## Specific questions

- We aim to identify the core areas used by Laysan albatrosses in the Mexican Pacific.
- We also aim to determine whether these core areas overlap with existing ANPs.

Question 1: We split the tracks into individual trips; then we do kernel density estimations for each individual trip (we assess the representativeness of the sample data: not an input of the next step); finally, we determine the core areas (potential key biodiversity areas (KBA)).
Question 2: We take the core areas and intersect them with the MPA/ANP, then we evaluate/quantify the level of overlap.

### Core areas used by Laysan albatrosses

The unit of analysis is the trip.
Guadalupe Island is one colony, which has multiple individuals; each individual makes multiple trips per season.
Each trip is the smallest unit of analysis.
Core areas refer to the 50% Utilization Distribution (UD).
From the GPS trajectories, we calculated kernel density estimation (KDE) to define the core areas.
The UD level is 50%.
The Area-Restricted Search scale uses First Passage Time analysis (adehabitatLT).
FPT variance peaks are identified per individual.
Peaks are selected by peakMethod (default "first").
Then the median across individuals is taken.
KDE has been widely used to determine Utilization Distribution (UD).
KDE was selected because a wide range of users are familiar with its use, which facilitates the communication of results among decision makers.
KDEs are calculated for individual trips.
Then the KDEs from individual trips are combined to obtain a pooled density, from which the core area (50% UD) is obtained.
Representativeness refers to how well the sample represents the population.
For this purpose, individual trips are subsampled, and KDEs are calculated and combined to obtain the UD.
From the resulting area, we evaluate how many data points that were not selected in the subsample fall outside.
That gives us an idea of whether the sample size is sufficiently representative of the population for the results to be valid for the entire population.

The independent variable is the GPS locations of the albatrosses.
The dependent variable is the core areas used by the albatrosses.


A total of XXX individuals were tracked in Guadalupe Island between 2014 and 2026.
The number of individuals and the number of seasons were determined by the amount of resources available.
The representativeness of the data was assessed a posteriori.

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
| 2026 | XXX |

A total of {{ clarion_n_total }} individuals were tracked in Clarion Island between 2018 and 2022.

| Year | Number of individuals |
| ---- | --------------------- |
| 2018 | 7 |
| 2019 | 9 |
| 2020 | 6 |
| 2022 | 4 |

### Overlap of core areas with ANPs

We calculated the overlap index to quantify the overlap of the core areas with the ANP polygons.

The independent variables are the core areas used by the albatrosses and the ANP polygons.
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
We do not know if the core areas used by the albatrosses during the non-reproductive season are different.
However, it is during the reproductive season when the population could be most vulnerable.
