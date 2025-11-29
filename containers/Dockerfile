FROM rocker/r-ver:4.4.0

# system libraries for Seurat and monocle3
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libfftw3-dev \
    libhdf5-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libudunits2-dev \
    libgsl-dev \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e 'install.packages(c("ggplot2", "patchwork", "fpc", "dplyr", "irlba", "Rtsne", "data.table"))'
RUN R -e 'install.packages(c("Seurat", "SeuratWrappers"), repos="https://cloud.r-project.org")'
RUN R -e 'if (!requireNamespace("BiocManager")) install.packages("BiocManager")'
RUN R -e 'BiocManager::install(c("monocle3", "Biobase", "BiocGenerics"))'
RUN R -e 'install.packages("optparse")'
