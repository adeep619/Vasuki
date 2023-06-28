# download new Uniprot database
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
from collections import defaultdict

# FTP Uniprot
FTP = FTPRemoteProvider()
UNIPROTDB = "ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"

# download new Uniprot database
rule download_uniprot:
    input:
        db = FTP.remote(UNIPROTDB, static=True)
    output:
        db = "database/bac_nr_ncbi/uniprot_sprot.fasta.gz"
    shell:
        """
            mv {input.db} {output.db};
        """

rule unpack_uniprot:
    input: "database/bac_nr_ncbi/uniprot_sprot.fasta.gz"
    output: "database/bac_nr_ncbi/uniprot_sprot.fasta"
    shell: "gunzip -c {input} > {output}"

rule build_index_uniprot:
    input: "database/bac_nr_ncbi/uniprot_sprot.fasta"
    output: "database/bac_nr_ncbi/uniprot_sprot.db"
    conda: "../envs/uniprot.yml"
    shell: "prerapsearch -d {input} -n {output}"

rule uniprot_rapsearch_search:
    input:
        fasta="{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db=expand("database/bac_nr_ncbi/uniprot_sprot.db")
    output:
        align = "{results}/anotation/{sample}/uniprot/{sample}_aligned.aln"
    threads: config["threads"]
    conda: "../envs/uniprot.yml"
    
    shell:
          """
            cat {input.fasta} | rapsearch -q stdin -d {input.db} -o {output.align} -z {threads} -b 1 -v 0 -p T -t n -e 1
          """


rule build_index_cazyme:
    input: "database/bac_nr_ncbi/cazy_fasta.txt"
    output: "database/bac_nr_ncbi/cazy_fasta.db"
    conda: "../envs/uniprot.yml"
    shell: "prerapsearch -d {input} -n {output}"

rule cazyme_rapsearch_search:
    input:
        fasta="{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db=expand("database/bac_nr_ncbi/cazy_fasta.db")
    output:
        align = "{results}/anotation/{sample}/uniprot/{sample}_cazy_aligned.aln"
    threads: config["threads"]
    conda: "../envs/uniprot.yml"

    shell:
          """
            cat {input.fasta} | rapsearch -q stdin -d {input.db} -o {output.align} -z {threads} -b 1 -v 0 -p T -t n -e 1
          """
