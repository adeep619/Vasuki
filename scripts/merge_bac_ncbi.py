#merge two files with same column
import pandas as pd
import sys

df1=pd.read_table(snakemake.input[0], delimiter='\t', low_memory=False) # low memory is for big files
df2=pd.read_table(snakemake.input[1], delimiter='\t', low_memory=False)

#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='accession.version', how='left') # outer
out.to_csv( snakemake.output[0], sep='\t', index=False)
