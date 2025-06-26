all: reports/anteproyecto.docx \
	reports/anteproyecto.pdf \
	reports/articulo_uno.docx \
	reports/articulo_uno.pdf


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

reports/draft.md:
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

results: \
	data/processed/trips_geographic_points.csv \
	data/processed/trips_summary.csv \
	reports/figures/gps_albatross_50_percent_individuals_kernel.png \
	reports/figures/gps_albatross_50_percent_representative_assess.png \
	reports/figures/gps_albatross_50_percent_usage_area.png \
	reports/figures/gps_albatross_75_percent_individuals_kernel.png \
	reports/figures/gps_albatross_95_percent_individuals_kernel.png \
	reports/figures/gps_albatross_geographic_points_by_trip.png \
	reports/figures/gps_albatross_geographic_points.png \
	reports/figures/gps_fisheries_geographic_points_2014.png \
	reports/figures/gps_fisheries_geographic_points.png \
	reports/figures/gps_fisheries_percent_kernel_density.png

reports/figures/gps_albatross_95_percent_individuals_kernel.png: \
	data/processed/bl_gps_albatross_guadalupe.csv \
	trips_config.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--percentage-distribution 95 \
		--output-path $@

reports/figures/gps_albatross_75_percent_individuals_kernel.png: \
	data/processed/bl_gps_albatross_guadalupe.csv \
	trips_config.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--percentage-distribution 75 \
		--output-path $@

reports/figures/gps_albatross_50_percent_usage_area.png: \
	data/processed/bl_gps_albatross_guadalupe.csv \
	trips_config.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_usage_area_by_individual(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--percentage-distribution 50 \
		--n-iterations 100 \
		--output-path $@

reports/figures/gps_albatross_50_percent_representative_assess.png: \
	data/processed/bl_gps_albatross_guadalupe.csv \
	trips_config.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_representative_assess(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--percentage-distribution 50 \
		--n-iterations 100 \
		--output-path $@

reports/figures/gps_albatross_50_percent_individuals_kernel.png: \
	data/processed/bl_gps_albatross_guadalupe.csv \
	trips_config.json
	$(checkDirectories)
	Rscript -e "bycatch::plot_individual_kernels(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--percentage-distribution 50 \
		--output-path $@

reports/figures/gps_albatross_50_percent_kernel_density.png: \
	data/processed/trips_geographic_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-kernel-density \
		--geographic-data-path data/processed/trips_geographic_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--selected-contour "50_contour" \
		--bandwidth 0.005 \
		--result-map-path $@

reports/figures/gps_albatross_kernel_density.png: \
	data/processed/trips_geographic_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-kernel-density \
		--geographic-data-path data/processed/trips_geographic_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--selected-contour "All_contours" \
		--bandwidth 0.005 \
		--result-map-path $@

reports/figures/gps_albatross_geographic_points.png: \
	data/processed/trips_geographic_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points \
		--geographic-data-path data/processed/trips_geographic_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

reports/figures/gps_albatross_geographic_points_by_trip.png: \
	data/processed/trips_geographic_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points-by-trip \
		--geographic-data-path data/processed/trips_geographic_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/trips_geographic_points.csv: \
	data/processed/bl_gps_albatross_guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--output-path $@

data/processed/trips_summary.csv: \
	data/processed/bl_gps_albatross_guadalupe.csv
	$(checkDirectories)
	Rscript -e "bycatch::write_trips_summary(bycatch::get_domain_specific_options())" \
		--data-path data/processed/bl_gps_albatross_guadalupe.csv \
		--config-path trips_config.json \
		--output-path $@

data/processed/bl_gps_albatross_guadalupe.csv: \
	data/raw/datapackage.json \
	data/raw/gps-albatros-guadalupe.csv \
	data/raw/breeding_status_albatross_guadalupe.csv
	$(checkDirectories)
	cd data/raw && R -e "seabird.tracking::write_bl_table()"
	mv data/raw/bl_gps_albatross_guadalupe.csv $@

reports/figures/gps_fisheries_percent_kernel_density.png: \
	data/processed/fisheries_gps_points_2014.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-kernel-density \
		--geographic-data-path data/processed/fisheries_gps_points_2014.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--selected-contour "All_contours" \
		--bandwidth 0.005 \
		--result-map-path $@

reports/figures/gps_fisheries_geographic_points.png: \
	data/processed/fisheries_gps_points.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points-by-vessel \
		--geographic-data-path data/processed/fisheries_gps_points.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

reports/figures/gps_fisheries_geographic_points_2014.png: \
	data/processed/fisheries_gps_points_2014.csv \
	data/raw/division_politica_paises.shp \
	data/raw/division_politica_paises.shx \
	data/raw/rosewind.png
	$(checkDirectories)
	geci-plot-cli plot-geographic-points-by-vessel \
		--geographic-data-path data/processed/fisheries_gps_points_2014.csv \
		--global-shapefile-data-path data/raw/division_politica_paises.shp \
		--path-rose-wind data/raw/rosewind.png \
		--result-map-path $@

data/processed/fisheries_gps_points_2014.csv:
	$(checkDirectories)
	Rscript -e "dafishr::vms_download(2014,'data/raw/')"
	Rscript src/concatenate_fishery_data_dafishr.R
	iconv -c -f ascii -t utf-8 -o data/processed/fisheries_gps_points_2014.csv data/processed/fisheries_gps_points_ascii.csv
	sed -i "s/,Latitud,/,Latitude,/" data/processed/fisheries_gps_points_2014.csv
	sed -i "s/,Longitud,/,Longitude,/" data/processed/fisheries_gps_points_2014.csv

data/processed/fisheries_gps_points.csv:
	$(checkDirectories)
	geci-zenodo download-from-geci-zenodo --doi "10.5281/zenodo.15102444"
	unzip *.zip -d data/raw/conapesca/
	Rscript src/concatenate_fishery_data.R
	iconv -c -f ascii -t utf-8 -o data/processed/fisheries_gps_points.csv data/processed/fisheries_gps_points_ascii.csv
	sed -i "s/,Latitud,/,Latitude,/" data/processed/fisheries_gps_points.csv
	sed -i "s/,Longitud,/,Longitude,/" data/processed/fisheries_gps_points.csv


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
	rm --force --recursive reports
	rm --force --recursive data
	rm --force *.pdf



init: init_git
	shellspec --init

init_git:
	git config --global --add safe.directory /workdir
	git config --global user.name "Ciencia de Datos • GECI"
	git config --global user.email "ciencia.datos@islas.org.mx"


setup: clean init_git
