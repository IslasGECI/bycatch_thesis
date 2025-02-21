all: dummy_report.pdf


reports/dummy_report.pdf: reports/dummy_report.tex
	$(renderLatex)

reports/dummy_report.tex: reports/non-tabular/results.json
	jinja-render \
	--report-name "dummy_report" \
	--summary-path "reports/non-tabular/results.json"

reports/non-tabular/results.json:
	$(checkDirectories)
	echo '{"A":2 , "B":3 , "total":5}' > reports/non-tabular/results.json

data/processed/bl_gps_albatross_guadalupe.csv: \
	data/raw/datapackage.json \
	data/raw/gps-albatros-guadalupe.csv \
	data/raw/breeding_status_albatross_guadalupe.csv
	$(checkDirectories)
	cd data/raw && R -e "seabird.tracking::write_bl_table()"
	mv data/raw/bl_gps_albatross_guadalupe.csv $@

data/raw/gps-albatros-guadalupe.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/breeding_status_albatross_guadalupe.csv:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

data/raw/datapackage.json:
	$(checkDirectories)
	descarga_datos $(@F) $(@D) seabird_tracking

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
	setup \
	tests \
	tests_r

clean:
	rm --force --recursive reports/figures/
	rm --force --recursive reports/non-tabular/
	rm --force --recursive reports/tables/
	rm --force --recursive data
	rm --force *.pdf



init: init_git
	shellspec --init

init_git:
	git config --global --add safe.directory /workdir
	git config --global user.name "Ciencia de Datos • GECI"
	git config --global user.email "ciencia.datos@islas.org.mx"


setup: clean init_git


