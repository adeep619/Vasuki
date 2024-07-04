import pandas as pd
import sys 

df1=pd.read_table(sys.argv[1], delimiter='\t', low_memory=False) # NumReads # low memory is for big files
df2=pd.read_table(sys.argv[2], delimiter='\t', low_memory=False) #  eval
#Name_NumReads=df1[["Name","NumReads"]]
df2.columns = ['Cross-reference (KEGG)','ko', 'pathway']
#df1.columns = ['KEGG', 'ko']
#uniprot= df2[["Name","Taxa"]]
#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='Cross-reference (KEGG)', how='left') # outer is for including all data which matches and do not match
#print("duplicates remove")

# Drop duplicate rows based on col 0
#out.drop_duplicates(subset=['Name'], keep='first', inplace=True)

#filtered_df= out[out.apply(lambda row: row.count() == 4, axis=1)]
out.to_csv(sys.argv[3], sep='\t', index=False)

