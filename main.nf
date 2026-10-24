#!/usr/bin/env nextflow
nextflow.enable.dsl=2
include { FASTQC as FASTQC_RAW; FASTQC as FASTQC_TRIMMED } from './modules/fastqc'
include { FASTP } from './modules/fastp'
include { REFERENCE_PREP } from './modules/reference_prep'
include { BWA_ALIGN } from './modules/bwa_align'
include { MARK_DUPLICATES } from './modules/mark_duplicates'
include { BASE_RECALIBRATION } from './modules/base_recalibration'
include { HAPLOTYPE_CALLER } from './modules/haplotype_caller'
include { COMBINE_GVCFS } from './modules/combine_gvcfs'
include { GENOTYPE_GVCFS } from './modules/genotype_gvcfs'
include { MULTIQC } from './modules/multiqc'
workflow {
    if (!params.input) error 'Missing --input samplesheet CSV'
    if (!params.fasta) error 'Missing --fasta reference genome FASTA'
    if (!params.intervals) error 'Missing --intervals WES capture targets (BED, interval_list, or VCF)'
    samplesheet = file(params.input, checkIfExists: true)
    reads = channel.fromPath(samplesheet).splitCsv(header: true, strip: true).collect().flatMap { rows ->
        if (!rows) error 'Samplesheet has no data rows'
        ids = rows.collect { it.sample }
        if (ids.any { !it } || ids.size() != ids.unique().size()) error 'Sample IDs must be present and unique'
        rows.collect { row ->
            if (!row.fastq_1 || !row.fastq_2) error 'Samplesheet requires non-empty sample, fastq_1, and fastq_2 columns'
            if (!(row.sample ==~ /[A-Za-z0-9][A-Za-z0-9._-]*/)) {
                error "Invalid sample ID '${row.sample}': use letters, numbers, dot, underscore, or hyphen"
            }
            tuple([id: row.sample], file(row.fastq_1, checkIfExists: true), file(row.fastq_2, checkIfExists: true))
        }
    }
    fasta = file(params.fasta, checkIfExists: true)
    intervals = file(params.intervals, checkIfExists: true)
    FASTQC_RAW(reads)
    FASTP(reads)
    FASTQC_TRIMMED(FASTP.out.reads)
    REFERENCE_PREP(fasta)
    reference = REFERENCE_PREP.out.reference.first()
    indexes = REFERENCE_PREP.out.index.first()
    BWA_ALIGN(FASTP.out.reads, reference, indexes)
    MARK_DUPLICATES(BWA_ALIGN.out.bam)
    if (params.known_sites) {
        if (!params.known_sites_index) error 'Set --known_sites_index to the matching .tbi/.idx when --known_sites is used'
        known_sites = file(params.known_sites, checkIfExists: true)
        known_sites_index = file(params.known_sites_index, checkIfExists: true)
        BASE_RECALIBRATION(MARK_DUPLICATES.out.bam, reference, known_sites, known_sites_index, intervals)
        analysis_bam = BASE_RECALIBRATION.out.bam
    } else {
        analysis_bam = MARK_DUPLICATES.out.bam
    }
    HAPLOTYPE_CALLER(analysis_bam, reference, intervals)
    if (params.joint_genotyping) {
        sample_gvcfs = HAPLOTYPE_CALLER.out.gvcf.map { meta, gvcf, index -> [gvcf, index] }.collect(flat: true)
        cohort_gvcf = COMBINE_GVCFS(sample_gvcfs, reference)
        GENOTYPE_GVCFS(cohort_gvcf.out.gvcf, reference)
    }
    qc_reports = FASTQC_RAW.out.html.mix(FASTQC_RAW.out.zip)
        .mix(FASTQC_TRIMMED.out.html).mix(FASTQC_TRIMMED.out.zip)
        .mix(FASTP.out.html).mix(FASTP.out.json).mix(BWA_ALIGN.out.stats).collect()
    MULTIQC(qc_reports)
}
