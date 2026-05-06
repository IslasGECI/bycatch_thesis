FROM islasgeci/bycatch:latest
COPY . /workdir
RUN apt update && apt install --yes \
        aspell-es && \
    apt clean && rm --force --recursive /var/lib/apt/lists/*
RUN pip install --upgrade pip && pip install \
	git+https://github.com/IslasGECI/geci_plots.git \
	zenodo-api
RUN R -e "install.packages(c('rnaturalearth','rnaturalearthdata','ggspatial'), repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('IslasGECI/bycatch_code', ref='latest', upgrade='never')"
RUN R -e "remotes::install_github('IslasGECI/seabird_tracking', ref='latest', upgrade='never')"
