rule diamond_index:
    input:
          fasta="database/dbcan/CAZyDB.07262023.fa"
    output: "database/dbcan/cazy.dmnd"
    threads: 120
    conda: "envs/diamond.yaml"
    shell:
        """
           diamond makedb --in {input.fasta} -d {output} -p {threads}
        """

rule diamond_ncbi:
    input:
        fasta=fasta = "{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db="database/dbcan/CAZyDB.07262023.fa",
        index="database/dbcan/cazy.dmnd"
    output:
        csv="{results}/results/cazy_diamond/{sample}_cazy.csv"
    conda: "envs/diamond.yaml"
    threads: 128
    shell:
        """
        diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.index} -o {output.csv} --evalue 1 -f 6 qseqid sseqid score evalue pident  --max-target-seqs 20 --threads {threads} --unal 1
        """
