#merge blast result with annotation (only one that match)
import pandas as pd
import sys 
df1=pd.read_table(snakemake.input[0], delimiter='\t', low_memory=False) # uniprot blast file # low memory is for big files
df2=pd.read_table(snakemake.input[1], delimiter='\t', low_memory=False) # uniprot2ko file

df1.columns=["#trinityId", "uniprotID", "length", "eval", "match"]
df2.columns=["uniprotId", "Cross-reference (KEGG)"]


df3=df1['uniprotID'].str.split(pat="|", expand=True) # to split "sp|P61272|RL35A_MACFA"
df3.columns=["1", "uniprotId", "3"]
df1["uniprotId"]=df3["uniprotId"]
#print(df1.head(2))
column_list=['#trinityId','uniprotId','Cross-reference (KEGG)']

#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='uniprotId', how='left') # outer is for including all data which matches and do not match
out.to_csv(snakemake.output[0], sep='\t', index=False, columns=column_list)

