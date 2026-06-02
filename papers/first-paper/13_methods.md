
# Methods

## Study Area

Seabirds nest on the islands.
The islands are protected natural areas.

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

Clarion Island has the second largest colony.
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

## Study Species

Seabirds are marine organisms and are only found on land to reproduce.
Tracking devices are installed while individuals are breeding on the island.

Albatrosses are seabirds.
Seabirds are marine organisms.
They are on land only during their reproductive stage.
During the reproductive and nesting season, they make foraging trips.
They are at the nest, make a foraging trip, and return to the nest.

We are studying the core area used by Laysan albatrosses in the Mexican Pacific and its overlap with protected natural areas (ANP).
In particular, we focus on the albatrosses that nest on Guadalupe Island and Clarion Island.
Laysan albatross is an umbrella species.
If we find that MPA/ANP adequately protect the core areas of Laysan albatross, we can be sure that MPA/ANP also protect multiple species.
Their trophic level tells us that if the Laysan albatross does well, it means that the lower trophic levels do well as well.

Seabirds are top predators and serve as umbrella species.
If the ANPs serve to protect these species, we can infer that they serve to protect the marine ecosystem.

## Study Design

### Time period

The data were collected from 2014 to 2026.
We want to determine the core areas that are constant over time.
MPA (ANP) are constant over time.
To evaluate how effectively MPAs protect the core areas for albatrosses, we need a long time period to obtain persistent patterns.
A 12-year period (2014–2026) is long enough to evaluate MPA (ANP) effectiveness.
A shorter period might not be enough because of interannual variability.
We assess the degree of representativeness of the data.
We don't consider the interannual variability directly.
We just verify the time period is long enough to be representative despite the interannual variability.
All the data are pooled together without accounting for the year.

## Field Methods

We attached GPS units to XXX Laysan albatross individuals on Guadalupe Island from 2014 to 2026.
Additionally, we attached GPS units to 26 individuals on Clarion Island from 2018 to 2022.

A total of XXX individuals were tracked in Guadalupe Island between 2014 and 2026.
The number of individuals and the number of seasons were determined by the amount of resources available.
The representativeness of the data was assessed a posteriori.

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

## Data Processing

We used the R package track2KBA.
We removed points within 60 km around the colony.
We follow the track2KBA methodology, which calls for removing incomplete trips.
The following track2KBA functions were used:
- `formatFields()` to normalize GPS field names and date-time format
- `tripSplit()` to split GPS fixes into individual foraging trips
- `tripSummary()` to summarize trip metrics
- `projectTracks()` to project into an equal-area azimuthal projection
- `findScale()` to estimate the ARS smoothing scale via First Passage Time
- `estSpaceUse()` to compute kernel density estimates for each individual
- `repAssess()` to bootstrap and assess sample representativeness
- `findSite()` to identify potential KBA polygons meeting thresholds

Records are every 10 minutes.
We did not do any resampling or consistency checks.
All GPS were programmed to record one position every 10 minutes.

## Data Analysis

No inferential statistics were used.

We based our methodology on [@beal2021track2kba].
We used the R package track2KBA [@beal2021track2kba] to split individual tracks, calculate KDE, and find core areas (50% UD; potential KBA).
Our implementation follows [@beal2021track2kba] completely.
No deviations.

### Core areas used by Laysan albatrosses

**Measurements and Variables**

The independent variable is the GPS locations of the albatrosses.
The dependent variable is the core areas used by the albatrosses.

**Analysis**

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
That indicates whether the sample size is sufficiently representative of the population for the results to be valid for the entire population.

### Overlap of core areas with ANPs

**Measurements and Variables**

The independent variables are the core areas used by the albatrosses and the ANP polygons.
The dependent variable is the overlap index.

**Analysis**

Fieberg & Kochanny quantified home-range overlap using the utilization distribution.
We calculated the overlap index to quantify the overlap of the core areas with the ANP polygons.
The overlap index is area-based (proportional) overlap: HR_{i,j} = A_{i,j} / A_i.
HR_{i,j} measures the proportion of animal i's home range that is overlapped by animal j's home range.
This index is directional: HR_{i,j} $\neq$ HR_{j,i}.
It ignores the utilization distribution and treats all space within the home range as equally used.
Source: Kernohan et al. (2001); White & Garrott (1990).
Area-based (proportional) overlap measures the proportion of core area that is overlapped by MPA/ANP area.
This measure of core habitat protection coverage tells us what fraction of the animal's most intensively used space is inside the protected area.

## Ethical Considerations

Ethical considerations and permits are required by Mexican authorities.
The study was conducted under the permits from the following institutions:
Ministry of the Interior, Ministry of Environment and Natural Resources, and the National Commission for Protected Natural Areas.
[[ Add specific permit IDs or agencies if possible ]]

No albatross individuals were harmed during the study.
[[ Explain how albatross are trapped. Is there a standard for this? ]]


## Methodological Considerations

We collected data from Clarion and San Benedicto islands, but the sample was small.
All the results are based on the Guadalupe Island colony, which we believe is representative since it is much bigger than the rest.

Different years have different numbers of GPS devices, individuals, and trips.
However, we are not distinguishing between years.

The GPS logger only collects data during the breeding season, which does not cover the whole year.
One limitation is that the GPS data only correspond to the reproductive season.
We do not know if the core areas used by the albatrosses during the non-reproductive season are different.
However, it is during the reproductive season when the population could be most vulnerable.
Because data were collected only during the breeding season, MPA protection effectiveness for the Laysan albatross is determined only for that period.
We cannot speak of the protection provided by the MPA during the rest of the year.
