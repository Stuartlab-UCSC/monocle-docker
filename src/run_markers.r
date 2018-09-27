#!/usr/local/bin/Rscript

# example usage:
# Rscript run_markers.r <cell_x_branch.tab> <expression.tab>
# outputs a 'markers.gmt' file in the /data directory of the
# container.

suppressMessages(library("gam"))
default_file_name <- '/data/markers.gmt'

cell_x_branch <- commandArgs(trailingOnly=TRUE)[1]
expression <-  commandArgs(trailingOnly=TRUE)[2]
output <-  commandArgs(trailingOnly=TRUE)[3]

if (is.na(output)){
   output <- default_file_name
} else {
   output <- paste(c("/data/", output), collapse="")
}

# Max number of markers allowed per branch
#max <-  commandArgs(trailingOnly=TRUE)[3]


branch_markers <- function(cell_x_branch, expression, cutoff=.01, max=100){
  # Uses gam method used here: https://www.bioconductor.org/packages/devel/bioc/vignettes/slingshot/inst/doc/slingshot.html#identifying-temporally-expressed-genes
  # Returns a list of branch ids pointing to a ranked vector of gene names (ordered starting with miniumum pvalue) having an Fstat pvalue less than cutoff.  
  # expression: gene x cell matrix, values expression levels. should have hugo gene names
  # cell_x_branch: cell x branch matrix, values pseudotime assignment.
  # cutoff: (0, 1] number. only genes with pvalues less than this number will be included in the gene ranking.
  
  branch_names <- colnames(cell_x_branch)
  top_genes_list <- list()
  for (branch_id in branch_names){
    # remove
    message(branch_id[1])
    tmp_pseudotime <- cell_x_branch[,branch_id]
    cells_have_values <- names(tmp_pseudotime)[!is.na(tmp_pseudotime)]
    tmp_pseudotime <- tmp_pseudotime[!is.na(tmp_pseudotime)]
    tmp_expression <- expression[,cells_have_values]
    gam.pval <- apply(tmp_expression,1,function(z){
      d <- data.frame(z=z, t=tmp_pseudotime)
      tmp <- gam(z ~ lo(t), data=d)
      p <- summary(tmp)[4][[1]][1,5]
      p
    })
    gene_names <- names(sort(gam.pval[gam.pval< .01]))
    if (length(gene_names) > max) {
	   gene_names <- gene_names[1:max]
    } 
    top_genes_list[[branch_id]] <- gene_names
  }
  
  top_genes_list
}


read_data <- function(file){
  # Read tab matrix from shared dir.
  as.matrix(read.table(paste(c("/data/",file),collapse=""), sep="\t", header=T, row.names=1))
}


write_gmt <- function(marker_list, filename){
  file_conn<-file(filename)
  lines <- c()
  for (name in names(marker_list)){
    paste(c(name, "", marker_list[[name]]),collapse="\t")
    lines <- c(lines, paste(c(name, "", marker_list[[name]]),collapse="\t"))
  }
  writeLines(lines, file_conn)
  close(file_conn)
}


message("Reading data...")
cxb <- read_data(cell_x_branch)
exp <- read_data(expression)

message("Determining markers per branch...")
marker_list <- branch_markers(cxb, exp)

for (name in names(marker_list)){
    m <- paste(c(length(marker_list[[name]]), "markers found on", name), collapse=" ")
    message(m)
}

message("Writing to gmt...")
write_gmt(marker_list, output)

message("Completed.")
