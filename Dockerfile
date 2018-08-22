FROM rocker/tidyverse

COPY ./traj-converters /home/rstudio

RUN R -e 'install.packages(c("optparse","gam"));source("https://bioconductor.org/biocLite.R");biocLite("monocle")'
