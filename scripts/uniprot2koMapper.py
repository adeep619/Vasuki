#!/usr/bin/env python3
import os
import sys
import pandas as pd
from pathlib import Path

#defining files
idmapping_file = snakemake.input[0]
uniprot_list_file=snakemake.output[1]
kofile=snakemake.input[1]
output_file=snakemake.output[0]

#making uniprot2kegg list if it dosent exist
if not Path(uniprot_list_file).is_file(): #create_the_uniprot2kegg
    print("Making uniprot2kegg intermediate file")
    command=f"echo 'Entry\tCross-reference (KEGG)' > {uniprot_list_file}"
    print(command)
    os.system(command)
    command=f"zcat {idmapping_file}|grep -P '\tKEGG\t'| cut -f1,3 >>{uniprot_list_file}"
    print(command)
    os.system(command)


#opening the data files to start mapping
print("Loading Files")
u2kegg=pd.read_csv(uniprot_list_file,sep="\t",names=["uID","kgene"],header=0)
gene2_ko=pd.read_csv(kofile,sep="\t",names=["kID","geneID"]).groupby(['geneID'],as_index = False).agg({'kID':lambda x:";".join(set(x)).replace("ko:","")}) #read the kegg Ko list and create a df with all KOs refereing to same gene on one line
print("ID cross-mapping Started")
u2ko=pd.DataFrame(columns=["Entry","Cross-reference (KEGG)"]) #CREATE EMPTY DATAFRAME FOR LATER

uniprot2_ko_st_df=pd.merge(u2kegg,gene2_ko,how="left",left_on="kgene",right_on="geneID").dropna().reset_index(drop=True)[["uID","kID"]] #initial mapping qick
for entry in uniprot2_ko_st_df[uniprot2_ko_st_df["kID"].str.contains(";")].itertuples(): #loop to seperate every UiD with multiple KOs into two seperate entries looping over only part of it as it is faster and other entries are alredy singletons
    uniprot_id=entry[1].strip()
    kIDs=entry[-1].strip().split(";")
    for kID in kIDs:
        new_row={"Entry":[uniprot_id],"Cross-reference (KEGG)":[kID]}
        #new_row = [uniprot_id,kID]
        u2ko=pd.concat([u2ko,pd.DataFrame(new_row)],ignore_index=True)
#merge the DF with seperated uIDS and the original with just singletons:
u2ko=pd.concat([uniprot2_ko_st_df[uniprot2_ko_st_df["kID"].str.contains(";")==False].rename(columns={'uID':'Entry','kID':'Cross-reference (KEGG)'}),u2ko],ignore_index=True)
u2ko["Entry"]=u2ko["Entry"].str.strip() #removing white space characters from beginin and end of all cells in the the DF
u2ko["Cross-reference (KEGG)"]=u2ko["Cross-reference (KEGG)"].str.strip()
u2ko.to_csv(output_file,index=False,sep="\t") #write out the final DF

