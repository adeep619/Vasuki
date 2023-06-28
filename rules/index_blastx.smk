rule bac_index:
        input:
                fasta="database/blastx/bacteria.nonredundant_protein.99.protein.faa"
        output:
                expand("database/blastx/bac.dmnd")
        conda: "../envs/diamond.yaml"
        threads: config["threads"]
        shell: "diamond makedb --in {input.fasta} -d {output} -p {threads}"


rule fungi_index:
        input:
                fasta="database/blastx/fungi.25.protein.faa"
        output:
                expand("database/blastx/fungi.dmnd")
        conda: "../envs/diamond.yaml"
        threads: config["threads"]
        shell: "diamond makedb --in {input.fasta} -d {output} -p {threads}"

