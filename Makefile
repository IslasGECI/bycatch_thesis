all: \
	reports/anteproyecto.docx \
	reports/anteproyecto.pdf \
	reports/first_paper.docx \
	reports/first_paper.pdf \
	reports/second_paper.docx \
	reports/second_paper.pdf

SHELL := /bin/bash

reports/first_paper.docx reports/first_paper.pdf: \
	data/processed/individual_kde_guadalupe.rds \
	data/processed/trips_summary_guadalupe.csv \
	papers/first-paper/10_metadata.yaml \
	reports/figures/gps_albatross_50_percent_individual_kde_ars_guadalupe.png \
	reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe.png \
	reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_with_mpa.png \
	reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_without_mpa.png \
	reports/figures/gps_albatross_50_percent_representative_assessment_ars_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_by_trip_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_raw_clarion.png \
	reports/figures/gps_albatross_geographic_points_raw_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_raw_guadalupe_2025.png \
	reports/figures/mexico_eez.png \
	reports/figures/mexico_eez_bounding_box_zoom_in.png \
	reports/figures/mexico_eez_bounding_box_zoom_out.png \
	reports/figures/mexico_map.png \
	reports/figures/mexico_mpa.png \
	reports/figures/mexico_naturalearth.png \
	reports/figures/mexico_naturalearth_pro.png \
	reports/figures/mexico_pna.png \
	reports/first_paper.md
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=papers/first-paper/10_metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/first_paper.md

first_paper_sources := $(wildcard papers/first-paper/1?_*.md)

reports/first_paper.md: data/processed/methods.json $(first_paper_sources)
	$(checkDirectories)
	cat $(first_paper_sources) > papers/first-paper/first_paper.mustache
	mustache data/processed/methods.json papers/first-paper/first_paper.mustache > $@

reports/second_paper.docx reports/second_paper.pdf: \
	data/processed/individual_kde_all.rds \
	data/processed/trips_summary_all.csv \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv \
	papers/second-paper/20_metadata.yaml \
	reports/figures/gps_albatross_50_percent_individual_kde_ars_all.png \
	reports/figures/gps_albatross_50_percent_potential_kba_ars_all.png \
	reports/figures/gps_albatross_50_percent_representative_assessment_ars_all.png \
	reports/figures/gps_albatross_geographic_points_by_trip_all.png \
	reports/figures/longline_events_map.png \
	reports/figures/mexico_eez_bounding_box_zoom_in.png \
	reports/figures/mexico_eez_bounding_box_zoom_out.png \
	reports/second_paper.md
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=papers/second-paper/20_metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/second_paper.md

second_paper_sources := $(wildcard papers/second-paper/2?_*.md)

reports/second_paper.md: $(second_paper_sources)
	$(checkDirectories)
	cat $(second_paper_sources) > $@

reports/anteproyecto.docx reports/anteproyecto.pdf: \
	papers/proposal/00_metadata.yaml \
	papers/proposal/01_proposal.md
	$(checkDirectories)
	pandoc --metadata-file=papers/proposal/00_metadata.yaml --citeproc --output=$@ papers/proposal/01_proposal.md

reports/figures/mexico_eez.png: data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_mexico_eez.R

data/processed/bounding_box.json: data/processed/gps_albatross_all.csv
	Rscript src/export_bounding_box_to_json.R

data/processed/mexico_eez_bounding_box_intersection.gpkg: data/external/Exclusive_economic_zone_Mexico.shp data/processed/bounding_box.json
	$(checkDirectories)
	Rscript src/export_mexico_eez_bounding_box_to_gpkg.R

data/processed/mexico_eez_bounding_box_zoom_in.json: data/processed/mexico_eez_bounding_box_intersection.gpkg
	$(checkDirectories)
	Rscript src/export_mexico_eez_bounding_box_zoom_in_to_json.R

reports/figures/mexico_eez_bounding_box_zoom_in.png: \
	data/processed/mexico_eez_bounding_box_intersection.gpkg \
	data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_mexico_eez_bounding_box_intersection.R

reports/figures/mexico_eez_bounding_box_zoom_out.png: \
	data/external/Exclusive_economic_zone_Mexico.shp data/processed/bounding_box.json \
	data/processed/gps_albatross_all.csv \
	data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_mexico_eez_bounding_box_union.R

