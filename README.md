# nextflow-project
A repository for delivering the nextflow project

## Summary
The pipeline is meant as an exercise for the 2025 April session of the [VIB-TCP Nextflow Project](https://github.com/vib-tcp/project_nextflow_microcredential).

The pipeline can help users compare computational resource usage by two quality control tools:
- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/): A widely used quality control tool for high-throughput nucleotide sequencing data that provides an overview of quality metrics.
- [FALCO](https://github.com/smithlabcode/falco): A high-speed drop-in replacement tool for FastQC. It is designed to offer the same functionality as FastQC but have higher efficiency in the use of computational resources.  

It will also run [fastp](https://nf-co.re/modules/fastp/) with default values on the input data and provide resulting modifed sequencing files.

## Input
The pipeline expects data in the `data/` directory, that is in the same directory as the one in which the pipeline is launched.  
Input data is of expected format `*_R{1,2}.fastq.gz`, for example: `DC01_R1.fastq.gz`.      
In case input data is not provided, the pipeline will download example data from the European Nucleotide Archive [Project PRJEB21504](https://www.ebi.ac.uk/ena/browser/view/PRJEB21504). 

## Output
The pipeline outputs to the 'output/' folder that is created in the directory from which the pipeline is launched from.  
- falco_multiqc: MultiQC results for the samples analysed with Falco. Provided for convenient comparison of results.  
- fastqc_multiqc: MultiQC results for the samples analysed with FastQC.  Provided for convenient comparison of results.  
- FASTP: modified `fastq.gz` files resulting from using fastp.

## Using
It is made to run at the [HPC Ugent](https://www.ugent.be/hpc/en), and uses Singularity as the default profile