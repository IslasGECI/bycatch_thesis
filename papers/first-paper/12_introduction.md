
# Introduction

<!-- main idea: pelagic species are far less MPA-covered than coastal ones -->
Seabirds are one of the most threatened groups of birds, with ~31% of species at risk and ~47% in decline [@dias2019threats].
State with studies why they are threatened (harvesting, over fishing, predation from invasive species, etc., indicate cause and consequence [[ citations for each ]].
Given all these negative impacts, different strategies have been pursued to prevent seabird populations from collapsing and improving their conservation status [[ citation ]].
In particular, marine protected areas are considered an efficient conservation strategy for seabird species [[ references ]].
In general, seabirds are threatened and pelagic species are poorly protected by protected areas [@dias2019threats; @critchley2018marine].
Pelagic species, such as albatrosses, are less protected by MPAs than coastal species.
13.2% of pelagic species are covered by MPAs, compared to 32.5% of coastal species [@critchley2018marine].

<!-- main idea: the Laysan albatross is an umbrella species, so its protection implies its ecosystem's -->
Seabirds are top predators and serve as umbrella species, meaning that if they are protected, other species in the same habitat are also protected [@lascelles2016applying].
An umbrella species is a species whose protection indirectly protects other species sharing its habitat [@lascelles2016applying].
The Laysan albatross is an umbrella species.
The top-predator trophic level of the Laysan albatross tells us that if this species does well, the lower trophic levels are thriving.
Given that the Laysan albatross is an umbrella species, its protection by protected areas implies the protection of its ecosystem.
Conversely, its lack of protection implies the lack of protection of its ecosystem [@lascelles2016applying].

<!-- main idea: the albatross lives at sea except to breed, and its foraging trips are what tracking resolves -->
Seabirds are marine organisms that are on land only during their reproductive stage.
Albatrosses are seabirds.
During the breeding season, albatrosses leave their nest only to feed themselves and bring food for the chick.
They are at the nest, make a foraging trip, and return to the nest.

<!-- main idea: on land the birds sit in protected natural areas; at sea they face a regulated bycatch fleet -->
The islands of Baja California lie within federal Protected Natural Areas (ANPs) managed by CONANP.
The global population size has been estimated to be around 800,000 breeding pairs [@birdlife2018phoebastria].
The biggest nesting colonies are low-lying sites at risk due to sea-level rise associated with climate change [@birdlife2018phoebastria].
Guadalupe Island has high nesting areas that are less affected by sea-level rise, offering a refuge for the species [@hernandez2019sexual].
Seabirds are affected by bycatch in longline, trawl, and purse-seine fisheries, and these fleets are regulated by national (CONAPESCA) and regional (IATTC) institutions [@phillips2024incidental; @morgan2016fourth].

<!-- main idea: food is set by oceanography, so the birds' range is not tied to land -->
Their food availability and distribution (fish, squid, etc.) are determined by oceanographic factors.
The California Current enriches the water with nutrients, which makes food more available.
ENSO variability might increase or reduce food availability in certain areas.
This food availability will affect where the albatrosses feed, which will determine what the core areas are.

<!-- main idea: tracking finds marine areas important to seabirds, yet protected areas still fail pelagic species -->
Tracking seabirds is a standard method for identifying important marine areas [@lascelles2016applying].
Important marine areas are the basis on which marine protected areas should be delineated [@lascelles2016applying; @critchley2018marine].
In the Mexican Pacific, however, protected areas are anchored to terrestrial units and were not delineated from seabird tracking [@mendez2022population].
There is evidence that in some cases protected areas do not actually protect highly mobile pelagic species [@critchley2018marine].

<!-- main idea: the method turns tracks into a core area and tests it against protected areas -->
To evaluate if whether the protected area actually protects the important areas for the Laysan albatross, we evlauate the overlap between those two areas.
GPS tracking allows finding the UD by means of kernel density estimation (KDE), and we use the UD to identify the core areas [@beal2021track2kba; @worton1989kernel].
The colony is used to define what constitutes a complete trip, which is the unit of analysis in this study.
This evaluates the effectiveness of a protected area to protect an umbrella species, such as the Laysan albatross [@critchley2018marine].

<!-- main idea: spatial data is in institutional demand, which raises the cost of leaving it missing -->
Stakeholders relevant to the issues addressed in this study include Mexican conservation and fisheries authorities, the fishing sector, and environmental civil society organizations (CSOs).
For example, in 2023, the trilateral framework explicitly proposed using bird tracking, satellite imagery, and cloud computing to overcome "long-standing information gaps" [@trilateral2023meeting].
This group seeks joint action regarding incidental catch, thereby raising the political priority of obtaining spatial data [@trilateral2023meeting].
As authorities issue permits for seabird management, information gaps hinder the authorities' ability to be effective [@mendez2022population].
Environmental CSOs rely on spatial data to guide their actions and justify their restoration interventions [@trilateral2023meeting; @mendez2022population].

<!-- gap: no existing sentence introduces the designation framework the challenge rests on, or states where that framework stops for pelagic species at sea -->
<!-- main idea: unknown are the core area in the Mexican Pacific and its MPA coverage -->
@phillips2024incidental concludes that there are "clear knowledge gaps" in the Northeast Pacific, the region where this study is located.
There is a lack of GPS tracking data in the Mexican Pacific to determine core areas for pelagic species [@phillips2024incidental].
There is a gap of knowledge about the core areas used by Laysan albatross in the Mexican Pacific.
It is also unknown whether these areas are protected by existing Marine Protected Areas (MPAs).
It is unknown to what extent the Mexican protected areas cover the Laysan albatross core area in the Mexican Pacific [@critchley2018marine].
Without this information, it is not possible to determine whether the existing MPAs effectively protect this and other species sharing the same habitat.
The gap in knowledge this study addresses is identifying the core areas used by the Laysan albatross breeding in Mexico.

<!-- main idea: the question this paper answers -->
Our objective is to determine the effectiveness of existing marine protected areas in protecting the Laysan albatross and its ecosystem.
To this end, we aim to identify the key areas used by the Laysan albatross and determine the extent to which these areas are covered by existing marine protected areas.

<!-- main idea: the question rests on key concepts whose meanings must be fixed first -->
The key concepts are core area [@worton1989kernel], marine protected area [@critchley2018marine], umbrella species [@lascelles2016applying], and GPS tracking [@lascelles2016applying; @beal2021track2kba].
These key concepts establish shared terminology to address the core-area question unambiguously.
This question is underpinned by utilization-distribution/home-range theory [@worton1989kernel; @fieberg2005quantifying] and the KBA/IBA criteria [@lascelles2016applying; @beal2021track2kba; @soanes2016defining].
A core area is the portion of an animal's utilization distribution that contains 50% of its space-use probability, in contrast to the 95% home range [@beal2021track2kba; @fieberg2005quantifying].
Defining the core area as the 50% UD and the home range as the 95% UD is a standard practice but is not universal [@beal2021track2kba; @fieberg2005quantifying].
A marine protected area is a spatially delimited marine zone designated to conserve biodiversity and regulate extractive activities such as fishing [@critchley2018marine; @afan2018adaptive].
GPS tracking is the recording of an animal's position over time to estimate its space use and identify important areas [@lascelles2016applying; @beal2021track2kba].

<!-- main idea: no prior study combined this dataset, method and these colonies, or checked representativeness -->
This study is the first to use 12 years of GPS tracking data to identify the core area of Laysan albatrosses breeding in Mexico [@beal2021track2kba; @hernandez2019sexual].
We are using track2KBA to identify the core areas, which has not been done for the Laysan albatross in Mexico [@beal2021track2kba].
This identification uses 12 years of GPS tracking data that was not available before [@beal2021track2kba].
Previous studies used a shorter (5 years) GPS tracking dataset.
They calculated the 50%, 75%, and 95% UD using a different method than the newer method suggested by the track2KBA framework [@hernandez2019sexual; @beal2021track2kba].
Previous studies do not address the population representativeness of the GPS-tracked sample relative to the total population, which we do consider [@beal2021track2kba].
Also, previous studies used data only from Guadalupe Island, while this study includes data from the islands of Clarión and San Benedicto [@hernandez2019sexual; @pitman2004population].

<!-- main idea: the objective, the approach and the hypothesis the paper tests -->
The main objective is to identify the core areas used by Laysan albatross in the Mexican Pacific and to assess their overlap with protected areas [@beal2021track2kba; @critchley2018marine].
This study is based on GPS tracking, UD, and KBA methods to identify core areas.
This study closes the knowledge gap by mapping the core areas and quantifying their coverage by protected areas [@phillips2024incidental; @critchley2018marine].
This study quantifies the degree of overlap between a pelagic core area and existing protected areas.
Finally, we compare this area with Mexican protected areas [@critchley2018marine; @mendez2022population].
It challenges the assumption that protected areas effectively cover the core areas of mobile pelagic species [@lascelles2016applying; @beal2021track2kba; @critchley2018marine].
Achieving the objective allows evaluating whether the existing protected areas effectively protect the Laysan albatross core area [@critchley2018marine; @mendez2022population].
Our hypothesis is that the existing protected areas do not adequately cover the core area used by the Laysan albatross breeding in Mexico [@critchley2018marine].

<!-- main idea: what the method and data enable, framed prospectively -->
The methodology described can be replicated for other species or geographic regions [@beal2021track2kba].
The practical application that could come from the results of this study is where to extend the protected areas.
This is relevant in the context of the Kunming-Montreal 30x30 target [@critchley2018marine; @afan2018adaptive].
CONANP could use the results to prioritize the extension of protected areas, and the trilateral group could use them to coordinate actions [@mendez2022population; @trilateral2023meeting].
The tracking data used by this study are made available for others to make their own analysis.


<!-- ======================================================================= -->
<!-- STILL UNPLACED: sentences that state the resolution, not the challenge. -->
<!-- Held verbatim, unedited. None has a home in the six-paper structure,    -->
<!-- which keeps applications prospective and never reports findings.        -->
<!-- ======================================================================= -->

<!-- announces the resolution: reports a finding -->
Our results suggest that the existing protected areas do not adequately cover the core areas used by the Laysan albatross [@critchley2018marine].

<!-- announces the resolution: asserts the outcome, which Schimel Ch. 7 forbids in an introduction -->
It extends the global picture of the effectiveness of MPAs to protect pelagic species [@critchley2018marine].
This study provides the scientific base necessary to extend the protected areas in an effective way [@critchley2018marine; @afan2018adaptive; @mendez2022population].

<!-- announces the resolution: recommendations already made -->
We also recommend using these results to define biodiversity corridors [@afan2018adaptive].
We recommend incorporating the core area and overlap maps into protected area management plans and using them to adjust boundaries toward uncovered core areas [@mendez2022population; @afan2018adaptive].
