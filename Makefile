all: reports/anteproyecto.docx \
	reports/anteproyecto.pdf \
	reports/articulo_uno.docx \
	reports/articulo_uno.pdf \
	reports/articulo_dos.docx \
	reports/articulo_dos.pdf

SHELL := /bin/bash

reports/articulo_uno.pdf: \
	reports/draft.md \
	metadata.yaml
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/draft.md

reports/articulo_uno.docx: \
	reports/draft.md \
	metadata.yaml
	$(checkDirectories)
	pandoc --include-in-header=options.sty --metadata-file=metadata.yaml --metadata=documentclass:article --table-of-contents --citeproc --output=$@ reports/draft.md

reports/draft.md: results_firts_paper
	$(checkDirectories)
	cat 1?_*.md > $@

reports/anteproyecto.pdf: \
	metadata.yaml \
	01_proposal.md
	$(checkDirectories)
	pandoc --metadata-file=metadata.yaml --citeproc --output=$@ 01_proposal.md

reports/anteproyecto.docx: \
	metadata.yaml \
	01_proposal.md
	$(checkDirectories)
	pandoc --metadata-file=metadata.yaml --citeproc --output=$@ 01_proposal.md

results_first_paper: \
	data/processed/trips_summary_all.csv \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv \
	reports/figures/gps_albatross_50_percent_individuals_kernel_ARS_all.png \
	reports/figures/gps_albatross_50_percent_individuals_kernel_ARS_guadalupe.png \
	reports/figures/gps_albatross_50_percent_potential_site_ARS_all.png \
	reports/figures/gps_albatross_50_percent_potential_site_ARS_guadalupe.png \
	reports/figures/gps_albatross_50_percent_representative_assess_ARS.png \
	reports/figures/gps_albatross_50_percent_usage_area_ARS.png \
	reports/figures/gps_albatross_geographic_points.png \
	reports/figures/gps_albatross_geographic_points_2025.png \
	reports/figures/gps_albatross_geographic_points_by_trip.png

results_second_paper: \
	data/processed/vessel_kernel_union_25.gpkg \
	reports/figures/kernel_overlap_home_ranges_union_25.png \
	reports/figures/kernel_overlap_home_ranges_union_25_zoom.png \
	reports/figures/kernel_seabird_home_ranges_map_25.png \
	reports/figures/kernel_seabird_home_ranges_union_25.png \
	reports/figures/kernel_vessel_home_ranges_map_25.png \
	reports/figures/kernel_vessel_home_ranges_union_25.png \
	reports/figures/mexico_eez.png \
	reports/figures/mexico_mpa.png

reports/figures/mexico_eez.png: data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_mexico_eez.R

bounding_box_config.json: data/processed/gps_albatross_combined.csv
	Rscript src/export_bounding_box_to_json.R

data/processed/mexico_eez_bounding_box_intersection.gpkg: data/external/Exclusive_economic_zone_Mexico.shp bounding_box_config.json
	$(checkDirectories)
	Rscript src/export_mexico_eez_bounding_box_to_gpkg.R

data/processed/mexico_ezz_bounding_box_zoom_in.json: data/processed/mexico_eez_bounding_box_intersection.gpkg
	$(checkDirectories)
	Rscript src/export_mexico_eez_bounding_box_zoom_in_to_json.R

reports/figures/mexico_eez_bounding_box_zoom_in.png: data/processed/mexico_eez_bounding_box_intersection.gpkg data/processed/mexico_ezz_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_mexico_eez_bounding_box_intersection.R

reports/figures/mexico_eez_bounding_box_zoom_out.png: data/external/Exclusive_economic_zone_Mexico.shp bounding_box_config.json data/processed/mexico_ezz_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_mexico_eez_bounding_box_union.R

