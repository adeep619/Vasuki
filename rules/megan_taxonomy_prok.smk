## this is to get taxonomy from megan 
if config['megan']:
    rule diamond_megan:
        input:
            fasta="{results}/assembly/trinity_{sample}/Trinity.fasta" if config["assembly"]=="TRINITY" else "{results}/assembly/spades_{sample}/soft_filtered_transcripts.fasta",
            db=expand("database/bac_nr_ncbi/bac_nr.fasta")
        output:
            daa = "{results}/megan/{sample}_megan.daa",
            tax = "{results}/megan/{sample}_taxinfo.txt"
        conda: "../envs/diamond.yaml"
        threads: config["threads"]
        shell:
            """
                diamond blastx -b 20.0 -c 1 -q {input.fasta} -d {input.db} -o {output.daa} --evalue 1 -f 100  --max-target-seqs 20 --threads {threads} --unal 1
                /mnt/xio/botany/megan/tools/daa-meganizer -i {output.daa} -mdb /mnt/xio/botany/megan/tools/megan-map-Feb2022.db
                /mnt/xio/botany/megan/tools/daa2info --in  {output.daa} -bo -r2c Taxonomy  -n  -p >  {output.tax}
            """
