all: \
	reports/anteproyecto.pdf \
	reports/first_paper.docx \
	reports/first_paper.pdf \
	reports/obsolete_results.pdf \
	reports/second_paper.docx \
	reports/second_paper.pdf

SHELL := /bin/bash

reports/first_paper.docx reports/first_paper.pdf: \
	data/processed/individual_kde_guadalupe.rds \
	data/processed/trips_summary_guadalupe.csv \
	papers/first-paper/10_metadata.yaml \
	reports/figures/gps_albatross_50_percent_potential_kba_ars_all_with_mpa.png \
	reports/figures/gps_albatross_geographic_points_raw_clarion.png \
	reports/figures/gps_albatross_geographic_points_raw_all.png \
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

data/processed/methods.json: \
	src/export_tracking_dates.R \
	data/raw/gps-albatros-guadalupe.csv \
	data/raw/gps-albatros-clarion.csv \
	data/raw/gps-albatros-san-benedicto.csv
	$(checkDirectories)
	Rscript src/export_tracking_dates.R

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
	reports/figures/gps_albatross_50_percent_potential_kba_ars_all_without_mpa.png \
	reports/figures/gps_albatross_50_percent_representative_assessment_ars_all.png \
	reports/figures/gps_albatross_geographic_points_by_trip_all.png \
	reports/figures/longline_events_map.png \
	reports/figures/gfw_longline_hotspot_binary_map_all.png \
	reports/figures/kba_and_gfw_longline_hotspot_map.png \
	reports/figures/kba_and_vms_hotspot_map.png \
	reports/figures/kba_and_vms_longline_hotspot_map.png \
	reports/figures/kba_and_radar_signal_hotspot_map.png \
	reports/figures/radar_signal_geographic_points_in_eez.png \
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

reports/obsolete_results.docx reports/obsolete_results.pdf: \
	papers/obsolete-results/00_metadata.yaml \
	papers/obsolete-results/obsolete-results.md \
	reports/figures/gfw_longline_hotspot_map_all.png \
	reports/figures/gps_albatross_geographic_points_raw_guadalupe.png \
	reports/figures/gps_albatross_geographic_points_raw_san_benedicto.png \
	reports/figures/radar_signal_geographic_points_albatross_guadalupe.png \
	reports/figures/vms_hotspot_binary_map.png \
	reports/figures/vms_hotspot_map.png
	$(checkDirectories)
	pandoc --metadata-file=papers/obsolete-results/00_metadata.yaml --output=$@ papers/obsolete-results/obsolete-results.md

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
	rm --force $@
	Rscript -e "bycatch::create_potential_kba(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_guadalupe.rds \
		--percentage-distribution 50 \
		--population-size 4390 \
		--output-path $@

# Filtra las trayectorias VMS para conservar puntos dentro de la ZEE mexicana
data/processed/vessel_trajectories.csv: \
  data/external/vessel_data_pacific.csv \
  data/external/vessel_info.csv
	$(checkDirectories)
	Rscript src/create_vessel_joined.R

# Cuenta puntos VMS por celda de la rejilla del KDE
data/processed/vms_in_grid.gpkg: \
  data/processed/vessel_trajectories.csv \
  data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript src/export_vms_in_grid.R

# Filtra las trayectorias VMS para conservar solo embarcaciones palangreras
data/processed/vessel_trajectories_longline.csv: \
  data/external/vessel_data_pacific.csv \
  data/external/vessel_info.csv
	$(checkDirectories)
	Rscript src/create_vessel_joined_longline.R

# Aplica Getis-Ord Gi* a los conteos VMS por celda
data/processed/vms_hotspot.gpkg: \
  data/processed/vms_in_grid.gpkg
	$(checkDirectories)
	Rscript src/compute_vms_hotspot.R

# Grafica el mapa de hot spots de congestión VMS
reports/figures/vms_hotspot_map.png: \
  data/processed/vms_hotspot.gpkg \
  data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_vms_hotspot.R

# Grafica el mapa binario de hot spots de congestión VMS
reports/figures/vms_hotspot_binary_map.png: \
  data/processed/vms_hotspot.gpkg \
  data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_vms_hotspot_binary.R

# Cuenta puntos de palangre de GFW por celda de la rejilla del KDE
data/processed/gfw_longline_in_grid.gpkg: \
  data/processed/longline_events_in_eez_without_gulf_of_california.csv \
  data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript src/export_gfw_longline_in_grid.R

# Aplica Getis-Ord Gi* a los conteos de palangre de GFW por celda
data/processed/gfw_longline_hotspot_all.gpkg: \
  data/processed/gfw_longline_in_grid.gpkg
	$(checkDirectories)
	Rscript src/compute_gfw_longline_hotspot.R