reports/figures/gps_albatross_50_percent_usage_area_ARS.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	trips_config_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_usage_area_by_individual(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path trips_config_guadalupe.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--n-iterations 1000 \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_site_ARS_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	trips_config_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_potential_site(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path trips_config_guadalupe.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--population-size 4390 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_site_ARS_all.png: \
	data/processed/trips_geographic_points_all.csv \
	trips_config_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_potential_site(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path trips_config_all.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--population-size 4437 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assess_ARS.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	trips_config_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_representative_assess(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path trips_config_guadalupe.json \
		--percentage-distribution 50 \
		--n-iterations 1000 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ARS_guadalupe.png: \
	data/processed/trips_geographic_points_guadalupe.csv \
	trips_config_guadalupe.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_guadalupe.csv \
		--config-path trips_config_guadalupe.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ARS_clarion.png: \
	data/processed/trips_geographic_points_clarion.csv \
	trips_config_clarion.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_clarion.csv \
		--config-path trips_config_clarion.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel_ARS_all.png: \
	data/processed/trips_geographic_points_all.csv \
	trips_config_all.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_all.csv \
		--config-path trips_config_all.json \
		--percentage-distribution 50 \
		--smoothing-method scale_ARS \
		--output-path $@

reports/figures/gps_albatross_50_percent_kernel_density.png: \
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

reports/figures/gps_albatross_kernel_density.png: \
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

reports/figures/gps_albatross_geographic_points.png: \
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

reports/figures/gps_albatross_geographic_points_2025.png: \
	data/processed/gps_albatros_guadalupe_2025.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/processed/gps_albatros_guadalupe_2025.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/gps_albatros_guadalupe_2025.csv: \
	data/raw/gps-albatros-guadalupe.csv 
	$(checkDirectories)
	Rscript -e "bycatch::filter_data_between_dates(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--start 2025-01-01 \
		--end 2025-12-31 \
		--date-column-name date \
		--output-path $@

reports/figures/gps_albatross_geographic_points_by_trip.png: \
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

data/processed/trips_geographic_points_guadalupe.csv: \
	data/raw/gps-albatros-guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--config-path trips_config_guadalupe.json \
		--output-path $@

data/processed/trips_geographic_points_clarion.csv: \
	data/raw/gps-albatros-clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-clarion.csv \
		--config-path trips_config_clarion.json \
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
		--config-path trips_config_guadalupe.json \
		--output-path $@

data/processed/trips_summary_clarion.csv: \
	data/processed/trips_geographic_points_clarion.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_clarion.csv \
		--config-path trips_config_clarion.json \
		--output-path $@

data/processed/trips_summary_all.csv: \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv
	rm --force $@
	csvstack data/processed/trips_summary_*.csv > $@

reports/figures/gps_albatross_clarion_geographic_points.png: \
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

data/processed/overlap_kernel_intersection_25.gpkg: data/processed/vessel_kernel_union_25.gpkg data/processed/seabird_kernel_union_25.gpkg
	$(checkDirectories)
	Rscript "src/intersect_vessel_seabird_kernels.R"

reports/figures/kernel_overlap_home_ranges_union_25.png reports/figures/kernel_overlap_home_ranges_union_25_zoom.png: data/processed/overlap_kernel_intersection_25.gpkg data/processed/vessel_kernel_union_25.gpkg data/processed/seabird_kernel_union_25.gpkg
	$(checkDirectories)
	Rscript "src/plot_overlap_home_ranges.R"

data/processed/vessel_home_ranges_25.gpkg data/processed/vessel_kernel_union_25.gpkg: data/external/vessel_data_pacific_2014.csv
	$(checkDirectories)
	Rscript "src/generate_vessel_kernel_home_ranges.R"

reports/figures/kernel_vessel_home_ranges_map_25.png reports/figures/kernel_vessel_home_ranges_union_25.png: data/processed/vessel_home_ranges_25.gpkg data/processed/vessel_kernel_union_25.gpkg
	$(checkDirectories)
	Rscript "src/plot_vessel_home_ranges.R"

data/processed/seabird_home_ranges_25.gpkg data/processed/seabird_kernel_union_25.gpkg: data/processed/trips_geographic_points_guadalupe.csv
	$(checkDirectories)
	Rscript "src/generate_seabird_kernel_home_ranges.R"

reports/figures/kernel_seabird_home_ranges_map_25.png reports/figures/kernel_seabird_home_ranges_union_25.png: data/processed/seabird_home_ranges_25.gpkg data/processed/seabird_kernel_union_25.gpkg
	$(checkDirectories)
	Rscript "src/plot_seabird_home_ranges.R"

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

reports/figures/anp.png: data/external/232_ANP-ITRF08_04072025.shp
	$(checkDirectories)
	Rscript src/plot_anp.R

data/processed/gps_albatross_combined.csv: data/raw/gps-albatros-clarion.csv data/raw/gps-albatros-guadalupe.csv
	$(checkDirectories)
	Rscript src/join_gps_data.R

data/processed/anp_union.gpkg: data/external/232_ANP-ITRF08_04072025.shp
	$(checkDirectories)
	Rscript src/export_anp_to_gpkg.R

reports/figures/mexico.png: data/external/Mexico_e_islas_wgs84.shp
	$(checkDirectories)
	Rscript src/plot_mexico.R

data/processed/mexico_union.gpkg: data/external/Mexico_e_islas_wgs84.shp
	$(checkDirectories)
	Rscript src/export_mexico_to_gpkg.R

data/processed/mexico_mpa.gpkg: data/processed/anp_union.gpkg data/processed/mexico_union.gpkg
	$(checkDirectories)
	Rscript src/export_mexico_mpa_to_gpkg.R

reports/figures/mexico_mpa.png: data/processed/mexico_mpa.gpkg
	$(checkDirectories)
	Rscript src/plot_mexico_mpa.R

data/processed/overlap_amp_seabird_25.gpkg: data/processed/mexico_mpa.gpkg data/processed/seabird_kernel_union_25.gpkg
	$(checkDirectories)
	Rscript src/overlap_amp_seabird.R

reports/figures/overlap_amp_seabird.png: data/processed/overlap_amp_seabird_25.gpkg
	$(checkDirectories)
	Rscript src/plot_overlap_amp_seabird.R

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
	clean \
	format \
	green \
	init \
	red \
	refactor \
	results \
	setup \
	tests \
	tests_r

clean:
	rm --force *.pdf
	rm --force --recursive data/processed
	rm --force --recursive data/raw
	rm --force --recursive reports
	rm --force bounding_box_config.json
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

