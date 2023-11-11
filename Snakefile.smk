# Run: snakemake -j 50 -s Snakefile.smk --use-conda --configfile config.yaml -k --debug -npr
#### rule all ##################################################################
#print('\033[2;31;43m                                                                                                                                           \033[0;0m')
#a= """
#.##.....##....###.....######..##.....##.##....##.####
#.##.....##...##.##...##....##.##.....##.##...##...##.
#.##.....##..##...##..##.......##.....##.##..##....##.
#.##.....##.##.....##..######..##.....##.#####.....##.
#..##...##..#########.......##.##.....##.##..##....##.
#...##.##...##.....##.##....##.##.....##.##...##...##.
#....###....##.....##..######...#######..##....##.####
#"""
#print(a)
#print('\033[2;31;43m                                                                                                                                           \033[0;0m')

rule all:
    input:
        # output preprocessing
        expand("{results}/qc/fastqc/{sample}_{read}_fastqc.zip", results=config["results"], sample=config["samples"], read = config["reads"]) if config["fastqc"]  else [],
        expand("{results}/qc/multiqc_report.html", results=config["results"]) if config["format"] == "fastq" else [],
#        expand("{results}/qc/cleaned/{sample}_{read}.{format}.gz", results=config["results"], sample=config["samples"], read = config["reads"], format = config["format"]) if config["format"] == "fastq" else expand("{results}/qc/cleaned/{sample}.{format}.gz", results=config["results"], sample=config["samples"], format = config["format"]),
        # output sortmerna
#        expand("{results}/mrna/{sample}_{read}.fastq", results=config["results"], sample=config["samples"], read = config["reads"]),
#        expand("{results}/rrna/{sample}_{read}.fastq", results=config["results"], sample=config["samples"], read = config["reads"]),
	# Filter plant reads
        #expand("database/alnus/alnus_genome.fna"), 
	expand("database/alnus/alnus_index.1.bt2"),
        expand("{results}/unmapped/{sample}.sam", sample=config["samples"], results=config["results"]),
        expand("{results}/unmapped/{sample}_{read}.fastq", sample=config["samples"], read = config["reads"], results=config["results"]),
        # output assembly
        expand("{results}/assembly/trinity_{sample}/Trinity.fasta", results=config["results"], sample=config["samples"]) if config["assembly"]=="TRINITY" else [],
        expand("{results}/assembly/quant_{sample}/quant.sf", results=config["results"], sample=config["samples"]),
	expand("{results}/assembly/quant_{sample}/quant_edit.sf", results=config["results"], sample=config["samples"]),
	# Uniprot diamond
	expand("{results}/diamond/{sample}_uniprot.csv", results=config["results"], sample=config["samples"]),
	expand("{results}/anotation/{sample}/jgi_tax_tpm_unip.txt", results=config["results"], sample=config["samples"]),
	expand("{results}/uniprot/{sample}_uniprot_ko.tab", results=config["results"], sample=config["samples"]),
        ## output JGI search with diamond
#        expand("{results}/anotation/{sample}/{sample}_jgi_complete_anot.tsv", results=config["results"], sample=config["samples"]),
	expand("{results}/anotation/{sample}/{sample}_jgi_tax.tsv", results=config["results"], sample=config["samples"]),
        ## output NCBI bacteria diamond search
#        expand("{results}/anotation/{sample}/{sample}_ncbi.tsv", results=config["results"], sample=config["samples"]),
	## MEGAN output for NCBI
	expand("{results}/megan/{sample}_megan.daa", results=config["results"], sample=config["samples"]) if config["megan"] else [],
        expand("{results}/megan/{sample}_taxinfo.txt", results=config["results"], sample=config["samples"]) if config["megan"] else [],
	expand("{results}/anotation/{sample}/megan_tpm_tax.txt", results=config["results"], sample=config["samples"]) if config["megan"] else [],
	expand("{results}/anotation/{sample}/megan_tax_tpm_unip.txt", results=config["results"], sample=config["samples"]) if config["megan"] else [],
        # JGI Taxonomy Anotation
	expand("{results}/anotation/{sample}/jgi_tpm_tax.txt", results=config["results"], sample=config["samples"]),
	expand("{results}/anotation/{sample}/jgi_tax_tpm_unip.txt", results=config["results"], sample=config["samples"]),
        #### for KEGG DATABASE###
        expand("database/bac_nr_ncbi/ko2pathway.txt" if config["KEGG_pathways"] != "" else []),
        expand(["database/bac_nr_ncbi/uniprot2ko.txt","database/bac_nr_ncbi/uniprot2kegg.txt"])


# global constraints
wildcard_constraints:
    read = "R\d",

# run preproscessing
include: "rules/preprocessing.smk"

#### sort RNA ##################################################################

# run sortmerna
include: "rules/sortmerna.smk"

#### run Trinity ###############################################################

# run assembly
include: "rules/assembly.smk"
include: "rules/assembly_spades.smk"
# edit abundance
include: "rules/edit_abundance.smk"
#run uniprot on assembly
include: "rules/uniprot.smk"
## to make index NCBI NR bacteria
include: "rules/index_ncbi_diamond.smk"
## run diamond search against NCBI NR bacteria
#include: "rules/diamond_ncbi_search.smk"
# to make index of JGI ###
include: "rules/index_jgi_diamond.smk"
# to diamond seach against JGI 
include: "rules/diamond_jgi_search.smk"

# to create KEGG Database
include: "rules/create_kegg_mapping.smk"
include: "rules/create_uniprot_db.smk"
include: "rules/filter_plant_reads.smk"

#include: "rules/bow_build.smk"
# for NCBI Taxonomy  megan
include: "rules/megan_taxonomy_prok.smk"
# for JGI Taxonomy
include: "rules/jgi_tpm_merge.smk"
# for NCBI megan merge
include: "rules/megan_tpm_merge.smk"
include: "rules/index_blastx.smk"
