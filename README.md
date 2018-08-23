# monocle-docker
Environment for executing the monocle trajectory inference algorithm.
Contains [functions](https://github.com/Stuartlab-UCSC/traj-converters) to convert the output to [common formats](https://github.com/Stuartlab-UCSC/traj-formats). The container is hosted on [docker hub](https://hub.docker.com/r/stuartlab/monocle/).

The main purpose of the container is to minimize installation woes by 
facilitating development and analysis inside the container. This has the
desirable side effect of reproducible computation environments. I'm
willing to work with people if the container design doesn't fit a
particular workflow (e.g. doesn't do jupyter notebook at the moment).
Please submit a 'would be nice' issue and I'll have a peak and see what
I can do.

The docker containers can also be run stand alone and `exec`'d into.
If that's more your slice of pie see the second workflow example below.

For instructions below I suggest creating a shared volume,
`./shared` in the directory you are launching the docker from. This 
volume acts as shared storage. The shared storage is the easiest way to
access input and write output from the container.

## Example workflow analysis with monocle outputing common formats

starting from a bash shell:
```bash
# pull the docker image down to your machine
docker pull stuartlab/monocle

# Move into some directory and make a space for shared storage.
cd some/directory && mkdir shared

# Move the data you'd like into shared storage
cp ../../Astrocyte_cds.rda ./shared

# Run the containers Rstudio server
docker run -v $(pwd)/shared:/home/rstudio/shared -d -p 8787:8787 -e ROOT=TRUE stuartlab/monocle
```
 
From there open your favorite browser (tested on chrome) at `http://localhost:8787/`. The default password and username are both `rstudio`.

Now use the editor to create a script that runs on your data, and save
the script to `/home/rstudio/shared` inside the container. An example
script could be something as short as:
```R
library(monocle)
# Make random data for testing
#rd <- replicate(110, rnbinom(500, c(3, 10, 45, 100), .1))
#colnames(rd)<- 1:110
#Astrocyte_cds <- newCellDataSet(rd)

# Contains an Astrocyte_cds CellDataSet 
load("/home/rstudio/shared/Astrocyte_cds.rda")

# Monocle analysis pipeline
Astrocyte_cds <- estimateSizeFactors(Astrocyte_cds)
Astrocyte_cds <- estimateDispersions(Astrocyte_cds)
Astrocyte_ordering_genes <- subset(dispersionTable(Astrocyte_cds), mean_expression>=0.1)
Astrocyte_cds <- setOrderingFilter(Astrocyte_cds, Astrocyte_ordering_genes)
Astrocyte_cds <- reduceDimension(Astrocyte_cds, max_components = 2, method = "DDRTree")
Astrocyte_cds <- orderCells(Astrocyte_cds)
# Astrocyte_cds is now a completed monocle S4 class instance.

# source the r script with the converters for monocle.
source("/home/traj-converters/src/R/monocle_convert.r")

# output the common json and cell_x_branch matrix from the monocle object
write_cell_x_branch(Astrocyte_cds, file="/home/rstudio/shared/Astro.monocle.cellxbranch.tab")
write_common_json(Astrocyte_cds, file="/home/rstudio/shared/Astro.monocle.json")
```

 After executing each line of that script in rstudio's console (e.g. using ctrl + enter shortcut of Rstudio's editor) you will have a `./shared/Astro.monocle.json` and a `./shared/Astro.monocle.cellxbranch.tab` file on your
 local machine.
 

