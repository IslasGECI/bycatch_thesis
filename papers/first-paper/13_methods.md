
# Methods

## Study Area

<!-- study scope, marine-coverage question, and candidate islands -->
We studied the core areas that Laysan albatrosses use within the Mexican EEZ.
This study evaluates whether the marine protected area covers the core area used by the Laysan albatross during its breeding season.
The protected areas relevant for this study have a terrestrial component (the island) and a marine component (the surrounding waters).
[[ How does the coverage question narrow to specific islands? ]]
There are several islands on which the Laysan albatross nests: Guadalupe, Clarion and San Benedicto are the most relevant.
[[ How does the scope and question lead into the island profiles? ]]

<!-- Guadalupe Island profile -->
Guadalupe Island hosts the largest breeding colony of Laysan albatross in the eastern Pacific [@hernandez2019sexual].
Guadalupe Island is located 300 km west of the coast of Baja California.
It is an oceanic island of volcanic origin.
It has an area of 244 km$^2$.
It measures 30 km at its longest part from the southern end to the northern end.
In Guadalupe Island, there are 2,195 breeding pairs of Laysan albatross in 2025 [[ reference ]].
[[ Why do these island attributes matter for the core-area analysis? ]]

### Clarion Island

<!-- Clarion Island profile -->
Clarion Island is part of the Revillagigedo Archipelago.
Clarion is located 700 kilometers from the Mexican mainland.
It has a tropical climate.
It has an area of 19.8 km$^2$.
It measures 8.6 km at its longest part from the eastern end to the western end.
Clarion Island has the second largest Laysan albatross colony in Mexico.
In Clarion Island, crows and snakes prey on Laysan albatross eggs and newly hatched chicks.
[[ Why does the Clarion profile matter for the core-area analysis? ]]

### San Benedicto

<!-- San Benedicto: secondary colony, low reproductive success, and the three breeding grounds -->
San Benedicto Island is also part of the Revillagigedo Archipelago and shares the same tropical climate.
San Benedicto is located 600 kilometers from the Mexican mainland.
It has an area of 10 km$^2$.
It measures 4.8 km at its longest part from the northern end to the southern end.
In San Benedicto Island, crabs feed on the chicks, and nests can be buried in ash.
In both, Clarion and San Benedicto islands, reproductive success for Laysan albatross is close to 0% and the number of nests is low (less than 40 for San Benedicto).
[[ Why does the San Benedicto profile matter for the core-area analysis? ]]

## Study Species

<!-- tracking, trip segmentation, and KDE -->
Tracking devices are installed while individuals are breeding on the island.
Each tracking device records multiple foraging trips.
We split each record into discrete round trips and analyze each trip by itself using KDE [@beal2021track2kba].
[[ Why is the individual trip the appropriate unit for KDE? ]]

<!-- core-area/MPA target, focal colonies, and long time series -->
We are studying the core area used by Laysan albatross in the Mexican Pacific and its overlap with marine protected areas (MPA).
In particular, we focus on the albatrosses that nest on the islands Guadalupe, Clarion, and San Benedicto.
To identify the core areas that persist over time, we use a long time series of tracking data.
[[ How does the long time series connect to the representativeness analysis? ]]

## Study Design

### Time period

<!-- 12-year dataset and representativeness -->
The data were collected from 2014 to 2026.
We assume that a 12-year tracking dataset would be long enough to capture the patterns that persist despite the interannual variability.
We verified this assumption with a representativeness analysis.
We also confirmed that a 5-year dataset (2014-2018) was not long enough to be representative of the population.
We grouped all 12 years without distinguishing between years.
[[ How does grouping the years relate to the breeding-season restriction? ]]

<!-- breeding-season coverage and deployment window -->
Even though the dataset is 12 years long, each year covers only the breeding season.
The GPS loggers were deployed from December to June, within the breeding season (November to July).
The GPS devices are deployed and recovered on the island, where seabirds return only during the breeding season.
The GPS devices and data cannot be recovered the next breeding season because the GPS devices are attached to feathers that are molted during the non-breeding season.
This study focuses on the breeding season because that is when seabirds forage from the colony and their use of the core areas is attributable to each island.
Once the time period is defined, we describe how the data were collected.

<!-- deployment date ranges per colony -->
[[ What do these deployment date ranges show? ]]
| Colony | Min Date | Max Date |
|--------|----------|----------|
| Guadalupe | {{ guadalupe_min_date }} | {{ guadalupe_max_date }} |
| Clarion | {{ clarion_min_date }} | {{ clarion_max_date }} |
| San Benedicto | {{ san_benedicto_min_date }} | {{ san_benedicto_max_date }} |

## Field Methods

