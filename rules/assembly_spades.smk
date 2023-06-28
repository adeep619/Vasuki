# Assembly reads or sequences ##################################################

# import modules ###############################################################

import math

# rules ########################################################################

# run rnaspades for single end fasta and fastq files
if len(config['reads']) == 1 or config['format'] == "fasta":
    rule spades_single_end:
        input:
            reads = expand("{{results}}/qc/cleaned/{{sample}}_{read}.{format}.gz", read = config["reads"], format = config["format"]) if config["format"] == "fastq" else expand("{{results}}/qc/cleaned/{{sample}}.{format}.gz", format = config["format"])
        output:
            "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta"
        conda:
            "../envs/assemblyspades.yaml"
        params:
            memory = str(math.floor(config["maxmem"]/1024)),
            outdir = "{results}/assembly/spades_{sample}",
            #type = "fq" if config["format"] == "fastq" else "fa"
        threads: config["threads"]
        resources:
            mem_mb=config["maxmem"]
        log: "{results}/assembly/spades_{sample}/spades_snkmk.log"
        shell:
            """
            rnaspades.py -s {input.reads} -t {threads} -m {params.memory} -o {params.outdir} 2> {log}
            """
# run rnaspades for paired-end data
else:
    rule spades_fastq_paired:
        input:
            reads = expand("{{results}}/unmapped/{{sample}}_{read}.fastq", read = config["reads"])
        output:
            "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta"
        conda:
            "../envs/assemblyspades.yaml"
        params:
            memory = str(math.floor(config["maxmem"]/1024)),
            outdir = "{results}/assembly/spades_{sample}"
        resources:
            mem_mb=config["maxmem"]
        threads: config["threads"]
        log: "{results}/assembly/spades_{sample}/spades_snkmk.log"
        shell:
            """
            rnaspades.py -1 {input.reads[0]} -2 {input.reads[1]} -t {threads} -m {params.memory} -o {params.outdir} 2> {log}
            """
rule create_index:
    input:
        assembly = "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta"
    output:
        index = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}/pos.bin"
    conda:
        "../envs/assemblyspades.yaml"
    params:
        outdir = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}"
    threads: config["threads"]
    log: "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}/indexing_smk.log"
    shell:
        """
        salmon index -t {input.assembly} -i {params.outdir} -p {threads}
        """
        
# quantify abundance single-end data
if config['format'] == "fasta":
    rule abundance_single:
        input:
            reads = expand("{{results}}/qc/cleaned/{{sample}}_{read}.{format}.gz", read = config["reads"], format = config["format"]) if config["format"] == "fastq" else expand("{{results}}/qc/cleaned/{{sample}}.{format}.gz", format = config["format"]),
            assembly = "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
            index = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}/pos.bin"
        output:
            "{results}/assembly/quant_{sample}/quant.sf"
        conda:
            "../envs/assemblyspades.yaml"
        params:
            outdir = "{results}/assembly/quant_{sample}",
            #type = "fq" if config["format"] == "fastq" else "fa"
            indexdir = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}"
        threads: config["threads"]
        log: "{results}/assembly/quant_{sample}/quant.log"
        shell:
            """
            salmon quant -l IU -r {input.reads} -p {threads} -o {params.outdir} -i {params.indexdir} 2> {log}
            """
# quantify abundance paired-end data
else:
    rule abundance_paired:
        input:
            reads = expand("{{results}}/unmapped/{{sample}}_{read}.fastq", read = config["reads"]),
            assembly = "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
            index = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}/pos.bin"
        output:
            "{results}/assembly/quant_{sample}/quant.sf"
        conda:
            "../envs/assemblyspades.yaml"
        params:
            outdir = "{results}/assembly/quant_{sample}",
            indexdir = "{results}/assembly/spades_{sample}/soft_transcripts_index_{sample}"
        threads: config["threads"]
        log: "{results}/assembly/quant_{sample}/quant.log"
        shell:
            """
             salmon quant -l IU -1 {input.reads[0]} -2 {input.reads[1]} -p {threads} -o {params.outdir} -i {params.indexdir} 2> {log}
            """

# create output files with sequences and number of reads
rule sequence_and_reads:
    input:
        assembly = "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        quant = "{results}/assembly/quant_{sample}/quant.sf"
    output:
        seq = temp("{results}/tmp/{sample}_seq.tmp"),
        reads = temp("{results}/tmp/{sample}_reads.tmp")
    shell:
        """
         tail -n +2 {input.quant} | cut -f 5 > {output.reads}
         awk \'/^>/ {{ if(NR>1) print \"\";  printf(\"%s\\n\",$0); next; }} {{ printf(\"%s\",$0);}}  END {{printf(\"\\n\");}}\' {input.assembly} | paste - - | cut -f 2 > {output.seq}
        """

################################################################################
