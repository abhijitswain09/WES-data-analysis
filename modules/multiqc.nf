process MULTIQC {
 label 'process_low'
 conda 'bioconda::multiqc=1.25.1'
 input:
 path reports
 output:
 path 'multiqc_report.html'
 path 'multiqc_data'
 script:
 """
 multiqc --force --outdir . ${reports.join(' ')}
 """
}
