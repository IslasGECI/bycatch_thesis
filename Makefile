all: \
	articles \
	dangling \
	maps \
	old_method \
	results_clarion

SHELL := /bin/bash

articles: \
	reports/anteproyecto.docx \
	reports/anteproyecto.pdf \
	reports/first_paper.docx \
	reports/first_paper.pdf \
	reports/second_paper.docx \
	reports/second_paper.pdf

reports/first_paper.docx reports/first_paper.pdf: \
	metadata.yaml \
	reports/first_paper_draft.md \
	results_first_paper
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/first_paper_draft.md

reports/first_paper_draft.md:
	$(checkDirectories)
	cat 1?_*.md > $@

reports/second_paper.docx reports/second_paper.pdf: \
	metadata.yaml \
	reports/second_paper_draft.md \
	results_second_paper
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/second_paper_draft.md

reports/second_paper_draft.md:
	$(checkDirectories)
	cat 2?_*.md > $@

reports/anteproyecto.docx reports/anteproyecto.pdf: \
	metadata.yaml \
	01_proposal.md
	$(checkDirectories)
	pandoc --metadata-file=metadata.yaml --citeproc --output=$@ 01_proposal.md

results_first_paper: \
	data/processed/trips_summary_guadalupe.csv \
	reports/figures/gps_albatross_50_percent_individuals_kernel_ars_guadalupe.png \
	reports/figures/gps_albatross_50_percent_potential_site_ars_guadalupe.png \
	reports/figures/gps_albatross_50_percent_representative_assess_ars_guadalupe.png \
	reports/figures/gps_albatross_50_percent_usage_area_ars_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_by_trip_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_raw_guadalupe.png

results_second_paper: \
	data/processed/trips_summary_all.csv \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv \
	reports/figures/gps_albatross_50_percent_individuals_kernel_ars_all.png \
	reports/figures/gps_albatross_50_percent_potential_site_ars_all.png \
	reports/figures/gps_albatross_50_percent_representative_assess_ars_all.png \
	reports/figures/gps_albatross_50_percent_usage_area_ars_all.png \
	reports/figures/gps_albatross_geographic_points_by_trip_all.png \
	reports/figures/mexico_eez_bounding_box_zoom_in.png \
	reports/figures/mexico_eez_bounding_box_zoom_out.png

results_clarion: \
	data/processed/trips_summary_clarion.csv \
	reports/figures/gps_albatross_50_percent_individuals_kernel_ars_clarion.png \
	reports/figures/gps_albatross_geographic_points_raw_clarion.png

maps: \
	reports/figures/mexico_map.png \
	reports/figures/mexico_mpa.png \
	reports/figures/mexico_pna.png

old_method: \
	reports/figures/gps_albatross_50_percent_kernel_density_guadalupe.png \
	reports/figures/gps_albatross_kernel_density_guadalupe.png

dangling: \
	reports/figures/gps_albatross_geographic_points_raw_guadalupe_2025.png

reports/figures/mexico_eez.png: data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_mexico_eez.R

config_bounding_box.json: data/processed/gps_albatross_all.csv
	Rscript src/export_bounding_box_to_json.R

data/processed/mexico_eez_bounding_box_intersection.gpkg: data/external/Exclusive_economic_zone_Mexico.shp config_bounding_box.json
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
	data/external/Exclusive_economic_zone_Mexico.shp config_bounding_box.json \
	data/processed/gps_albatross_all.csv \
	data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_mexico_eez_bounding_box_union.R

