rule edit_abundance:
		input:
				expand("{results}/assembly/quant_{sample}/quant.sf",sample=config["samples"], results=config["results"])
		output:
				"{results}/assembly/quant_{sample}/quant_edit.sf"
		script:
				"../scripts/edit_abundance_tpm.py"

