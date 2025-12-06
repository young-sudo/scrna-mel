#!/usr/bin/env Rscript

# 04-nonmalignant_preprocess_and_dimreduce.R
library(Seurat)
library(ggplot2)
library(optparse)

non_malignant <- readRDS("results/non-malignant/seurat/non_malignant_seurat.rds")
out_dir <- "results/non_malignant/dimreduce"

option_list <- list(
  make_option(c("-i", "--input"), type="character", default=non_malignant, help="Input file"),
  make_option(c("-o", "--outdir"), type="character", default=out_dir, help="Output directory")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)
non_malignant <- opt$input
out_dir <- opt$outdir
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)


# Annotate cell types from the metadata mapping used in the Rmd
cluster_names <- c("unresolved", "T-cells", "B-cells", "Macrophages", "Endothelial", "CAF", "NK")
if ("non.malignant.cell.type..1.T.2.B.3.Macro.4.Endo..5.CAF.6.NK" %in% colnames(non_malignant@meta.data)) {
  non_malignant@meta.data$cell_type <- cluster_names[non_malignant@meta.data$non.malignant.cell.type..1.T.2.B.3.Macro.4.Endo..5.CAF.6.NK + 1]
}

# Normalization / scaling / PCA
non_malignant <- NormalizeData(non_malignant)
all.genes <- rownames(non_malignant)
non_malignant <- ScaleData(non_malignant, features = all.genes)
non_malignant <- RunPCA(non_malignant, features = all.genes)

# Variable features + PCA using variable features
non_malignant <- FindVariableFeatures(non_malignant, selection.method = "vst", nfeatures = 1000)

non_malignant <- ScaleData(non_malignant)
non_malignant <- RunPCA(non_malignant, features = VariableFeatures(object = non_malignant))

# Run UMAP/tSNE using first 15 PCs (set seeds for reproducibility)
set.seed(3)
non_malignant <- RunTSNE(non_malignant, dims = 1:15, seed.use = 3)
set.seed(1)
non_malignant <- RunUMAP(non_malignant, dims = 1:15, seed.use = 1, n.neighbors = 10)


# Plot and save figures
# Create figures directory
fig_dir <- file.path(out_dir, "figures")
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# Variable features plot
# Identify the 10 most highly variable genes
top10 <- head(VariableFeatures(non_malignant), 10)

# plot variable features with and without labels
plot1 <- VariableFeaturePlot(non_malignant)
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)

ggsave(
  filename = file.path(fig_dir, "variable_features.png"),
  plot = plot2,
  width = 8, height = 6, dpi = 300
)

# t-SNE colored by cell type
tsne_celltype <- DimPlot(
  non_malignant,
  reduction = "tsne",
  group.by = "cell_type",
  pt.size = 1.5,
  label = FALSE
) + ggtitle(NULL)

ggsave(
  filename = file.path(fig_dir, "tsne_cell_type.png"),
  plot = tsne_celltype,
  width = 6, height = 5, dpi = 300
)

# t-SNE colored by tumor ID
tsne_tumor <- DimPlot(
  non_malignant,
  reduction = "tsne",
  group.by = "tumor_id",
  pt.size = 1.5,
  label = FALSE
) + ggtitle(NULL)

ggsave(
  filename = file.path(fig_dir, "tsne_tumor_id.png"),
  plot = tsne_tumor,
  width = 6, height = 5, dpi = 300
)

# UMAP colored by cell type
umap_celltype <- DimPlot(
  non_malignant,
  reduction = "umap",
  group.by = "cell_type",
  pt.size = 1.5,
  label = FALSE
) + ggtitle(NULL)

ggsave(
  filename = file.path(fig_dir, "umap_cell_type.png"),
  plot = umap_celltype,
  width = 6, height = 5, dpi = 300
)

# UMAP colored by tumor ID
umap_tumor <- DimPlot(
  non_malignant,
  reduction = "umap",
  group.by = "tumor_id",
  pt.size = 1.5,
  label = FALSE
) + ggtitle(NULL)

ggsave(
  filename = file.path(fig_dir, "umap_tumor_id.png"),
  plot = umap_tumor,
  width = 6, height = 5, dpi = 300
)


outfile <- file.path(out_dir, "non_malignant_dimreduced.rds")
saveRDS(non_malignant, file = outfile)
message("Saved non-malignant processed object to ", outfile)
