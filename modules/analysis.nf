#!/usr/bin/env nextflow

process SPLIT_MALIGNANT {
    input:
        path qc_data
    output:
        tuple(path("nonmalignant/*"), path("malignant/*")), emit: (nonmal_ch, mal_ch)
    script:
        """
        Rscript scripts/03-split_malignant_nonmalignant.R --input ${qc_data} --outdir ${params.outdir}/split
        """
}

process NONMALIGNANT_DIMREDUCE {
    input:
        path nonmal_ch
    output:
        path "nonmalignant_dimreduce/*", emit: nonmal_res
    script:
        """
        Rscript scripts/04-nonmalignant_dimensionality_reduction.R --input ${nonmal_ch} --outdir ${params.outdir}/nonmal_dimred
        """
}

process NONMALIGNANT_CLUSTER {
    input:
        path nonmal_res
    output:
        path "nonmalignant_clusters/*"
    script:
        """
        Rscript scripts/05-nonmalignant_clustering.R --input ${nonmal_res} --outdir ${params.outdir}/nonmal_clust
        """
}

process MALIGNANT_DIMREDUCE {
    input:
        path mal_ch
    output:
        path "malignant_dimreduce/*", emit: mal_res
    script:
        """
        Rscript scripts/06-malignant_dimensionality_reduction.R --input ${mal_ch} --outdir ${params.outdir}/mal_dimred
        """
}

process TRAJECTORY {
    input:
        path mal_res
    output:
        path "malignant_trajectory/*"
    script:
        """
        Rscript scripts/07-malignant_trajectory_analysis.R --input ${mal_res} --outdir ${params.outdir}/mal_traj
        """
}
