process FASTP {
 label 'process_medium'
 conda 'bioconda::fastp=0.23.4'
 input:
 tuple val(meta), path(read1), path(read2)
 output:
 tuple val(meta), path("${meta.id}_R1.fastq.gz"), path("${meta.id}_R2.fastq.gz"), emit: reads
 path '*.fastp.html', emit: html
 path '*.fastp.json', emit: json
 script:
 """
 fastp --thread ${task.cpus} --detect_adapter_for_pe --qualified_quality_phred 20 \
   --length_required ${params.min_length} --in1 '${read1}' --in2 '${read2}' \
   --out1 ${meta.id}_R1.fastq.gz --out2 ${meta.id}_R2.fastq.gz \
   --html ${meta.id}.fastp.html --json ${meta.id}.fastp.json
 """
}
