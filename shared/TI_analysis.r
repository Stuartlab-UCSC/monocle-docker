library(monocle)
source("/home/traj-converters/src/R/monocle_convert.r")

# High level functions.
get_data <- function(){
  # Return an expression matrix.
  # e.g. return(read.table("/home/rstudio/some-data.tab"))
  # or create random data for testing:
  set.seed(13)
  rd <- replicate(110, rnbinom(500, c(3, 10, 45, 100), .1))
  colnames(rd)<- 1:110
  return(rd)
}
monocle_analysis <- function(expression_matrix){
  # Return a completed monocle object
  cds <- newCellDataSet(expression_matrix)
  cds <- estimateSizeFactors(cds)
  cds <- estimateDispersions(cds)
  Astrocyte_ordering_genes <- subset(dispersionTable(cds), mean_expression>=0.1)
  cds <- setOrderingFilter(cds, Astrocyte_ordering_genes)
  cds <- reduceDimension(cds, max_components = 2, method = "DDRTree")
  cds <- orderCells(cds)
  return(cds)
}

# Execute pipeline.
exp_mat <- get_data()
monocle_obj <- monocle_analysis(exp_mat)

# Write to common format.
write_common_json(monocle_obj, file="/home/shared/monocle.json")
