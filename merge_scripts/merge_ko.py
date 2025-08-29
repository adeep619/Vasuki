import pandas as pd
import sys 

df1=pd.read_table(sys.argv[1], delimiter='\t', low_memory=False) # TPM # low memory is for big files
df2=pd.read_table(sys.argv[2], delimiter='\t', low_memory=False) #  Anotation megan bacteria
#df1=df[df['A'] != "N/A"]
#df1.columns= ["Name", "acc","taxa_eval", "superkingdom", "phylum", "class", "order", "family", "genus", "species"]
#df2.columns = ['Name', 'Cross-reference (KEGG)', 'eval_ko']
#uniprot= df2[["Name","Taxa"]]
#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='Name', how='left') # outer is for including all data which matches and do not match
#out = out.drop(out.columns[0], axis=1)
#col_list= ["Name", "acc", "superkingdom", "phylum", "class", "order", "family", "genus", "species"]
#filtered_df=out[['Name', "superkingdom", "phylum", "class", "order", "family", "genus", "species",'taxa_eval', 'Cross-reference (KEGG)', 'eval_ko']]
out.to_csv(sys.argv[3], sep='\t', index=False)
