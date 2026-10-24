process HAPLOTYPE_CALLER {
 label 'process_high'
 conda 'bioconda::gatk4=4.6.1.0'
 input:
 tuple val(meta), path(bam), path(bai)
 tuple path(reference), path(fai), path(dict)
 path intervals
 output:
 tuple val(meta), path("${meta.id}.g.vcf.gz"), path("${meta.id}.g.vcf.gz.tbi"), emit: gvcf
 script:
 """
 gatk HaplotypeCaller -R ${reference} -I ${bam} -L '${intervals}' \
   -ERC GVCF --native-pair-hmm-threads ${task.cpus} -O ${meta.id}.g.vcf.gz
 gatk IndexFeatureFile -I ${meta.id}.g.vcf.gz
 """
}
