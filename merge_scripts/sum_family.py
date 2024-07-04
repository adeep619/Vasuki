import pandas as pd
import sys
#Name=sys.argv[2]
header=sys.argv[1].replace("master_table/","").replace(".tsv", "").replace("AFP2_", "").replace("E_R_", "")
# Calculate the SUM NumReads for each organism
sample_df=pd.read_csv(sys.argv[1], sep="\t", header=0, low_memory=False)
#sample_df.columns=['family' , 'NumReads']
new_df=sample_df[["family","NumReads"]].copy()
#new_df.columns=["#organismId","NumReads"]

#sample_df['TPM']=sample_df['TPM'].astype(float)
# to make col  numeric
new_df['NumReads'] = pd.to_numeric(sample_df['NumReads'], errors='coerce')
new_df['NumReads'] = new_df['NumReads'].mask(pd.isnull, sample_df['NumReads'])
#
sum_df=new_df.groupby(['family'])['NumReads'].sum('sum').reset_index()

sum_df["NumReads"] = sum_df["NumReads"].round(0)
#average_df = sample_df.groupby(sample_df.columns[0]).mean().reset_index()
# Display the average TPM data
sum_df.columns=["family", header]
sum_df.to_csv(sys.argv[2], index=False)
