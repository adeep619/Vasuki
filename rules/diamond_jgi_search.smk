##### Diamond search against JGI #########

rule diamond_JGI:
    input:
        fasta="{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db=expand("database/jgi/diamond_index_jgi.dmnd")
    output:
        csv = "{results}/diamond/{sample}_jgi.csv"
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell:
        """
            diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.db} -o {output.csv} --evalue 1 -f 6 qseqid sseqid score evalue pident --max-target-seqs 20 --threads {threads} --unal 1
        """

rule edit_blast:
    input:
        blast="{results}/diamond/{sample}_jgi.csv"
    output:
        csv="{results}/diamond/{sample}_jgi_edit.csv"
    script:
           "../scripts/jgi_blast_modify.py"

rule merge_jgi_taxonomy:
    input:
        blast="{results}/diamond/{sample}_jgi_edit.csv",
        jgi_db="database/jgi/Final_taxonomy.txt"
    output:
        anot="{results}/anotation/{sample}/{sample}_jgi_tax.tsv"
    script:
           "../scripts/merge_jgi_tax.py"

#rule merge_jgi_taxonomy:
#    input:
#        anot="{results}/anotation/{sample}/{sample}_jgi_anot.tsv",
#        jgi_db="database/jgi/Final_taxonomy.txt"
#    output:
#        anot="{results}/anotation/{sample}/{sample}_jgi_complete_anot.tsv"
#    script:
#           "../scripts/merge_jgi_tax.py"

