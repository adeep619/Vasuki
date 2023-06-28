# Create diamond index #########################################################

# rules ########################################################################

rule make_index:
    input:
        fasta = "database/bac_nr_ncbi/bac_nr.fasta",
    output:
        index = "database/bac_nr_ncbi/diamond_index_bac_nr.dmnd"
    conda: "../envs/diamond.yaml"
    threads: config["threads"]
    shell: "diamond makedb --in {input.fasta} -d {output.index} -p {threads}"
