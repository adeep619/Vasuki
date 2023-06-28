# Assembly reads ##############################################################

# import modules ###############################################################

import math

# rules ########################################################################
if config["assembly"]=="TRINITY":
# run trinity for paired-end data
	rule trinity_fastq_paired:
		input:
			reads = expand("{{results}}/unmapped/{{sample}}_{read}.fastq", read = config["reads"])
		output:
			"{results}/assembly/trinity_{sample}/Trinity.fasta"
		conda:
			"../envs/assembly.yaml"
		params:
			memory = str(math.floor(config["maxmem"]/1024))+"G",
			outdir = "{results}/assembly/trinity_{sample}"
		resources:
			mem_mb=config["maxmem"]
		threads: config["threads"]
		log: "{results}/assembly/trinity_{sample}/Trinity.log"
		shell:
			"""
			Trinity --seqType fq --left {input.reads[0]} --right {input.reads[1]} --CPU {threads} --max_memory {params.memory} --output {params.outdir} --no_salmon 2> {log}
			"""
if config["assembly"]=="TRINITY":
	rule abundance_paired:
		input:
			reads = expand("{{results}}/unmapped/{{sample}}_{read}.fastq", read = config["reads"]),
			assembly = "{results}/assembly/trinity_{sample}/Trinity.fasta"
		output:
			"{results}/assembly/quant_{sample}/quant.sf"
		conda:
			"../envs/assembly.yaml"
		params:
			outdir = "{results}/assembly/quant_{sample}"
		threads: config["threads"]
		log: "{results}/assembly/quant_{sample}/quant.log"
		shell:
			"""
			align_and_estimate_abundance.pl --transcripts {input.assembly} --seqType fq --left {input.reads[0]} --right {input.reads[1]} --est_method salmon --trinity_mode --prep_reference --output_dir {params.outdir} --thread_count {threads} 2> {log}
			"""

# create output files with sequences and number of reads
if config["assembly"]=="TRINITY":
	rule sequence_and_reads:
		input:
			assembly = "{results}/assembly/trinity_{sample}/Trinity.fasta",
			quant = "{results}/assembly/quant_{sample}/quant.sf"
		output:
			seq = temp("{results}/tmp/{sample}_seq.tmp"),
			reads = temp("{results}/tmp/{sample}_reads.tmp")
		threads: 1
		shell:
			"""
			 tail -n +2 {input.quant} | cut -f 5 > {output.reads}
			 cat {input.assembly} | paste - - | cut -f 2 > {output.seq}
			"""

################################################################################
