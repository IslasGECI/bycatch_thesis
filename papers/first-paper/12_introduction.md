# Introduction

## Opening: the stakes
<!-- seabirds are threatened; pelagic species are weakly protected by MPAs -->
Seabirds are one of the most threatened groups of birds, with ~31% of species at risk and ~47% in decline [@dias2019threats].
Pelagic species, such as albatrosses, are less protected by MPAs than coastal species, with 13.2% of pelagic species covered by MPAs compared to 32.5% of coastal species [@critchley2018marine].
In general, seabirds are threatened and pelagic species are poorly protected by protected areas [@dias2019threats; @critchley2018marine].

<!-- Laysan albatross is an umbrella species; protecting it implies ecosystem protection -->
Seabirds are top predators and serve as umbrella species, meaning that if they are protected, other species in the same habitat are also protected [@lascelles2016applying].
Laysan albatross is an umbrella species.
Seabirds are top predators and serve as umbrella species.
Given that the Laysan albatross is an umbrella species, its protection by protected areas implies the protection of its ecosystem, and its lack of protection implies the lack of protection of its ecosystem [@lascelles2016applying].
If we find that MPAs/ANPs adequately protect the core areas of Laysan albatross, we can be sure that MPAs/ANPs also protect multiple species.
Their trophic level tells us that if the Laysan albatross does well, the lower trophic levels are thriving.
If the ANPs serve to protect these species, we can infer that they serve to protect the marine ecosystem.

<!-- tracking seabirds is the standard method for finding important marine areas -->
Tracking seabirds is a standard method for identifying important marine areas [@lascelles2016applying].

<!-- the audience: conservation scientists, spatial planners, protected-area managers, NGOs, and policy makers -->

## Challenge: the gap
<!-- the core areas used by Laysan albatross in the Mexican Pacific and their MPA coverage are unknown -->
There is a gap of knowledge about the core areas used by Laysan albatross in the Mexican Pacific and whether these areas are protected by existing Marine Protected Areas (MPAs).
There is evidence that in some cases protected areas do not actually protect highly mobile pelagic species [@critchley2018marine].

<!-- without that information MPA effectiveness cannot be evaluated -->
Without this information, it is not possible to determine if the existing MPAs are effective in protecting this and other species that share the same habitat.

<!-- knowledge gaps are declared for the Northeast Pacific -->
@phillips2024incidental concludes that there are "clear knowledge gaps" in the Northeast Pacific, the region where this study is located.

## Policy context and stakeholders
<!-- the trilateral working group raised the political priority of spatial data -->
The Trilateral Bycatch Working Group was formed in 2022, comprising members from Mexico, the United States, and Canada.
This group seeks joint action regarding incidental catch, thereby raising the political priority of obtaining spatial data [@trilateral2023meeting].
In 2023, the trilateral framework explicitly proposed using bird tracking, satellite imagery, and cloud computing to overcome "long-standing information gaps" [@trilateral2023meeting].

<!-- authorities, the fishing sector, and CSOs are stakeholders that rely on spatial data -->
Stakeholders relevant to the issues addressed in this study include Mexican conservation and fisheries authorities, the fishing sector, and environmental civil society organizations (CSOs).
Environmental CSOs rely on spatial data to guide their actions and justify their restoration interventions [@trilateral2023meeting], [@mendez2022population].

<!-- islands sit inside ANPs; gaps hinder management; bycatch fleets are regulated -->
The islands of Baja California lie within federal Protected Natural Areas (ANPs) managed by CONANP; as authorities issue permits for seabird management, information gaps hinder their management efforts [@mendez2022population].
Seabirds are affected by bycatch in longline, trawl, and purse-seine fisheries, and these fleets are regulated by national (CONAPESCA) and regional (IATTC) institutions [@phillips2024incidental], [@morgan2016fourth].

## The question
<!-- what is the core area, and how much of it is protected? -->
What is the core area used by the Laysan albatross in the Mexican Pacific, and how much of it is covered by protected areas?

<!-- the question rests on UD/home-range theory and KBA/IBA criteria -->
This question is underpinned by utilization-distribution/home-range theory [@worton1989kernel; @fieberg2005quantifying] and the KBA/IBA criteria [@lascelles2016applying; @beal2021track2kba; @soanes2016defining].

