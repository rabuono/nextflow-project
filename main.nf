#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Based on:
- Nextflow workshop from April 2025
    Github: https://github.com/vibbits/nextflow-workshop 

With inspirations from:
- nf-core/scrnaseq
    Github : https://github.com/nf-core/scrnaseq
----------------------------------------------------------------------------------------
*/


// Set default input parameters (these can be altered by calling their flag on the command line, e.g., nextflow run main.nf --reads 'mydata/*_R{1,2}.fastq')
params.reads = "${launchDir}/data/*_R{1,2}.fastq.gz" 
params.outdir = "${launchDir}/output"


// Include modules
// Adding from nf-core
include { FASTQC as raw_fastqc ; FASTQC as fastp_fastqc } from './modules/nf-core/fastqc/main'
include { FALCO as raw_falco ; FALCO as fastp_falco } from './modules/nf-core/falco/main'
include { FASTP } from './modules/nf-core/fastp/main'

// Adding local modules
include { MULTIQC as raw_multiqc_fastqc ; MULTIQC as raw_multiqc_falco ; MULTIQC as fastp_multiqc_fastqc ; MULTIQC as fastp_multiqc_falco} from './modules/local/multiqc/main'
include { DOWNLOAD_EXAMPLE_DATA } from './modules/local/download_example_data/main'
include { newnamefalco as raw_newnamefalco ; newnamefalco as fastp_newnamefalco  } from './modules/local/newnamefalco/main'


workflow {
    log.info """\
        LIST OF PARAMETERS
    ================================
    Reads            : ${params.reads}
    Output-folder    : ${params.outdir}/
    Make sure to check for the Nextflow report html file at the end of the run
    for resource usage of each process.
    Processes to compare:
    raw_falco - Running FALCO in raw samples
    raw_fastqc - Running FASTQC in raw samples
    fastp_falco - Running FALCO in fastp processed samples
    fastp_fastqc - Running FASTQC in fastp processed samples
    """
    
    // Create a channel for input reads and check if there are input files.
    // User is informed if no files were found and that example files will be downloaded.
def readsDir = file(params.reads)
if (readsDir.isEmpty()) {
    log.warn "No input files found at ${params.reads}"
    log.warn "Example files will be downloaded and used instead."
    DOWNLOAD_EXAMPLE_DATA()
    read_pairs_ch = DOWNLOAD_EXAMPLE_DATA.out
        .flatten()
        .map { file -> 
            def sampleId = file.name.toString().tokenize('_')[0]
            return tuple([id: sampleId], file)
        }
        .groupTuple(size: 2)
} else {
    read_pairs_ch = Channel
        .fromFilePairs(params.reads, checkIfExists:true)
        .map { sample_id, files -> [ [id: sample_id], files ] }
}

    // Remove comment to show resulting read_pairs channel
    //read_pairs_ch.view()

    // Run QC tools
	raw_fastqc(read_pairs_ch)
    raw_falco(read_pairs_ch)
    //raw_falco(read_pairs_ch_fastq) 

    // Create channel for FALCO file reorganization
    ch_raw_falco_rename = raw_falco.out.txt
    .map { sample_id, txt -> txt.parent }
    .collect()
    .map { it -> it.unique() }
    .flatMap { paths -> tuple(paths) }
    // Remove comment to view
    //.view()


    // Rename FALCO output and add to folder with sample name, as MultiQC expects a different file organization as the one in the FALCO output
    raw_newnamefalco (ch_raw_falco_rename)

    // Create separate channels for FASTQC and FALCO outputs
    ch_fastqc_multiqc = Channel.empty()
    ch_falco_multiqc = Channel.empty()
  
    // Populate channels
    ch_fastqc_multiqc = ch_fastqc_multiqc.mix(raw_fastqc.out.zip.map { it[1] }.collect())
    // Remove comment to view
    //ch_fastqc_multiqc.view()
    ch_falco_multiqc = ch_falco_multiqc.mix(raw_newnamefalco.out)
    //Remove comment to view
    //ch_falco_multiqc.view()

    // Run MultiQC separately for FASTQC and FALCO
    raw_multiqc_fastqc(ch_fastqc_multiqc.collect())
    raw_multiqc_falco(ch_falco_multiqc.collect())

    // Run fastp in the raw data
    // FASTP resulting reads files are saved in output for convenience
    FASTP(read_pairs_ch, [], false, false, false)
    
    // Create channel for FASTP output for FASTQC and FALCO
    ch_fastp = Channel.empty()
    
    // Populate FASTP channel
    ch_fastp = ch_fastp.mix(FASTP.out.reads.map { sample_id, files -> [ sample_id, files ] })
    
    // Remove comment to view
    //ch_fastp.view()

    /*
    Repeating FALCO and FASTQC after FASTP processing
    */

    // Run QC tools on processed data
	fastp_fastqc(ch_fastp)
    fastp_falco(ch_fastp)

    // Create channel for FALCO file reorganization after FASTP
    ch_fastp_falco_rename = fastp_falco.out.txt
    .map { sample_id, txt -> txt.parent }
    .collect()
    .map { it -> it.unique() }
    .flatMap { paths -> tuple(paths) }
    // Remove comment to view
    //.view()

    // Rename FALCO output after FASTP and add to folder with sample name, as MultiQC expects a different file organization as the one in the FALCO output
    fastp_newnamefalco (ch_fastp_falco_rename)

    // Create separate channels for FASTQC and FALCO outputs
    ch_fastp_fastqc_multiqc = Channel.empty()
    ch_fastp_falco_multiqc = Channel.empty()
  
    // Populate channels
    ch_fastp_fastqc_multiqc = ch_fastp_fastqc_multiqc.mix(fastp_fastqc.out.zip.map { it[1] }.collect())
    // Remove comment to view
    //ch_fastp_fastqc_multiqc.view()
    ch_fastp_falco_multiqc = ch_fastp_falco_multiqc.mix(fastp_newnamefalco.out)
    //Remove comment to view
    //ch_fastp_falco_multiqc.view()

    // Run MultiQC separately for FASTQC and FALCO
    fastp_multiqc_fastqc(ch_fastp_fastqc_multiqc.collect())
    fastp_multiqc_falco(ch_fastp_falco_multiqc.collect())

}

