#!/usr/bin/env nextflow

process process_download_and_read {
    input:
    path file_in

    output:
    path "processed/*"

    script:
    """
    Rscript 00-download_and_read.R --input ${file_in}
    """
}

workflow {

    Channel.fromPath(params.input_file)
        | set { raw_data_ch }

    process_download_and_read(raw_data_ch)
        | set { prepared_ch }

    process_prepare_expression(prepared_ch)
        | set { seurat_input_ch }

    process_basic_qc(seurat_input_ch)
        | set { split_ch }

    process_split_malignant(split_ch)
        | set { nonmalignant_ch, malignant_ch }

    process_nonmalignant_dimreduce(nonmalignant_ch)
        | set { nonmalignant_res_ch }

    process_nonmalignant_clustering(nonmalignant_res_ch)

    process_malignant_dimreduce(malignant_ch)
        | set { malignant_res_ch }

    process_trajectory(malignant_res_ch)
}
