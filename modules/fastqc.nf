process FASTQC {
 label 'process_low'
 conda 'bioconda::fastqc=0.12.1'
 input:
 tuple val(meta), path(read1), path(read2)
 output:
 path '*_fastqc.html', emit: html
 path '*_fastqc.zip', emit: zip
 script:
 """
 fastqc --threads ${task.cpus} --outdir . '${read1}' '${read2}'
 """
}
