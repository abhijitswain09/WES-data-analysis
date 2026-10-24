process BWA_ALIGN {
 label 'process_high'
 conda 'bioconda::bwa=0.7.17 bioconda::samtools=1.20'
 input:
 tuple val(meta), path(read1), path(read2)
 tuple path(reference), path(fai), path(dict)
 tuple path(amb), path(ann), path(bwt), path(pac), path(sa)
 output:
 tuple val(meta), path("${meta.id}.bam"), path("${meta.id}.bam.bai"), emit: bam
 path '*.flagstat.txt', emit: stats
 script:
 """
 bwa mem -t ${task.cpus} -R '@RG\tID:${meta.id}\tSM:${meta.id}\tPL:ILLUMINA\tLB:${meta.id}' \
   ${reference} '${read1}' '${read2}' 2> ${meta.id}.alignment.txt \
   | samtools sort -@ ${task.cpus} -o ${meta.id}.bam -
 samtools index -@ ${task.cpus} ${meta.id}.bam
    samtools flagstat -@ ${task.cpus} ${meta.id}.bam > ${meta.id}.flagstat.txt
 """
}
