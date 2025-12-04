#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { DOWNLOAD_AND_READ; PREPARE_EXPRESSION; BASIC_QC } from './modules/preprocessing.nf'
include { SPLIT_MALIGNANT; NONMALIGNANT_DIMREDUCE; NONMALIGNANT_CLUSTER;
          MALIGNANT_DIMREDUCE; TRAJECTORY } from './modules/analysis.nf'

workflow {

    raw_ch = Channel.fromPath(params.input_file)
    
    processed_ch = DOWNLOAD_AND_READ(raw_ch)
    prepared_ch  = PREPARE_EXPRESSION(processed_ch)
    qc_ch        = BASIC_QC(prepared_ch)
    
    (nonmal_ch, mal_ch) = SPLIT_MALIGNANT(qc_ch)
    nonmal_res = NONMALIGNANT_DIMREDUCE(nonmal_ch)
    NONMALIGNANT_CLUSTER(nonmal_res)
    mal_res = MALIGNANT_DIMREDUCE(mal_ch)
    TRAJECTORY(mal_res)
}
