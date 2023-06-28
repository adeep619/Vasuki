# Search NCBI nr with diamond ##################################################

# rules ########################################################################

rule diamond_NCBI:
    input:
        fasta = "{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db = expand("database/bac_nr_ncbi/diamond_index_bac_nr.dmnd")
    output:
        csv = "{results}/diamond/{sample}_ncbi.csv"
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell:
        """
            diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.db} -o {output.csv} --evalue 1 -f 6 qseqid sseqid score evalue pident --max-target-seqs 20 --threads {threads} --unal 1
        """


rule blast_ncbi_edit:
    input:
         blast="{results}/diamond/{sample}_ncbi.csv"
    output:
          csv="{results}/diamond/{sample}_ncbi_edit.csv"
    script:
           "../scripts/ncbi_blast_modify.py"



rule ncbi_anotation_merge:
    input:
        blast="{results}/diamond/{sample}_ncbi_edit.csv",
        ncbi_db=expand("database/bac_nr_ncbi/Final_anotation.txt")
    output:
         csv="{results}/anotation/{sample}/{sample}_ncbi.tsv"
    script:
           "../scripts/merge_bac_ncbi.py"