<!-- tagging effort and a posteriori representativeness -->
[[ How many individuals were tagged at each colony, including San Benedicto? ]]
We attached GPS units to {{ guadalupe_n_total }} Laysan albatross individuals on Guadalupe Island from {{ guadalupe_min_year }} to {{ guadalupe_max_year }}.
Additionally, we attached GPS units to {{ clarion_n_total }} individuals on Clarion Island from {{ clarion_min_year }} to {{ clarion_max_year }}.
We designed the sampling effort according to the available resources, and we verified a posteriori that the sample was representative of the population.
[[ How does the tagging effort connect to the GPS devices used? ]]

<!-- GPS devices: accuracy, frequency, and attachment -->
GPS loggers have the appropriate accuracy and precision for the study.
Other devices, such as GLS loggers, are not accurate enough to determine core areas.
We programmed the GPS to record one position every 10 minutes.
The 10-minute frequency allows recording multiple trips per individual per season.
This frequency is high enough for the data to be representative and identify moments when the individual stops or goes slow.
This frequency is low enough for the battery to last the whole season and track multiple trips.
[[ How does the recording frequency connect to the attachment method? ]]
We attached the GPS loggers to the albatrosses with Tesa tape (#4651, Tesa AG, Hamburg, Germany).
[[ Explain how the tape is attached. Is there a standard protocol for this? ]]
[[ Explanation: why was Tesa tape chosen for attaching the GPS loggers? ]]

<!-- device models by year and island -->
There were variations in the GPS device models across years and islands, which we describe below.

In Guadalupe Island we used the following GPS devices: From 2014 to 2016: model GiSPy-4SB by Techno Smart (Italy).
From 2017 to 2018: i-gotU model GT-120 by Mobile Action (Taiwan).
From 2019 to 2023: ATS1 model Nodo-2018 by ACMOS (Mexico).
From 2025 to 2026: GPS datalogger with accelerometer and UHF model Axy-Trek Remote by Techno Smart (Italy).

In Clarion Island, from 2018 to 2022 we used the following GPS devices: i-gotU model GT-120 by Mobile Action (Taiwan).
CatLog-S, Catnip Technologies (China).
CatLog-S2, Perthold Engineering (USA).
The models changed because new and better technology was available during the 12-year period of the study.

[[ Add description of GPS used in San Benedicto ]]
[[ How do the device differences affect comparability across years and islands? ]]

<!-- individuals tracked per season -->
The following tables show the number of individuals tracked per season at each colony.

**Guadalupe Island**

| Season | Start date | End date | Number of individuals |
|--------|------------|----------|----------------------|
{{#guadalupe_seasons}}
| {{season}} | {{start}} | {{end}} | {{n}} |
{{/guadalupe_seasons}}

**Clarion Island**

| Season | Start date | End date | Number of individuals |
|--------|------------|----------|----------------------|
{{#clarion_seasons}}
| {{season}} | {{start}} | {{end}} | {{n}} |
{{/clarion_seasons}}

**San Benedicto Island**

| Season | Start date | End date | Number of individuals |
|--------|------------|----------|----------------------|
{{#san_benedicto_seasons}}
| {{season}} | {{start}} | {{end}} | {{n}} |
{{/san_benedicto_seasons}}
[[ What should the reader see in the per-season tracking effort? ]]

<!-- tracking effort concentration across colonies -->
[[ What do the per-season tables show about the effort split across colonies? ]]
The tracking effort was concentrated at the largest colony, Guadalupe Island, and less effort was invested in the smallest colonies, Clarion and San Benedicto islands.

<!-- sampled individuals and trips -->
The number of sampled individuals per colony is shown in the previous tables.
The data from Guadalupe Island include XXX trips, Clarion XXX, and San Benedicto XXX.
[[ What does the trip count imply for the analysis? ]]
Once the data were collected, we processed them following the track2KBA methodology.

## Data Processing

<!-- track2KBA workflow and filters -->
We used the R package track2KBA [@beal2021track2kba].
We removed points within 60 km around the colony.
We followed the track2KBA methodology, which called for removing incomplete trips.
[[ How do these filters prepare the tracks for KDE? ]]

<!-- track2KBA functions used -->
The following track2KBA functions were used:

- `formatFields()` to normalize GPS field names and date-time format
- `tripSplit()` to split GPS fixes into individual foraging trips
- `tripSummary()` to summarize trip metrics
- `projectTracks()` to project into an equal-area azimuthal projection
- `findScale()` to estimate the ARS smoothing scale via First Passage Time
- `estSpaceUse()` to compute kernel density estimates for each individual
- `repAssess()` to bootstrap and assess sample representativeness
- `findSite()` to identify potential KBA polygons meeting thresholds
[[ Which function yields the core areas used later? ]]

<!-- no resampling under uniform frequency -->
We did not do any resampling or consistency checks.
[[ What check confirms the raw data were homogeneous? ]]
We did not resample because all GPS devices were programmed with the same frequency, so the raw data were already homogeneous.
After processing the data, we analyzed them to identify the core areas.

## Data Analysis

<!-- pipeline summary and Beal justification -->
We split individual tracks, calculated KDE, and found core areas (50% UD; potential KBA).
We chose the Beal et al. (2021) methodology because it is replicable using a single open-source R package (track2KBA) that allows us to split tracks, estimate UD, and evaluate representativeness, and it is explicitly designed to identify potential key biodiversity areas from tracking data.
[[ Which pipeline step yields the final core-area surface? ]]

### Core areas used by Laysan albatross

**Measurements and Variables**

<!-- variables: GPS locations to core areas -->
The independent variable is the GPS locations of the Laysan albatross.
The dependent variable is the core areas used by the Laysan albatross.
[[ How do these variables feed the identification procedure? ]]

**Analysis**

<!-- core-area identification, overlap procedure, and unit of analysis -->
To identify core areas, we split the tracks into individual trips and perform kernel density estimations for each trip.
Each colony hosts multiple individuals, each individual makes multiple foraging trips per season; the foraging trip is the unit of analysis.
We then assess sample representativeness and determine the core areas (potential key biodiversity areas).
To determine overlap, we intersect the core areas with the MPA polygons and quantify the level of overlap.
[[ Why is representativeness assessed before fixing the core areas? ]]
[[ How does the unit of analysis carry into the pooled core-area estimate? ]]

<!-- core-area definition, KDE rationale, ARS scale -->
Core areas refer to the 50% Utilization Distribution (UD).
From the GPS trajectories, we calculated kernel density estimation (KDE) to define the core areas.
KDE has been widely used to determine UD.
The Area-Restricted Search scale uses First Passage Time analysis (adehabitatLT).
KDEs are calculated for individual trips.
Then the KDEs from individual trips are combined to obtain a pooled density, from which the core area (50% UD) is obtained.
KDE was selected because a wide range of users are familiar with its use, which facilitates the communication of results among decision makers.
[[ How does the pooled density connect to the representativeness check? ]]

<!-- representativeness method -->
Representativeness refers to how well the sample represents the population.
For this purpose, individual trips are subsampled, and KDEs are calculated and combined to obtain the UD.
From the resulting area, we evaluate how many data points that were not selected in the subsample fall outside.
That indicates whether the sample size is sufficiently representative of the population for the results to be valid for the entire population.
Once the core areas were identified, we quantified their overlap with the existing protected areas.

### Overlap of core areas with MPAs

**Measurements and Variables**

<!-- variables: core areas and MPAs to overlap index -->
The independent variables are the core areas used by the Laysan albatross and the MPA polygons.
The dependent variable is the overlap index.
[[ How do these variables feed the overlap index? ]]

**Analysis**

<!-- overlap index definition, properties, and interpretation -->
We calculated the overlap index to quantify the overlap of the core areas with the MPA polygons.
Fieberg & Kochanny quantified home-range overlap using the utilization distribution.
The overlap index is area-based (proportional) overlap: $HR_{i,j} = \frac{A_{i,j}}{A_i}$.
This index is directional: $HR_{i,j} \neq HR_{j,i}$.
It ignores the utilization distribution and treats all space within the home range as equally used.
Source: Kernohan et al. (2001); White & Garrott (1990).
[[ How does the index translate into the protection-coverage statement? ]]
This measure of core habitat protection coverage tells us what fraction of the animal's most intensively used space is inside the protected area.

## Ethical Considerations

<!-- permits and institutions -->
Ethical considerations and permits are required by Mexican authorities.
The study was performed under an ethical framework and with all the permits required by the Mexican government.
The study was conducted under the permits from the following institutions:
Ministry of the Interior, Ministry of Environment and Natural Resources, and the National Commission for Protected Natural Areas.
[[ Add specific permit IDs or agencies if possible ]]
The permits are mandatory because this study handles wildlife in federal protected areas.
In addition to obtaining the permits, we ensured the welfare of the seabirds during their handling.

<!-- no harm and capture procedure -->
No albatross individuals were harmed during the study.
The seabirds are captured by hand at the nest.
The capture is brief and harmless, and the individuals are released on site immediately after attaching or removing the GPS device.
In addition to the ethical considerations, we must consider the methodological limitations.

## Methodological Considerations

<!-- breeding-season-only restriction -->
The GPS logger collects data only during the breeding season, so the analysis is restricted to that period.