# 4390 = 645*2 pairs in the main island + 1550*2 pairs in the islets (https://doi.org/10.5281/zenodo.18343678)
data/processed/kba_polygons_guadalupe.gpkg: \
	data/processed/representative_assessment_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_potential_kba(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_guadalupe.rds \
		--percentage-distribution 50 \
		--population-size 4390 \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe.png: \
	data/processed/kba_polygons_guadalupe.gpkg
	$(checkDirectories)
	Rscript -e "bycatch::render_potential_kba(bycatch::get_domain_specific_options())" \
		--gpkg-path data/processed/kba_polygons_guadalupe.gpkg \
		--output-path $@

data/processed/kba_mpa_intersection_guadalupe.gpkg: \
	data/processed/kba_polygons_guadalupe.gpkg \
	data/processed/mexico_mpa.gpkg
	$(checkDirectories)
	Rscript src/export_kba_mpa_intersection.R

reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_without_mpa.png: \
	data/processed/kba_polygons_guadalupe.gpkg \
	data/external/Exclusive_economic_zone_Mexico.shp \
	data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_potential_kba_guadalupe.R

reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_with_mpa.png: \
	data/processed/kba_mpa_intersection_guadalupe.gpkg \
	data/processed/kba_polygons_guadalupe.gpkg \
	data/processed/mexico_mpa.gpkg \
	data/external/Exclusive_economic_zone_Mexico.shp \
	data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_kba_mpa_intersection.R

# 4437 = 47 individuals in Clarion Island (2023) + 4390 individuals in Guadalupe Island
data/processed/kba_polygons_all.gpkg: \
	data/processed/representative_assessment_all.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_potential_kba(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_all.rds \
		--percentage-distribution 50 \
		--population-size 4437 \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_kba_ars_all.png: \
	data/processed/kba_polygons_all.gpkg
	$(checkDirectories)
	Rscript -e "bycatch::render_potential_kba(bycatch::get_domain_specific_options())" \
		--gpkg-path data/processed/kba_polygons_all.gpkg \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assessment_ars_guadalupe.png: \
	data/processed/representative_assessment_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_representative_assessment(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_guadalupe.rds \
		--output-path $@

data/processed/individual_kde_guadalupe.rds: \
	data/processed/trips_geographic_points_guadalupe.csv \
	config_trips_guadalupe.json \
	data/processed/trips_summary_guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_individual_kde(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--percentage-distribution 50 \
		--trips-summary-path data/processed/trips_summary_guadalupe.csv \
		--output-path $@

data/processed/representative_assessment_guadalupe.rds: \
	data/processed/individual_kde_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_representative_assessment(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_guadalupe.rds \
		--percentage-distribution 50 \
		--n-iterations 314 \
		--output-path $@

data/processed/individual_kde_all.rds: \
	data/processed/trips_geographic_points_all.csv \
	config_trips_all.json \
	data/processed/trips_summary_all.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_individual_kde(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path config_trips_all.json \
		--percentage-distribution 50 \
		--trips-summary-path data/processed/trips_summary_all.csv \
		--output-path $@

data/processed/representative_assessment_all.rds: \
	data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript -e "bycatch::create_representative_assessment(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_all.rds \
		--percentage-distribution 50 \
		--n-iterations 314 \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assessment_ars_all.png: \
	data/processed/representative_assessment_all.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_representative_assessment(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_all.rds \
		--output-path $@

reports/figures/gps_albatross_50_percent_individual_kde_ars_guadalupe.png: \
	data/processed/individual_kde_guadalupe.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_individual_kde(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_guadalupe.rds \
		--output-path $@

reports/figures/gps_albatross_50_percent_individual_kde_ars_all.png: \
	data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_individual_kde(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_all.rds \
		--output-path $@

reports/figures/gps_albatross_geographic_points_raw_guadalupe.png: \
	data/raw/gps-albatros-guadalupe.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/raw/gps-albatros-guadalupe.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/radar_signal_geographic_points.csv: \
	data/raw/radar-signal-albatros-guadalupe.csv \
	data/raw/gps-albatros-guadalupe.csv
	$(checkDirectories)
	Rscript -e "seabirdtracking::write_radar_signal_coordinates(seabirdtracking::get_domain_specific_options())" \
		--tracking-data-path data/raw/gps-albatros-guadalupe.csv \
		--radar-signal-path data/raw/radar-signal-albatros-guadalupe.csv \
		--output-path $@

reports/figures/gps_albatross_geographic_points_raw_guadalupe_2025.png: \
	data/processed/gps_albatross_guadalupe_2025.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/processed/gps_albatross_guadalupe_2025.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/gps_albatross_guadalupe_2025.csv: \
	data/raw/gps-albatros-guadalupe.csv 
	$(checkDirectories)
	Rscript -e "bycatch::create_filtered_gps_between_dates(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--start 2025-01-01 \
		--end 2025-12-31 \
		--date-column-name date \
		--output-path $@

reports/figures/gps_albatross_geographic_points_by_trip_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points-by-trip \
		--geographic-data-path data/processed/trips_geographic_points_guadalupe.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

reports/figures/gps_albatross_geographic_points_by_trip_all.png: \
	data/processed/trips_geographic_points_all.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points-by-trip \
		--geographic-data-path data/processed/trips_geographic_points_all.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/trips_geographic_points_guadalupe.csv: \
	data/raw/gps-albatros-guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--output-path $@

data/processed/trips_geographic_points_clarion.csv: \
	data/raw/gps-albatros-clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-clarion.csv \
		--config-path config_trips_clarion.json \
		--output-path $@

data/processed/trips_geographic_points_all.csv: \
	data/processed/trips_geographic_points_clarion.csv \
	data/processed/trips_geographic_points_guadalupe.csv
	rm --force $@
	Rscript src/join_trip_data.R

data/processed/trips_summary_guadalupe.csv: \
	data/processed/trips_geographic_points_guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--output-path $@

data/processed/trips_summary_clarion.csv: \
	data/processed/trips_geographic_points_clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_clarion.csv \
		--config-path config_trips_clarion.json \
		--output-path $@

data/processed/trips_summary_all.csv: \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv
	rm --force $@
	csvstack data/processed/trips_summary_*.csv > $@

reports/figures/gps_albatross_geographic_points_raw_clarion.png: \
	data/raw/gps-albatros-clarion.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/raw/gps-albatros-clarion.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

reports/figures/gps_albatross_geographic_points_raw_san_benedicto.png: \
	data/raw/gps-albatros-san-benedicto.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/raw/gps-albatros-san-benedicto.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/raw/gps-albatros-clarion.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/radar-signal-albatros-guadalupe.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/breeding_status_albatross_clarion.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/gps-albatros-guadalupe.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/breeding_status_albatross_guadalupe.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/datapackage.json:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/gps-albatros-san-benedicto.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

shpLineaCostaMundial = \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx

$(shpLineaCostaMundial):
	$(checkDirectories)
	descarga_datos $(@F) $(@D) shp/division_politica_paises

data/raw/rosewind.png:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) img/rosa_vientos

data/external/oorg_2025_geci_longline_events_v20260402.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) global_fishing_data

data/external/datapackage.json:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) global_fishing_data

data/external/232_ANP-ITRF08_04072025.shp:
	unzip data/external/232_ANP-ITRF08_04072025.zip -d data/external

data/external/Exclusive_economic_zone_Mexico.shp:
	unzip data/external/Exclusive_economic_zone_Mexico.zip -d data/external

data/external/Mexico_e_islas_wgs84.shp:
	unzip data/external/Mexico_e_islas_wgs84.zip -d data/external

reports/figures/mexico_pna.png: data/external/232_ANP-ITRF08_04072025.shp
	$(checkDirectories)
	Rscript src/plot_mexico_pna.R

reports/figures/longline_events_map.png: data/external/oorg_2025_geci_longline_events_v20260402.csv
	$(checkDirectories)
	Rscript src/plot_longline_events.R

data/processed/gps_albatross_all.csv: data/raw/gps-albatros-clarion.csv data/raw/gps-albatros-guadalupe.csv
	$(checkDirectories)
	Rscript src/join_gps_data.R

data/processed/mexico_pna.gpkg: data/external/232_ANP-ITRF08_04072025.shp
	$(checkDirectories)
	Rscript src/export_pna_to_gpkg.R

reports/figures/mexico_map.png: data/external/Mexico_e_islas_wgs84.shp
	$(checkDirectories)
	Rscript src/plot_mexico_map.R

data/processed/mexico_map.gpkg: data/external/Mexico_e_islas_wgs84.shp
	$(checkDirectories)
	Rscript src/export_mexico_to_gpkg.R

data/processed/mexico_mpa.gpkg: data/processed/mexico_pna.gpkg data/processed/mexico_map.gpkg
	$(checkDirectories)
	Rscript src/export_mexico_mpa_to_gpkg.R

reports/figures/mexico_mpa.png: data/processed/mexico_mpa.gpkg
	$(checkDirectories)
	Rscript src/plot_mexico_mpa.R

reports/figures/mexico_naturalearth.png:
	$(checkDirectories)
	Rscript src/plot_mexico_naturalearth.R

reports/figures/mexico_naturalearth_pro.png:
	$(checkDirectories)
	Rscript src/plot_mexico_naturalearth_pro.R

define renderBibLatex
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && bibtex $(subst .tex,,$(<F))
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pdflatex $(<F)
endef

define renderLatex
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pdflatex $(<F)
endef

define checkDirectories
	mkdir --parents $(@D)
endef

.PHONY: \
	all \
	check \
	clean \
	format \
	init

clean:
	rm --force *.pdf
	rm --force --recursive data
	rm --force --recursive reports

format:
	R -e "library(styler)" \
		-e "style_dir('src')"

check:
	src/check_manuscript_style.sh 'papers/first-paper/1?_*.md'
	src/check_manuscript_style.sh 'papers/second-paper/2?_*.md'
	src/check_spelling.sh 'papers/proposal/0?_*.md' 'es'
	src/check_spelling.sh 'papers/first-paper/1?_*.md' 'en'
	src/check_spelling.sh 'papers/second-paper/2?_*.md' 'en'

init: init_git

init_git:
	git config --global --add safe.directory /workdir
	git config --global user.name "Ciencia de Datos • GECI"
	git config --global user.email "ciencia.datos@islas.org.mx"

