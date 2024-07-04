import pandas as pd
import sys

file_list=sys.argv[2:]
# Read the four files into pandas dataframes
merged_df=pd.read_csv(sys.argv[1], sep=",")
# Merge the dataframes based on the first column
for filename  in file_list:
    data=pd.read_csv(filename , sep= ",")
    merged_df = pd.merge(merged_df, data, on='Cross-reference (KEGG)', how='outer')


#  drop duplicate
merged_df = merged_df.drop_duplicates(subset='Cross-reference (KEGG)')
# Replace NaN values with 0
merged_df = merged_df.fillna(0)

columns_to_convert = merged_df.columns[1:]  # Exclude the first column
merged_df[columns_to_convert] = merged_df[columns_to_convert].astype(int)

# Save the merged dataframe to a new file
merged_df.to_csv('merged_file.csv', index=False, sep="\t")
