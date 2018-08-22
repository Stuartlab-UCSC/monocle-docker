FROM rocker/tidyverse

COPY ./traj-converters /home/traj-converters

RUN R -e 'install.packages(c("optparse","gam"));source("https://bioconductor.org/biocLite.R");biocLite("monocle")'
