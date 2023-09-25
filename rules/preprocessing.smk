# Preprocessing of raw reads ###################################################

# import modules ###############################################################
#rule all:
#    input:
#        expand("{results}/qc/cleaned/{sample}_{read}.{format}.gz", results=config["results"], sample=config["samples"], read = config["reads"], format = config["format"])

import os
import glob

# functions ####################################################################


# rules ########################################################################

if (config["format"] == "fastq"):
    # fastqc analysis
	if (config["fastqc"]== "TRUE"):

		rule fastqc:
			input:
				expand("{raw}/{sample}_{read}.fastq.gz", raw=config["raw"], sample=config["samples"], read = config["reads"])
			output:
				expand("{results}/qc/fastqc/{sample}_{read}_fastqc.zip", results=config["results"], sample=config["samples"], read = config["reads"]),
				expand("{results}/qc/fastqc/{sample}_{read}_fastqc.html", results=config["results"], sample=config["samples"], read = config["reads"])
			conda:
				"../envs/preprocessing.yaml"
			params:
				outdir = expand("{results}/qc/fastqc", results=config["results"])
			threads: config["threads"]
			shell:
				"""
					fastqc {input} --outdir={params.outdir} -t {threads}
				"""

		# multiqc, summarizes fastqc reports
		rule multiqc:
			input:
				expand("{results}/qc/fastqc/{sample}_{read}_fastqc.zip", results=config["results"], sample=config["samples"], read = config["reads"])
			output:
				"{results}/qc/multiqc_report.html"
			params:
				indir = "{results}/qc/fastqc",
				outdir = "{results}/qc"
			conda:
				"../envs/preprocessing.yaml"
			threads: 1
			shell:
				"""
					multiqc {params.indir} -o {params.outdir}
				"""

# cut adapters and low quality reads
rule cutadapt:
    input:
        expand("{raw}/{{sample}}_{read}.{format}.gz",raw=config["raw"], sample=config["samples"], read = config["reads"], format=config["format"])
    output:
        temp(expand("{{results}}/qc/cleaned/{{sample}}_{read}.{format}.gz", results=config["results"], sample=config["samples"], read = config["reads"], format = config["format"]))
    log:
        "{results}/qc/cleaned/{sample}.log"
    params:
        adapter = config["adapter"],
        format = config["format"]
    threads: config["threads"]
    conda:
          "../envs/preprocessing.yaml"
    script:
        "../scripts/cutadapt.py"
