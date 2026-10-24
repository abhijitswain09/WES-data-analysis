process COMBINE_GVCFS {
 label 'process_high'
 conda 'bioconda::gatk4=4.6.1.0'
 input:
 path gvcfs
 tuple path(reference), path(fai), path(dict)
 output:
 path 'cohort.g.vcf.gz', emit: gvcf
    path 'cohort.g.vcf.gz.tbi', emit: index
 script:
 """
 gatk_args=()
    for gvcf in *.g.vcf.gz; do gatk_args+=( -V "$gvcf" ); done
    gatk CombineGVCFs -R ${reference} "${gatk_args[@]}" -O cohort.g.vcf.gz
    gatk IndexFeatureFile -I cohort.g.vcf.gz
 """
}
