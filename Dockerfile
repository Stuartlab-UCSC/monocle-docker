FROM rocker/tidyverse

ADD ./traj-converters /home/traj-converters

COPY ./src /home/src

ENV PATH="/home/src:${PATH}"

RUN R -e 'install.packages(c("optparse","gam"));source("https://bioconductor.org/biocLite.R");biocLite("monocle")'