## Concepts
<!-- key concepts: core area, MPA, umbrella species, GPS tracking -->
The key concepts are core area [@worton1989kernel], marine protected area [@critchley2018marine], umbrella species [@lascelles2016applying], and GPS tracking [@lascelles2016applying; @beal2021track2kba].
A marine protected area is a spatially delimited marine zone designated to conserve biodiversity and regulate extractive activities such as fishing [@critchley2018marine; @afan2018adaptive].
An umbrella species is a species whose protection indirectly protects other species sharing its habitat [@lascelles2016applying].
GPS tracking is the recording of an animal's position over time to estimate its space use and identify important areas [@lascelles2016applying; @beal2021track2kba].

<!-- core area is the 50% UD, home range the 95% UD; standard but not universal -->
A core area is the portion of an animal's utilization distribution that contains 50% of its space-use probability, in contrast to the 95% home range [@beal2021track2kba; @fieberg2005quantifying].
Defining the core area as the 50% UD and the home range as the 95% UD is a standard practice but is not universal [@beal2021track2kba; @fieberg2005quantifying].

<!-- albatrosses are land-bound and leave the nest only for breeding-season foraging trips -->
Albatrosses are seabirds.
Seabirds are marine organisms.
They are on land only during their reproductive stage.
During the reproductive and nesting season, they make foraging trips.
They are at the nest, make a foraging trip, and return to the nest.
During the breeding season, albatrosses leave their nest only to feed themselves and bring food for the chick.

<!-- oceanography drives food, which drives where core areas form -->
Their food availability and distribution (fish, squid, etc.) are determined by oceanographic factors.
The California Current enriches the water with nutrients, which makes food more available.
ENSO variability might increase or reduce food availability in certain areas.
This food availability will affect where the albatrosses feed, which will determine what the core areas are.

## The method in principle
<!-- GPS tracking yields the UD by KDE; the UD identifies core areas -->
GPS tracking allows finding the UD by means of kernel density estimation (KDE) [@beal2021track2kba].
We use the UD to identify the core areas [@worton1989kernel].

<!-- overlapping core areas with protected areas evaluates umbrella-species protection -->
By overlapping the core areas with the protected areas, we evaluate the effectiveness of a protected area to protect an umbrella species, such as the Laysan albatross [@critchley2018marine].
Ensuring the protection of an umbrella species implies the protection of its ecosystem [@lascelles2016applying].

## The gap restated for this study
<!-- the Laysan albatross gap: short datasets, unknown representativeness -->
There is a gap of knowledge about this situation regarding the Laysan albatross in the Mexican Pacific [@phillips2024incidental].
We need to evaluate whether the Mexican protected areas protect the Laysan albatross core areas in the Mexican Pacific [@critchley2018marine; @mendez2022population].
It is unknown to what extent the Mexican protected areas cover the Laysan albatross core area in the Mexican Pacific [@critchley2018marine].
There is a lack of GPS tracking data in the Mexican Pacific to determine core areas for pelagic species [@phillips2024incidental].
The gap in knowledge this study addresses is identifying the core areas used by the Laysan albatross breeding in Mexico by analyzing 12 years of GPS tracking data that was not available before [@beal2021track2kba].

<!-- ~800k breeding pairs; low-lying colonies at risk; Guadalupe as a refuge -->
The global population size has been estimated to be around 800,000 breeding pairs [[ reference ]].
However, the biggest nesting colonies are low-lying sites at risk due to sea-level rise associated with climate change [[ reference ]].
Guadalupe Island offers high nesting areas that are less affected by sea-level rise, offering a refuge for the species [[ reference ]].

## Action: this study
<!-- this study: 12-year GPS dataset + track2KBA, core areas, overlap quantification -->
This study is based on GPS tracking, UD, and KBA methods to identify core areas, and it challenges the assumption that protected areas effectively cover the core areas of mobile pelagic species [@lascelles2016applying; @beal2021track2kba; @critchley2018marine].
This study offers 12 years of GPS tracking data for the Laysan albatross breeding on Mexican islands [@hernandez2019sexual; @pitman2004population].
Finally, we compare this area with Mexican protected areas [@critchley2018marine; @mendez2022population].
We use GPS tracking data to identify the core areas and close the gap in knowledge regarding the core areas of the Laysan albatross breeding in Mexico [@beal2021track2kba].

