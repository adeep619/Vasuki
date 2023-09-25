rule download_alnus_genome:
    output:
          expand("database/alnus/alnus_genome.fna")
    shell:
         " wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/254/965/GCA_003254965.1_ASM325496v1/GCA_003254965.1_ASM325496v1_genomic.fna.gz -O {output}.gz ; gunzip {output}.gz > {output} "


rule bowtie_build:
    input:
         ref=expand("database/alnus/alnus_genome.fna")
    output:
         ref_idx=expand("database/alnus/alnus_index.1.bt2")
    params:
          name="database/alnus/alnus_index"
    conda:
         "../envs/bowtie.yml"
    threads: config["threads"]
    shell:
         "bowtie2-build  {input.ref} {params.name} --threads {threads}"

rule map_reads_alnus:
    input:
         reads=expand("{results}/mrna/{{sample}}_{read}.fastq" , sample=config["samples"], read = config["reads"], results=config["results"])
    output:
          fq=temp(expand("{results}/unmapped/{{sample}}.sam", sample=config["samples"], results=config["results"])),
    conda:
        "../envs/bowtie.yml"
    threads: config["threads"]
    params:
          name="database/alnus/alnus_index",
          path=expand("{results}/unmapped", results=config["results"])
    shell:
         """
             bowtie2 -x {params.name} -1 {input.reads[0]} -2  {input.reads[1]} -S {output.fq} -p {threads} ;
          """

rule get_unmapped_reads:
    input:
         sam_file = expand("{results}/unmapped/{{sample}}.sam", sample=config["samples"], results=config["results"])
    output:
          reads=expand("{results}/unmapped/{{sample}}_{read}.fastq", read = config["reads"], sample=config["samples"], results=config["results"])
    conda:
         "../envs/bowtie.yml"
    params:          
         path=expand("{results}/unmapped", results=config["results"])
    threads: config["threads"]
    shell:
         """
             samtools view -u -f 2 -F 256 {input.sam_file} > {params.path}/unmapped.sam
             samtools sort -n -@ {threads} {params.path}/unmapped.sam -o {params.path}/unmapped.sort.sam
#             samtools fastq {params.path}/unmapped.sort.sam -1 {output.reads[0]} -2 {output.reads[1]}; 
             bedtools bamtofastq -i {params.path}/unmapped.sort.sam -fq {output.reads[0]} -fq2 {output.reads[1]}
             rm {params.path}/unmapped.sort.sam {params.path}/unmapped.sam;
        """

