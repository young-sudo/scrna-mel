#!/usr/bin/env nextflow

process DOWNLOAD_AND_READ {
    input:
        path file_in
    output:
        path "${params.outdir}/processed/*", emit: processed_data
    script:
        """
        Rscript scripts/00-download_and_read.R --input ${file_in} --outdir ${params.outdir}/processed
        """
}

process PREPARE_EXPRESSION {
    input:
        path processed_data
    output:
        path "${params.outdir}/prepared/*", emit: prepared_data
    script:
        """
        Rscript scripts/01-prepare_expression_and_metadata.R --input ${processed_data} --outdir ${params.outdir}/prepared
        """
}

process BASIC_QC {
    input:
        path prepared_data
    output:
        path "${params.outdir}/qc/*", emit: qc_data
    script:
        """
        Rscript scripts/02-create_seurat_object_and_basic_qc.R --input ${prepared_data} --outdir ${params.outdir}/qc
        """
}
    