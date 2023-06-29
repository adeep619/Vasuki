
rule merge_jgi_tpm:
        input:
                "{results}/anotation/{sample}/{sample}_jgi_tax.tsv", #this is not final file
                "{results}/assembly/quant_{sample}/quant_edit.sf"
        output:
                "{results}/anotation/{sample}/jgi_tpm_tax.txt"
        script:
                "../scripts/merge_anot_tpm_jgi.py"


rule merge_jgi_uniprotID:
        input:
                "{results}/uniprot/{sample}_uniprot_ko.tab", #this is not final file
                "{results}/anotation/{sample}/jgi_tpm_tax.txt"
        output:
                "{results}/anotation/{sample}/jgi_tax_tpm_unip.txt"
        script:
                "../scripts/merge_anot_tpm_unip_jgi.py"
