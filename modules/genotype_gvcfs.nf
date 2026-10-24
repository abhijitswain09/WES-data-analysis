process GENOTYPE_GVCFS {
 label 'process_high'
 conda 'bioconda::gatk4=4.6.1.0'
 input:
 tuple path(gvcf), path(gvcf_index)
 tuple path(reference), path(fai), path(dict)
 output:
 path 'cohort.vcf.gz', emit: vcf
 path 'cohort.vcf.gz.tbi', emit: index
 script:
 """
 gatk GenotypeGVCFs -R ${reference} -V ${gvcf} -O cohort.vcf.gz
 gatk IndexFeatureFile -I cohort.vcf.gz
 """
}
