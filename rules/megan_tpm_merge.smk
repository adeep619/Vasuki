rule merge_megan_tpm:
        input:
                "{results}/megan/{sample}_taxinfo.txt", #this is not final file
                "{results}/assembly/quant_{sample}/quant_edit.sf"
        output:
                "{results}/anotation/{sample}/megan_tpm_tax.txt"
        script:
                "../scripts/merge_anot_tpm.py"


rule merge_megan_uniprotID:
        input:
                "{results}/diamond/{sample}_uniprot.csv", #this is not final file
                "{results}/anotation/{sample}/megan_tpm_tax.txt"
        output:
                "{results}/anotation/{sample}/megan_tax_tpm_unip.txt"
        script:
                "../scripts/merge_anot_tpm_unip.py"