<!-- novelty: first 12-year core-area analysis; track2KBA never applied in Mexico -->
We also identify for the first time the core area used by these seabirds [@beal2021track2kba].
This study is the first one to use 12 years of GPS tracking data for the Laysan albatrosses breeding in Mexico to identify their core area [@beal2021track2kba; @hernandez2019sexual].
We are using track2KBA to identify the core areas, which has not been done for the Laysan albatross in Mexico [@beal2021track2kba].

<!-- previous studies: 5 years, Guadalupe only, no representativeness -->
Previous studies used a shorter (5 years) GPS tracking dataset and calculated the 50%, 75%, and 95% UD using a different method than the newer method suggested by the track2KBA framework [@hernandez2019sexual; @beal2021track2kba].
Previous studies do not address the population representativeness of the GPS-tracked sample relative to the total population, which we do consider [@beal2021track2kba].
Also, previous studies used data only from Guadalupe Island, while this study includes data from the islands of Clarión and San Benedicto [@hernandez2019sexual; @pitman2004population].

<!-- objectives: identify core areas; assess overlap with ANPs -->
The objective of this study closes the knowledge gap by mapping the core areas and quantifying their coverage by protected areas [@phillips2024incidental; @critchley2018marine].
Achieving the objective allows evaluating whether the existing protected areas effectively protect the Laysan albatross core area [@critchley2018marine; @mendez2022population].
The main objective of this study is to identify the core areas used by Laysan albatross in the Mexican Pacific and to assess their overlap with existing protected areas [@beal2021track2kba; @critchley2018marine].
We aim to identify the core areas used by Laysan albatross in the Mexican Pacific.
We also aim to determine whether these core areas overlap with existing ANPs.

<!-- hypothesis: existing protected areas do not adequately cover the core area -->
The core areas of the Laysan albatross, a pelagic umbrella species, might be unprotected by the existing protected areas [@critchley2018marine].
Our hypothesis is that the existing protected areas do not adequately cover the core area used by the Laysan albatross breeding in Mexico [@critchley2018marine].

## Resolution: significance
<!-- quantifies the overlap; extends the global MPA-effectiveness picture -->
This study provides empirical evidence on whether existing protected areas protect the core area of the Laysan albatross, a pelagic species [@critchley2018marine].
The methodology described can be replicated for other species or geographic regions [@beal2021track2kba].
This study quantifies the degree of overlap between a pelagic core area and existing protected areas, extending the global picture of the effectiveness of MPAs to protect pelagic species [@critchley2018marine].

<!-- informs the 30x30 target; data released for reuse -->
Also, it provides information to make decisions regarding the 30x30 target.
The results can guide decision making regarding the 30x30 target.
The tracking data used by this study is made available for others to make their own analysis.
The practical application that could come from the results of this study is where to extend the protected areas in the context of the Kunming-Montreal 30x30 target [@critchley2018marine; @afan2018adaptive].

<!-- CONANP and the trilateral group could act on the results -->
This study provides the scientific base necessary to extend the protected areas in an effective way [@critchley2018marine; @afan2018adaptive; @mendez2022population].
CONANP could use the results to prioritize the extension of protected areas [@mendez2022population].
The trilateral group could use the results to coordinate actions [@trilateral2023meeting].
We recommend incorporating the core area and overlap maps into protected area management plans and using them to adjust boundaries toward uncovered core areas [@mendez2022population; @afan2018adaptive].
We also recommend using these results to define biodiversity corridors [@afan2018adaptive].

<!-- our results suggest inadequate coverage -->
The overlap between the core area and the protected areas and the population representativeness of the results support the conclusion about whether the protection provided by the protected areas is adequate [@critchley2018marine; @beal2021track2kba].
Our results suggest that the existing protected areas do not adequately cover the core areas used by the Laysan albatross [@critchley2018marine].