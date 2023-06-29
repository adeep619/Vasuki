#merge blast result with annotation (only one that match)
import pandas as pd


df1=pd.read_table(snakemake.input[0], delimiter='\t', low_memory=False) # blast file # low memory is for big files
df2=pd.read_table(snakemake.input[1], delimiter='\t', low_memory=False) # taxonomy file

#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='#proteinId', how='inner') # outer is for including all data which matches and do not match
out.to_csv(snakemake.output[0], sep='\t', index=False)
