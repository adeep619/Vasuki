# Create KEGG pathway mapping (only with license) ##############################

# RUN: snakemake -s create_kegg_mapping.sm
# TODO: include KEGG HMM search

# rule all #####################################################################


#workdir: "../databases/uniprot/"
# rules ########################################################################

if config["KEGG_pathways"] != "":
    rule copy_pathways:
        input: config["KEGG_pathways"]
        output: "database/bac_nr_ncbi/ko2pathway.txt"
        shell: """
                cp {input} {output};
                sed -i 's/ko://g' {output};
                sed -i 's/path://g' {output}
            """

################################################################################
