//Will download the example data below. Used when users do not provide data.

process DOWNLOAD_EXAMPLE_DATA {
    //publishDir "${params.outdir}", mode: 'copy'

   container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/wget:1.21.4' :
        'quay.io/biocontainers/wget:1.21.4' }"
    output:
    path "example_data/*", emit: exampledata

    script:
    """
    # Update package lists and install wget
    apt-get update && apt-get install -y wget
    
    # Download example data
    exampledatalink=ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR201

    LIST="ERR2015047/SC01_R1.fastq.gz
    ERR2015047/SC01_R2.fastq.gz
    ERR2015048/SC02_R1.fastq.gz
    ERR2015048/SC02_R2.fastq.gz
    ERR2015049/SC03_R1.fastq.gz
    ERR2015049/SC03_R2.fastq.gz
    ERR2015050/SC04_R1.fastq.gz
    ERR2015050/SC04_R2.fastq.gz
    ERR2015051/SC05_R1.fastq.gz
    ERR2015051/SC05_R2.fastq.gz
    ERR2015052/SC06_R1.fastq.gz
    ERR2015052/SC06_R2.fastq.gz
    ERR2015053/SC07_R1.fastq.gz
    ERR2015053/SC07_R2.fastq.gz
    ERR2015054/SC08_R1.fastq.gz
    ERR2015054/SC08_R2.fastq.gz
    ERR2015055/SC09_R1.fastq.gz
    ERR2015055/SC09_R2.fastq.gz
    ERR2015056/SC10_R1.fastq.gz
    ERR2015056/SC10_R2.fastq.gz"
    
    
    mkdir -p example_data
    for sample in \$LIST; do
      echo "Downloading \$sample"
      wget -P example_data -np \${exampledatalink}/\$sample
      
    done
    """


    
}