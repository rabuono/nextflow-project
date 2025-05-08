// Reorganizes the FALCO output into a format expected by MULTIQC

process newnamefalco {
    //publishDir "${params.outdir}", mode: 'copy'

    input:
    path falco_output

    output:
    path '*', emit: out

    script:
    """
    echo "Contents of input directory:"
    ls -R ${falco_output}
    
    for data_file in ${falco_output}/*.fastq.gz_fastqc_data.txt; do
        filename=\$(basename "\$data_file")
        # Remove '.fastq.gz_fastqc_data.txt' to get 'SC01_R1'
        sample_name=\${filename%.fastq.gz_fastqc_data.txt}

        echo "Processing: \$sample_name"

        mkdir -p "\$sample_name"

        cp "\$data_file" "./\$sample_name/fastqc_data.txt"
        cp "${falco_output}/\${sample_name}.fastq.gz_fastqc_report.html" "./\$sample_name/fastqc_report.html"
        cp "${falco_output}/\${sample_name}.fastq.gz_summary.txt" "./\$sample_name/summary.txt"
    done
    """
}