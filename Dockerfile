FROM islasgeci/bycatch:latest
COPY . /workdir

RUN pip install --upgrade pip && pip install \
        git+https://github.com/IslasGECI/geci_plots.git \
        zenodo-api
RUN R -e "install.packages(c('rnaturalearth','rnaturalearthdata'), repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('IslasGECI/bycatch_code', ref='hot_fix/parse_dates', force=TRUE)"
RUN R -e "remotes::install_github('IslasGECI/seabird_tracking', ref='latest', upgrade='never')"
