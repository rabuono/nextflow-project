process MULTIQC {
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.28--pyhdfd78af_0' :
        'biocontainers/multiqc:1.28--pyhdfd78af_0' }"
    
        

    input:
    path multiqc_files

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots

    script:
    """
    multiqc .
    """
   // to check for falco output
    /*"""
    echo "Checking for Falco output..."
    if ls *falco* 1> /dev/null 2>&1; then
        echo "Falco output found:"
        ls -l *falco*
    else
        echo "No Falco output found in the current directory."
        echo "Contents of the current directory:"
        ls -l
    fi

    echo "Running MultiQC..."
    multiqc . -v
    """*/
}