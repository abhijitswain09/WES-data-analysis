process REFERENCE_PREP {
 label 'process_high'
 conda 'bioconda::bwa=0.7.17 bioconda::samtools=1.20 bioconda::gatk4=4.6.1.0'
 input:
 path fasta, name: 'reference.fa'
 output:
 tuple path('reference.fa'), path('reference.fa.fai'), path('reference.dict'), emit: reference
 tuple path('reference.fa.amb'), path('reference.fa.ann'), path('reference.fa.bwt'), path('reference.fa.pac'), path('reference.fa.sa'), emit: index
 script:
 """
 samtools faidx reference.fa
 gatk CreateSequenceDictionary -R reference.fa -O reference.dict
 bwa index reference.fa
 """
}
