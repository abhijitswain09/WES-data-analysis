process MARK_DUPLICATES {
 label 'process_high'
 conda 'bioconda::gatk4=4.6.1.0'
 input:
 tuple val(meta), path(bam), path(bai)
 output:
 tuple val(meta), path("${meta.id}.dedup.bam"), path("${meta.id}.dedup.bai"), emit: bam
 path '*.metrics.txt', emit: metrics
 script:
 """
 gatk MarkDuplicates -I ${bam} -O ${meta.id}.dedup.bam -M ${meta.id}.metrics.txt --CREATE_INDEX true
 """
}
