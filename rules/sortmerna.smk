import itertools
# Sort reads for rRNA ##########################################################

# import modules ###############################################################

# functions ####################################################################
if config["rrna"]=="sortmerna":
	def separate_fastq_to_fasta(file, file_outf, file_outr):
		def grouper(iterable, n, fillvalue=None):
			args = [iter(iterable)] * n
			return itertools.zip_longest(*args, fillvalue=fillvalue)
		def to_fasta(read):
			id = read[0]
			id = id[1:]
			id = ">"+id.split()[1]
			seq = read[1]
			yield id+"\n"+seq
		with open(file_outf, "w") as g:
			with open(file_outr, "w") as h:
				with open(file) as f:
					for lines in grouper(f, 8, ''):
						read_f = lines[0:4]
						read_r = lines[4:8]
						for res in to_fasta(read_f):
							g.write(res)
						for res in to_fasta(read_r):
							h.write(res)

	def separate_fastq(file, file_outf, file_outr):
		def grouper(iterable, n, fillvalue=None):
			args = [iter(iterable)] * n
			return itertools.zip_longest(*args, fillvalue=fillvalue)
		with open(file_outf, "w") as g:
			with open(file_outr, "w") as h:
				with open(file) as f:
					for lines in grouper(f, 8, ''):
						read_f = lines[0:4]
						read_r = lines[4:8]
						for res in read_f:
							g.write(res)
						for res in read_r:
							h.write(res)

	# include subworkflows ## ######################################################

	# subworkflow to create sortmerna database
	subworkflow sortmerna:
		workdir: "../databases/sortmerna/"
		snakefile: "rules/download_sortmerna_db.smk"
		configfile: "config.yaml"

	# rules ########################################################################

	# uses databases in sortmerna
	rule sortrna:
		input: db = sortmerna("default_db.fasta"),
			reads = expand("{{results}}/qc/cleaned/{{sample}}_{read}.fastq.gz", read=config["reads"])
		output: rrna = temp("{results}/rrna/{sample}_R1_R2.fastq"),
			mrna = temp("{results}/mrna/{sample}_R1_R2.fastq")
		conda: "../envs/sortmerna.yaml"
		threads: config["threads"]
		params:
			prefix1 = lambda wildcards, output: output.rrna[:-6],
			prefix2 = lambda wildcards, output: output.mrna[:-6],
			workdir = "{results}/database/{sample}/sortmerna"
		shell:
			"""
			sortmerna --ref {input.db} --reads {input.reads[0]} --reads {input.reads[1]} --fastx --best 1 --min_lis 10 --blast --paired_in --aligned {params.prefix1} --other {params.prefix2} --workdir {params.workdir} --threads {threads}
			rm -rf {params.workdir}
			"""
	rule separate_interleaved:
		input: mrna = "{results}/mrna/{sample}_R1_R2.fastq",
		output: mrna_R1 = temp("{results}/mrna/{sample}_R1.fastq"),
			mrna_R2 = temp("{results}/mrna/{sample}_R2.fastq"),
		threads: 1
		run:
			separate_fastq(input.mrna, output.mrna_R1, output.mrna_R2)

else:
	rule ribodetector:
		input:
			reads = expand("{{results}}/qc/cleaned/{{sample}}_{read}.fastq.gz", read=config["reads"])
		output:
			mrna = expand("{{results}}/mrna/{{sample}}_{read}.fastq", read=config["reads"])
		conda: "../envs/ribodetector.yaml"
                threads: config["threads"]
		shell:
			"""
			   ribodetector_cpu -t {threads}  -l 100   -i  {input.reads[0]} {input.reads[1]} -e rrna  -o {output.mrna[0]}  {output.mrna[1]}
			"""
