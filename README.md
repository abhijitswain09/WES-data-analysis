# WES data analysis with Nextflow

A standalone Nextflow DSL2 workflow for paired-end germline whole-exome sequencing. It runs raw and trimmed read QC, fastp trimming, BWA alignment, duplicate marking, optional base quality score recalibration (BQSR), per-sample GATK HaplotypeCaller gVCFs, optional cohort joint genotyping, and MultiQC.

## Requirements

Nextflow 24.04 or later and Docker (recommended) or Conda/Mamba. The Docker profile uses Wave to build containers from the pinned Bioconda environments.

## Run

Make a CSV with one row per paired-end sample:

    sample,fastq_1,fastq_2
    SAMPLE_01,data/SAMPLE_01_R1.fastq.gz,data/SAMPLE_01_R2.fastq.gz
    SAMPLE_02,data/SAMPLE_02_R1.fastq.gz,data/SAMPLE_02_R2.fastq.gz

Then launch the pipeline:

    nextflow run abhijitswain09/WES-data-analysis -profile docker --input samplesheet.csv --fasta genome.fa --intervals exome_targets.bed --outdir results

The FASTA should match the reference build used to create the capture intervals. BED, GATK interval_list, and VCF interval inputs are supported. The workflow creates FASTA indexes and a sequence dictionary.

### Optional BQSR

Provide known variant sites and the matching index to enable BaseRecalibrator and ApplyBQSR:

    --known_sites dbsnp.vcf.gz --known_sites_index dbsnp.vcf.gz.tbi

Use sites prepared for the same reference build. Without these parameters, the workflow skips BQSR and calls variants from duplicate-marked BAMs.

### Optional cohort genotyping

By default, the workflow keeps one GVCF per sample. Enable joint genotyping when all samples belong to the same cohort and use the same reference and target intervals:

    --joint_genotyping true

This combines the sample GVCFs and emits a cohort VCF. This is a germline workflow, not a somatic variant caller.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| --input | required | CSV with sample, fastq_1, fastq_2 |
| --fasta | required | Reference genome FASTA |
| --intervals | required | WES capture target intervals |
| --known_sites | unset | Known-sites VCF used for BQSR |
| --known_sites_index | unset | Matching .tbi or .idx |
| --min_length | 30 | Minimum read length retained by fastp |
| --joint_genotyping | false | Combine GVCFs and run cohort genotyping |
| --outdir | results | Output directory |

## Outputs

- fastqc: raw and trimmed read QC reports
- fastp: trimmed paired reads and fastp reports
- bwa_align: coordinate-sorted indexed BAMs and flagstat summaries
- mark_duplicates: duplicate-marked BAMs, indexes, and metrics
- base_recalibration: recalibrated BAMs when known sites are supplied
- haplotype_caller: per-sample compressed GVCFs and indexes
- combine_gvcfs and genotype_gvcfs: cohort GVCF and VCF when joint genotyping is enabled
- multiqc: combined QC report
- pipeline_info: Nextflow report, timeline, and trace

Sample paths in the CSV are resolved from the directory where Nextflow is launched. Keep sample IDs unique and use only letters, numbers, dots, underscores, and hyphens.

## License

MIT
