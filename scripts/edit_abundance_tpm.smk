# this script is to get tpm from quant.sf file
import pandas as pd

df1=pd.read_table(snakemake.input[0], delimiter='\t', low_memory=False, header=None) # blast file # low memory is for big files

df2=df1.iloc[:,[0,3]] #get column first and fourth
df2.columns=["#trinityId", "TPM"] # add header

df2.to_csv(snakemake.output[0], sep='\t', index=False)


