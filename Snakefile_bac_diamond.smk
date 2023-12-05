
samples=config["samples"]
input="sfb_a01_ex_s_22_MT_total_RNA_results"
rule all:
    input:
        expand("results/bac_diamond/{sample}_nr.csv", sample=samples)

rule diamond_ncbi:
    input:
        fasta=lambda wildcards: "{input}/assembly/spades_{sample}/soft_filtered_transcripts.fasta".format(input=input, sample=wildcards.sample),
        db="database/bac_nr_ncbi/bac_nr.fasta",
        index="database/bac_nr_ncbi/bac_nr_tax.dmnd"
    output:
        csv="results/bac_diamond/{sample}_nr.csv"
    conda: "envs/diamond.yaml"
    threads: 128
    wildcard_constraints:
        sample="|".join(samples)
    shell:
        """
        diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.index} -o {output.csv} --evalue 1 -f 6 qseqid sseqid score evalue pident staxids --max-target-seqs 20 --threads {threads} --unal 1
        """
