# Create diamond index #########################################################

# rules ########################################################################

rule make_index_jgi:
    input:
        fasta = "database/jgi/aa_combined.fasta"
    output:
        expand("database/jgi/diamond_index_jgi.dmnd")
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell: "diamond makedb --in {input.fasta} -d {output}  -p {threads}"
