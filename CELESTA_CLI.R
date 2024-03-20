library(CELESTA)
library(Rmixmod)
library(spdep)
library(ggplot2)
library(reshape2)
library(zeallot)
library(optparse)

# Creating the Input options for the CLI 
option_list = list(
  make_option(c("-i", "--image_data"), type = "character", default = NULL, help = "path to quantification dataset with X/Y coordinates in csv format", metavar = "character"),
  make_option(c("-s", "--signature"), type = "character", default = NULL, help = "path to the signature matrix in csv format", metavar = "character"),
  make_option(c("--high"), type = "character", default = NULL, help = "path to as csv file with high thresholds for anchor (row1) and index (row2) cells, including a header with markers", metavar = "character"),
  make_option(c("--low"), type = "character", default = NULL, help = "optional path to as csv file with low thresholds for anchor (row1) and index (row2) cells, including a header with markers", metavar = "character"),
  make_option(c("-o", "--output"), type = "character", default = NULL, help = "optional path to stored the result .csv files, if not specified, current working directory will be used", metavar = "character"),
  make_option(c("-t", "--title"), type = "character", default = NULL, help = "optional project title used as a tag for the results", metavar = "character")
);

#Creating the opt_parser object from the option_list
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Check, if the 4 required inputs were prompted
if (is.null(opt$image_data) || is.null(opt$signature) || is.null(opt$high)){
  print_help(opt_parser)
  stop("At least these 3 inputs are required: --image_data (-i), --signature (-s), --high")
}

#Produce the inputs required for CELSTA algorithm
imaging_data = read.csv(opt$image_data)
prior_marker_info = read.csv(opt$signature)
high_marker_threshold_anchor = as.vector(read.csv(opt$high, header = TRUE)[1, ])
high_marker_threshold_iteration = as.vector(read.csv(opt$high, header = TRUE)[2, ])

# Adjust MCMICRO input for CELESTA
names(imaging_data)[names(imaging_data) == "X_centroid"] <- "X"
names(imaging_data)[names(imaging_data) == "Y_centroid"] <- "Y"
imaging_data <- imaging_data[, !names(imaging_data) %in% c("Area", "MajorAxisLength", "MinorAxisLength", "Eccentricity", "Solidity", "Extent", "Orientation")]

# If we do not get an input for low thresholds, we want to create our own vector with length of the other vectors consisting of only 1's
if (is.null(opt$low)) {
  low_marker_threshold_anchor = rep(1, length(high_marker_threshold_anchor))
} else {
  low_marker_threshold_anchor = as.vector(read.csv(opt$low, header = TRUE)[1, ])
}

if (is.null(opt$low)) {
  low_marker_threshold_iteration = rep(1, length(high_marker_threshold_anchor))
} else {
  low_marker_threshold_iteration = as.vector(read.csv(opt$low, header = TRUE)[2, ])
}

#If no folder is given, set to current working directory
if (is.null(opt$output)) {
  output_folder = getwd() 
} else {
  output_folder = as.character(opt$output)
}

if (is.null(opt$title)) {
  title = ""
} else {
  title = as.character(opt$title)
}


### The pre-saved imaging data is taken from reg009 of the published CODEX data Schurch et al. Cell,2020
### Create CELESTA object. It requires a title for the project. 
### It also required the segmented input file and user-defined cell-type signature matrix.
### Please refer to the Inputs session below.
CelestaObj <- CreateCelestaObject(project_title = title, prior_marker_info,imaging_data)

### Filter out questionable cells. 
### A cell with every marker having expression probability higher than 0.9 are filtered out. 
### And A cell with every marker having expression probability lower than 0.4 are filtered out. 
### User can define the thresholds based on inspecting their data. 
### **This step is optional.** We suggest starting without running this step to see whether there are many doublets/triplets.
CelestaObj <- FilterCells(CelestaObj,high_marker_threshold=0.9, low_marker_threshold=0.4)

### Assign cell types. 
### max_iteration is used to define the maximum iterations allowed in the EM algorithm per round. 
### cell_change_threshold is a user-defined ending condition for the EM algorithm. 
### For example, 0.01 means that when fewer than 1% of the total number of cells do not change identity, the algorithm will stop.
CelestaObj <- AssignCells(CelestaObj,max_iteration=10,cell_change_threshold=0.01,
                          high_expression_threshold_anchor=high_marker_threshold_anchor,
                          low_expression_threshold_anchor=low_marker_threshold_anchor,
                          high_expression_threshold_index=high_marker_threshold_iteration,
                          low_expression_threshold_index=low_marker_threshold_iteration,
                          save_result = F)

### After the AssignCells() function, the CELESTA assigned cell types will be stored in the CelestaObj
### in the field called final_cell_type_assignment with each row corresponding to a cell. 
### The final_cell_type_assignment has assignment for each round stored in each column, the final 
### cell types and the corresponding cell type number corresponding to the cell type specified in 
### the cell-type signature matrix (please see Input section below).

### Plot cells with CELESTA assigned cell types.
### The cell_number_to_use corresponds to the defined numbers in the prior cell-type signature matrix.
### For example, 1 corresponds to endothelial cell, 2 corresponds to tumor cell.
### The program will plot the corresponding cell types given in the "cell_number_to_use" parameter.
### To plot the "unknown" cells that are left unassigned by CELESTA, include 0 in the list.
### The default color for unknown cells is gray.
### The size of the cells plotted can be modified by changing the parameter test_size.
#PlotCellsAnyCombination(cell_type_assignment_to_plot=CelestaObj@final_cell_type_assignment[,(CelestaObj@total_rounds+1)],
#                        coords = CelestaObj@coords,
#                        prior_info = prior_marker_info,
#                        cell_number_to_use=c(1,2,3),
#                        cell_type_colors=c("yellow","red","blue"),
#                        test_size=1)
#
### To include unknown cells
#PlotCellsAnyCombination(cell_type_assignment_to_plot=CelestaObj@final_cell_type_assignment[,(CelestaObj@total_rounds+1)],
#                        coords = CelestaObj@coords,
#                        prior_info = prior_marker_info,
#                        cell_number_to_use=c(0,1,2,3),cell_type_colors=c("yellow","red","blue"))
#
#### plot expression probability
#PlotExpProb(coords=CelestaObj@coords,
#            marker_exp_prob=CelestaObj@marker_exp_prob,
#            prior_marker_info = prior_marker_info,
#            save_plot = TRUE)


final_celltypes = as.data.frame(CelestaObj@final_cell_type_assignment)$'Final cell type'

celesta_results = cbind(
  imaging_data,
  final_celltypes)

inspection = cbind(
  CelestaObj@cell_ID,
  CelestaObj@marker_exp_prob,
  final_celltypes)
colnames(inspection)[1] = "CellID"

## Use file.path to construct full file paths and write CSVs according to predefined filenames
write.csv(celesta_results, paste0(title, "_celesta_results.csv"))
write.csv(inspection, paste0(title, "_quality.csv"))
