# scRNA-seq pipeline

_by Younginn Park_

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=R&logoColor=white)
![Seurat](https://img.shields.io/badge/Seurat-b689ee?style=for-the-badge&logo=R&logoColor=white)
![Monocle3](https://img.shields.io/badge/Monocle3-2c3e50?style=for-the-badge&logo=R&logoColor=white)
![Nextflow](https://img.shields.io/badge/Nextflow-DSL2-23CC85?style=for-the-badge&logo=nextflow&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Apptainer](https://img.shields.io/badge/Apptainer-2E6CE6?style=for-the-badge&logo=linuxcontainers&logoColor=white) 

Reproducible melanoma scRNA-seq pipeline combining Tirosh et al. reanalysis with extended trajectory and pseudotime modeling using Seurat and Monocle3.

The dataset used in this project can be found [here](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72056) with download links ([https](https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE72056&format=file&file=GSE72056%5Fmelanoma%5Fsingle%5Fcell%5Frevised%5Fv2%2Etxt%2Egz)/[ftp](https://ftp.ncbi.nlm.nih.gov/geo/series/GSE72nnn/GSE72056/suppl/GSE72056%5Fmelanoma%5Fsingle%5Fcell%5Frevised%5Fv2.txt.gz)).

Reference article: Tirosh et al., 2016 - Dissecting the multicellular ecosystem of metastatic melanoma by single-cell RNA-seq ([PubMed](https://pubmed.ncbi.nlm.nih.gov/27124452/))

<p align="center">
  <img src="https://raw.githubusercontent.com/young-sudo/scrna-pipe/main/figures/plot_m-tsne-novf-tumor.png" width="300"/>
  <img src="https://raw.githubusercontent.com/young-sudo/scrna-pipe/main/figures/plot_nm-tsne-vf-cell.png" width="300"/>
</p>

---

# Usage

This pipeline can be run reproducibly with **Nextflow** using Docker, Singularity/Apptainer, Conda, or local execution.

---

## Get the pipeline

Clone the repository:

```bash
git clone https://github.com/young-sudo/scrna-pipe.git
cd scrna-pipe
```

## (Optional) Build the Docker image

If you want to build the container locally instead of pulling it automatically:

```bash
docker build -t r-scrna-pipe:latest .
```

You can then run the pipeline using your local image:

```bash
nextflow run main.nf -profile docker --docker.image r-scrna-pipe:latest
```


## Run the entire workflow

**Docker (or Singularity/Apptainer fallback on HPC):**
```bash
nextflow run main.nf -profile docker
```

Singularity/Apptainer directly:

```bash
nextflow run main.nf -profile apptainer
```

Conda/local environment:
```bash
nextflow run main.nf -profile conda
```

Local execution without containers:
```bash
nextflow run main.nf -profile standard
```

## Pass input parameters

You can override default parameters:

```bash
nextflow run main.nf -profile docker --input_file data/raw/GSE72056_melanoma_single_cell_revised_v2.txt.gz --outdir results
```
* `--input_file` → Path to the input `.txt.gz` file
* `--outdir` → Output directory for processed data and results

---

# Project Overview

This repository contains a modular, reproducible workflow for analyzing melanoma scRNA-seq data, including both reanalysis of published results and extended trajectory modeling.

### Step-by-step pipeline

1. **Data acquisition and reading** (`00-download_and_read.R`):

   * Download and load the raw Tirosh melanoma single-cell data into R.

2. **Expression and metadata preparation** (`01-prepare_expression_and_metadata.R`):

   * Clean the raw data.
   * Construct gene expression matrix and cell metadata.
   * Handle duplicate genes and remove inconsistent entries.

3. **Seurat object creation and basic QC** (`02-create_seurat_object_and_basic_qc.R`):

   * Create a Seurat object.
   * Add mitochondrial percentage.
   * Initial QC plots and filtering for feature/cell counts.

4. **Malignant and non-malignant cell separation** (`03-filter_and_split_malignant.R`):

   * Subset cells into malignant vs. non-malignant populations.

5. **Non-malignant cells preprocessing and dimensionality reduction** (`04-nonmalignant_preprocess_and_dimreduce.R`):

   * Normalize, scale, identify variable genes.
   * PCA, t-SNE, and UMAP dimensionality reduction.

6. **Non-malignant clustering and visualization** (`05-nonmalignant_clustering_and_qc_plots.R`):

   * Construct SNN graph and find clusters.
   * Visualize clusters and tumor ID distributions.
   * Save diagnostic plots to `figures/`.

7. **Malignant cells preprocessing and dimensionality reduction** (`06-malignant_preprocess_and_dimreduce.R`):

   * Normalize, scale, PCA, t-SNE, UMAP for malignant population.

8. **Trajectory analysis with Monocle3** (`07-trajectory_monocle3.R`):

   * Convert Seurat malignant subset to Monocle3 CellDataSet.
   * Preprocess, dimensionality reduction, cluster, and learn trajectory graph.
   * Optional pseudotime ordering.


