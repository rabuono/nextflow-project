process MULTIQC {
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

}