
rule all:
       input:
             expand("../{results}/fastqc/{sample}_{read}.fastq.zip", results=config["results"], sample=config["samples"], read = config["reads"]),
             expand("../{results}/multiqc/multiqc_report.html", results=config["results"])

rule fastqc:
    input:
         expand("../{results}/{sample}_{read}.fastq.gz", results=config["results"], sample=config["samples"], read = config["reads"])
    output:
         "../{results}/fastqc/{sample}_{read}.fastq.zip"
    conda:
          "../envs/preprocessing.yaml"
    params:
          outdir = "{results}/qc/fastqc"
    shell:
         """
            fastqc {input} --outdir={params.outdir}
         """

rule multiqc:
    input:
         expand("../{results}/fastqc/{sample}_{read}.fastq.zip", results=config["results"], sample=config["samples"], read = config["reads"])
    output:
          "../{results}/multiqc/multiqc_report.html"
    params:
            indir = "{results}/fastqc",
            outdir = "{results}/multiqc"
    conda:
            "../envs/preprocessing.yaml"
    shell:
            """
                multiqc {params.indir} -o {params.outdir}
            """
