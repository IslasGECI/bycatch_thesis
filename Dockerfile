FROM islasgeci/bycatch:latest
COPY . /workdir

RUN pip install --upgrade pip && pip install \
    git+https://github.com/IslasGECI/geci_plots.git \
    zenodo-api

RUN R -e "remotes::install_github('IslasGECI/bycatch_code', ref='latest')"
RUN R -e "remotes::install_github('IslasGECI/seabird_tracking', ref='latest')"