reports/figures/gps_albatross_50_percent_usage_area_ars_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	config_trips_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_usage_area_by_individual(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--n-iterations 1000 \
		--output-path $@

reports/figures/gps_albatross_50_percent_usage_area_ars_all.png: \
	data/processed/trips_geographic_points_all.csv \
	config_trips_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_usage_area_by_individual(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path config_trips_all.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--n-iterations 1000 \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_site_ars_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	config_trips_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_potential_site(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--population-size 4390 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_site_ars_all.png: \
	data/processed/trips_geographic_points_all.csv \
	config_trips_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_potential_site(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path config_trips_all.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--population-size 4437 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assess_ars_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	config_trips_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_representative_assess(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assess_ars_all.png: \
	data/processed/trips_geographic_points_all.csv \
	config_trips_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_representative_assess(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path config_trips_all.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ars_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	config_trips_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ars_clarion.png: \
	data/processed/trips_geographic_points_clarion.csv \
	config_trips_clarion.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_clarion.csv \
		--config-path config_trips_clarion.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ars_all.png: \
	data/processed/trips_geographic_points_all.csv \
	config_trips_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path config_trips_all.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_kernel_density_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-kernel-density \
		--geographic-data-path data/processed/trips_geographic_points_guadalupe.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--selected-contour "50_contour" \
		--bandwidth 0.005 \
		--result-map-path $@

reports/figures/gps_albatross_kernel_density_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-kernel-density \
		--geographic-data-path data/processed/trips_geographic_points_guadalupe.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--selected-contour "All_contours" \
		--bandwidth 0.005 \
		--result-map-path $@

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
	Rscript -e "bycatch::filter_data_between_dates(bycatch::get_domain_specific_options())" \
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
	Rscript -e "bycatch::write_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--output-path $@

data/processed/trips_geographic_points_clarion.csv: \
	data/raw/gps-albatros-clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips(bycatch::get_domain_specific_options())" \
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
	Rscript -e "bycatch::write_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path config_trips_guadalupe.json \
		--output-path $@

data/processed/trips_summary_clarion.csv: \
	data/processed/trips_geographic_points_clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips_summary(bycatch::get_domain_specific_options())" \
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

data/raw/gps-albatros-clarion.csv:
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

shpLineaCostaMundial = \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx

$(shpLineaCostaMundial):
	$(checkDirectories)
	descarga_datos $(@F) $(@D) shp/division_politica_paises

data/raw/rosewind.png:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) img/rosa_vientos

data/external/232_ANP-ITRF08_04072025.shp:
	unzip data/external/232_ANP-ITRF08_04072025.zip -d data/external

data/external/Exclusive_economic_zone_Mexico.shp:
	unzip data/external/Exclusive_economic_zone_Mexico.zip -d data/external

data/external/Mexico_e_islas_wgs84.shp:
	unzip data/external/Mexico_e_islas_wgs84.zip -d data/external

reports/figures/mexico_pna.png: data/external/232_ANP-ITRF08_04072025.shp
	$(checkDirectories)
	Rscript src/plot_mexico_pna.R

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
	articles \
	clean \
	dangling \
	format \
	init \
	maps \
	old_method \
	results_clarion \
	results_first_paper \
	results_second_paper

clean:
	rm --force *.pdf
	rm --force --recursive data/processed
	rm --force --recursive data/raw
	rm --force --recursive reports
	rm --force config_bounding_box.json
	rm --force data/external/232_ANP-ITRF08_04072025.cpg
	rm --force data/external/232_ANP-ITRF08_04072025.dbf
	rm --force data/external/232_ANP-ITRF08_04072025.prj
	rm --force data/external/232_ANP-ITRF08_04072025.s*
	rm --force data/external/Exclusive_economic_zone_Mexico.cpg
	rm --force data/external/Exclusive_economic_zone_Mexico.dbf
	rm --force data/external/Exclusive_economic_zone_Mexico.prj
	rm --force data/external/Exclusive_economic_zone_Mexico.s*
	rm --force data/external/Mexico_e_islas_wgs84.cpg
	rm --force data/external/Mexico_e_islas_wgs84.dbf
	rm --force data/external/Mexico_e_islas_wgs84.prj
	rm --force data/external/Mexico_e_islas_wgs84.qmd
	rm --force data/external/Mexico_e_islas_wgs84.s*

format:
	R -e "library(styler)" \
      -e "style_dir('src')"


init: init_git
	shellspec --init

init_git:
	git config --global --add safe.directory /workdir
	git config --global user.name "Ciencia de Datos • GECI"
	git config --global user.email "ciencia.datos@islas.org.mx"

