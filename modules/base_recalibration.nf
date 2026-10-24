process BASE_RECALIBRATION {
 label 'process_high'
 conda 'bioconda::gatk4=4.6.1.0'
 input:
 tuple val(meta), path(bam), path(bai)
 tuple path(reference), path(fai), path(dict)
 path known_sites
 path known_sites_index
 path intervals
 output:
 tuple val(meta), path("${meta.id}.recal.bam"), path("${meta.id}.recal.bai"), emit: bam
 script:
 """
 gatk BaseRecalibrator -R ${reference} -I ${bam} -L '${intervals}' \
   --known-sites '${known_sites}' -O ${meta.id}.recal.table
 gatk ApplyBQSR -R ${reference} -I ${bam} --bqsr-recal-file ${meta.id}.recal.table \
   -O ${meta.id}.recal.bam --create-output-bam-index true
 """
}
