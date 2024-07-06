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

rule make_index_uniprot:
    input:
        fasta = "database/bac_nr_ncbi/uniprot_sprot.fasta"
    output:
        expand("database/bac_nr_ncbi/uniprot_sprot.dmnd")
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell: "diamond makedb --in {input.fasta} -d {output}  -p {threads}"


rule diamond_uniprot:
    input:
        fasta="{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
        db=expand("database/bac_nr_ncbi/uniprot_sprot.dmnd")
    output:
        csv = "{results}/diamond/{sample}_uniprot.csv"
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell:
        """
            diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.db} -o {output.csv} --evalue 1 -f 6 qseqid sseqid score evalue pident --max-target-seqs 20 --threads {threads}
        """


rule uniprot_ko:
	input:
		"{results}/diamond/{sample}_uniprot.csv",
		"database/bac_nr_ncbi/uniprot2ko.txt"
	output:
		"{results}/uniprot/{sample}_uniprot_ko.tab"
	script:
		"../scripts/uniprot2ko_merge.py"


