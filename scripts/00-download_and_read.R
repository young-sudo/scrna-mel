#!/usr/bin/env Rscript

# 00-download_and_read.R
# Download (optional) and read the raw matrix file into R
# Configure paths

# raw_dir <- "data/raw"
out_dir <- "data/processed"
# dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Path to the gz file (if already downloaded)
# file_in <- file.path(raw_dir, "GSE72056_melanoma_single_cell_revised_v2.txt.gz")

library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), type="character", help="Input file"),
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

file_in <- opt$input

if (!file.exists(file_in)) {
  message("File not found: ", file_in)
  message("Please download from GEO:")
  message("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE72nnn/GSE72056/suppl/GSE72056_melanoma_single_cell_revised_v2.txt.gz")
  stop("Data file missing")
}

# Read table (fast) -- stringsAsFactors = FALSE
message("Reading data...")
raw <- data.table::fread(file_in, header = TRUE, data.table = FALSE)

# Save a copy in RDS for faster loading later
saveRDS(raw, file = file.path(out_dir, "raw_tirosh_table.rds"))
message("Saved raw RDS to ", file.path(out_dir, "raw_tirosh_table.rds"))
