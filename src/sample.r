#!/usr/local/bin/Rscript

input <- commandArgs(trailingOnly=TRUE)[1]
output <- commandArgs(trailingOnly=TRUE)[2]
seed <- commandArgs(trailingOnly=T)[3]

set.seed(seed)

data_in_sample_out <- function(file, out){
  # Read tab matrix from shared dir.
  #mat <- as.matrix(read.table(paste(c("/data/",file),collapse=""), sep="\t", header=T, row.names=1))
  mat <- as.matrix(read.table(file, sep="\t", header=T, row.names=1))
  
  cols <- sample(colnames(mat), floor(.90 * dim(mat)[2]))
  write.table(mat[,cols],file=out, sep="\t")
}

data_in_sample_out(input, output)

