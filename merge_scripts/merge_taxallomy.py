#merge blast result with annotation (only one that match)
import pandas as pd
import sys 

from datetime import datetime
now = datetime.now()

df1=pd.read_table(sys.argv[1], delimiter='\t', low_memory=False) # TPM # low memory is for big files
df2=pd.read_table(sys.argv[2], delimiter='\t', low_memory=False) #  Anotation megan bacteria
#print("dataframe loaded")
#print(now)
df1.columns = ['Name', 'accession.version', 'len', 'eval', 'per_', 'taxid']
#uniprot= df2[["Name","Taxa"]]
#df1.merge(df2, left_on=1, right_on=1)
out=pd.merge(df1,df2,on='taxid', how='left') # outer is for including all data which matches and do not match
#out = out.drop(out.columns[0], axis=1)
#filtered_df=out[['Name','Taxa','eval']]
out.to_csv(sys.argv[3], sep='\t', index=False)
#print(now)
#print("finished")