# Grafica el mapa continuo de hot spots de palangre de GFW
reports/figures/gfw_longline_hotspot_map_all.png: \
  data/processed/gfw_longline_hotspot_all.gpkg \
  data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_gfw_longline_hotspot.R

# Grafica el mapa binario de hot spots de palangre de GFW
reports/figures/gfw_longline_hotspot_binary_map_all.png: \
  data/processed/gfw_longline_hotspot_all.gpkg \
  data/processed/mexico_eez_bounding_box_zoom_in.json
	$(checkDirectories)
	Rscript src/plot_gfw_longline_hotspot_binary.R

# Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de palangre de GFW
data/processed/kba_hotspot_intersection.gpkg: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/gfw_longline_hotspot_all.gpkg
	$(checkDirectories)
	Rscript src/export_kba_hotspot_intersection.R

# Grafica el mapa combinado de KBA y hot spots de palangre de GFW
reports/figures/kba_and_gfw_longline_hotspot_map.png: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/gfw_longline_hotspot_all.gpkg \
  data/processed/kba_hotspot_intersection.gpkg \
  data/processed/mexico_mpa.gpkg \
  data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_and_gfw_longline_hotspot.R

# Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de congestión VMS
data/processed/kba_vms_hotspot_intersection.gpkg: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/vms_hotspot.gpkg
	$(checkDirectories)
	Rscript src/export_kba_vms_hotspot_intersection.R

# Grafica el mapa combinado de KBA y hot spots de congestión VMS
reports/figures/kba_and_vms_hotspot_map.png: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/vms_hotspot.gpkg \
  data/processed/kba_vms_hotspot_intersection.gpkg \
  data/processed/mexico_mpa.gpkg \
  data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_and_vms_hotspot.R

# Cuenta puntos VMS de palangre por celda de la rejilla del KDE
data/processed/vms_longline_in_grid.gpkg: \
  data/processed/vessel_trajectories_longline.csv \
  data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript src/export_vms_longline_in_grid.R

# Aplica Getis-Ord Gi* a los conteos VMS de palangre por celda
data/processed/vms_longline_hotspot.gpkg: \
  data/processed/vms_longline_in_grid.gpkg
	$(checkDirectories)
	Rscript src/compute_vms_longline_hotspot.R

# Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de congestión VMS de palangre
data/processed/kba_vms_longline_hotspot_intersection.gpkg: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/vms_longline_hotspot.gpkg
	$(checkDirectories)
	Rscript src/export_kba_vms_longline_hotspot_intersection.R

# Grafica el mapa combinado de KBA y hot spots de congestión VMS de palangre
reports/figures/kba_and_vms_longline_hotspot_map.png: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/vms_longline_hotspot.gpkg \
  data/processed/kba_vms_longline_hotspot_intersection.gpkg \
  data/processed/mexico_mpa.gpkg \
  data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_and_vms_longline_hotspot.R

# Calcula la intersección entre el sitio potencial KBA y las celdas hot spot de señal de radar
data/processed/kba_radar_signal_hotspot_intersection.gpkg: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/radar_signal_hotspot.gpkg
	$(checkDirectories)
	Rscript src/export_kba_radar_signal_hotspot_intersection.R

# Grafica el mapa combinado de KBA y hot spots de señal de radar
reports/figures/kba_and_radar_signal_hotspot_map.png: \
  data/processed/kba_polygons_all.gpkg \
  data/processed/radar_signal_hotspot.gpkg \
  data/processed/kba_radar_signal_hotspot_intersection.gpkg \
  data/processed/mexico_mpa.gpkg \
  data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_and_radar_signal_hotspot.R

data/processed/kba_mpa_intersection_all.gpkg: \
	data/processed/kba_polygons_all.gpkg \
	data/processed/mexico_mpa.gpkg
	$(checkDirectories)
	Rscript src/export_kba_mpa_intersection.R

data/processed/kba_mpa_intersection_guadalupe.gpkg: \
	data/processed/kba_polygons_guadalupe.gpkg \
	data/processed/mexico_mpa.gpkg
	$(checkDirectories)
	Rscript src/export_kba_guadalupe_mpa_intersection.R

reports/figures/gps_albatross_50_percent_potential_kba_ars_all_with_mpa.png: \
	data/processed/kba_mpa_intersection_all.gpkg \
	data/processed/kba_polygons_all.gpkg \
	data/processed/mexico_mpa.gpkg \
	data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_mpa_intersection.R

reports/figures/gps_albatross_50_percent_potential_kba_ars_guadalupe_with_mpa.png: \
	data/processed/kba_mpa_intersection_guadalupe.gpkg \
	data/processed/kba_polygons_guadalupe.gpkg \
	data/processed/mexico_mpa.gpkg \
	data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_kba_guadalupe_mpa_intersection.R

# 4437 = 47 individuals in Clarion Island (2023) + 4390 individuals in Guadalupe Island
data/processed/kba_polygons_all.gpkg: \
	data/processed/representative_assessment_all.rds
	$(checkDirectories)
	rm --force $@
	Rscript -e "bycatch::create_potential_kba(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/representative_assessment_all.rds \
		--percentage-distribution 50 \
		--population-size 4437 \
		--output-path $@

reports/figures/gps_albatross_50_percent_potential_kba_ars_all_without_mpa.png: \
	data/processed/kba_polygons_all.gpkg \
	data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/plot_potential_kba_all.R

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

reports/figures/gps_albatross_50_percent_individual_kde_ars_all.png: \
	data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript -e "bycatch::render_individual_kde(bycatch::get_domain_specific_options())" \
		--rds-path data/processed/individual_kde_all.rds \
		--output-path $@

reports/figures/radar_signal_geographic_points_albatross_guadalupe.png: \
	data/processed/radar_signal_geographic_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli render-radar-signal-geographic-points \
		--radar-signal-data-path data/processed/radar_signal_geographic_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

reports/figures/radar_signal_geographic_points_in_eez.png: \
	data/processed/radar_signal_geographic_points_in_eez.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli render-radar-signal-geographic-points \
		--radar-signal-data-path data/processed/radar_signal_geographic_points_in_eez.csv \
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

data/processed/radar_signal_geographic_points_in_eez.csv: \
	data/processed/radar_signal_geographic_points.csv \
	data/external/Exclusive_economic_zone_Mexico.shp
	$(checkDirectories)
	Rscript src/remove_outside_eez_from_radar_signal_geographic_points.R

# Suma valores de señal de radar por celda de la rejilla del KDE
data/processed/radar_signal_in_grid.gpkg: \
  data/processed/radar_signal_geographic_points_in_eez.csv \
  data/processed/individual_kde_all.rds
	$(checkDirectories)
	Rscript src/export_radar_signal_in_grid.R

# Aplica Getis-Ord Gi* a las sumas de señal de radar por celda
data/processed/radar_signal_hotspot.gpkg: \
  data/processed/radar_signal_in_grid.gpkg
	$(checkDirectories)
	Rscript src/compute_radar_signal_hotspot.R

data/processed/gps_albatross_guadalupe_2025.csv: \
	data/raw/gps-albatros-guadalupe.csv 
	$(checkDirectories)
	Rscript -e "bycatch::create_filtered_gps_between_dates(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-guadalupe.csv \
		--start 2025-01-01 \
		--end 2025-12-31 \
		--date-column-name date \
		--output-path $@

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

data/processed/trips_geographic_points_san_benedicto.csv: \
	data/raw/gps-albatros-san-benedicto.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips(bycatch::get_domain_specific_options())" \
		--data-path data/raw/gps-albatros-san-benedicto.csv \
		--config-path config_trips_san_benedicto.json \
		--output-path $@

data/processed/trips_geographic_points_all.csv: \
	data/processed/trips_geographic_points_clarion.csv \
	data/processed/trips_geographic_points_guadalupe.csv \
	data/processed/trips_geographic_points_san_benedicto.csv
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

data/processed/trips_summary_san_benedicto.csv: \
	data/processed/trips_geographic_points_san_benedicto.csv
	$(checkDirectories)
	Rscript -e "bycatch::create_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/trips_geographic_points_san_benedicto.csv \
		--config-path config_trips_san_benedicto.json \
		--output-path $@

data/processed/trips_summary_all.csv: \
	data/processed/trips_summary_clarion.csv \
	data/processed/trips_summary_guadalupe.csv \
	data/processed/trips_summary_san_benedicto.csv
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

reports/figures/gps_albatross_geographic_points_raw_all.png: \
	data/processed/gps_albatross_all.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/processed/gps_albatross_all.csv \
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

# Reorganiza los eventos de palangre de GFW a formato largo por punto extremo
data/processed/longline_events_long.csv: \
  data/external/oorg_2025_geci_longline_events_v20260402.csv
	$(checkDirectories)
	Rscript src/export_longline_events_long.R

# Elimina los eventos de palangre de GFW que caen dentro del Golfo de California y fuera de la ZEE de México
data/processed/longline_events_in_eez_without_gulf_of_california.csv: \
	data/external/Exclusive_economic_zone_Mexico.shp \
	data/processed/longline_events_long.csv \
	data/raw/gulf_of_california.kml
	$(checkDirectories)
	Rscript src/remove_gulf_of_california_from_longline_events.R

reports/figures/longline_events_map.png: data/external/oorg_2025_geci_longline_events_v20260402.csv
	$(checkDirectories)
	Rscript src/plot_longline_events.R

data/processed/gps_albatross_all.csv: \
	data/raw/gps-albatros-clarion.csv \
	data/raw/gps-albatros-guadalupe.csv \
	data/raw/gps-albatros-san-benedicto.csv
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

