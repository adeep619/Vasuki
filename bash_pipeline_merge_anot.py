#bash
#!/bin/bash

# Navigate to the result folder
#cd ~/path_to_results_folder
#results=
# Filter NCBI hits and get top one for bacteria

print_in_green() {
    echo -e "\033[1;32m$1\033[0m"
}

print_in_green "script started"
echo

cd diamond
print_in_green  "uniprot started"
echo
# Filter UniProt for KO
mkdir best_eval_uniprot
for i in `ls *uniprot.csv`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/filter_eval_uniprot.py $i best_eval_uniprot/$i
    echo $i
done
cd best_eval_uniprot

# Merge KO to UniProt filtered
#mkdir merge_ko
mkdir ko 
for i in `ls *.csv`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_uniprot2ko.py $i /mnt/disk2/Vasuki/database/bac_nr_ncbi/uniprot2ko.txt ko/$i
    echo $i
done
cd ../
print_in_green "uniprot finished"
echo
print_in_green "JGI started"
echo
print_in_green "best_eval_jgi"
# Filter JGI blast hits to get top hit for fungi
mkdir best_eval_jgi
for i in `ls *jgi.csv`; do
 #   python /home/omics/aman_link/Vasuki/merge_scripts/filter_eval_best.py $i best_eval_jgi/$i
    echo $i
done


# Edit JGI blast hits
cd best_eval_jgi

print_in_green "taxa"
# JGI taxonomy merge from taxonomy file
mkdir taxa
for i in `ls *.csv`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_taxa_jgi.py $i /mnt/disk2/Vasuki/database/jgi/Final_correct_jgi_taxonomy.txt taxa/$i
    echo $i
done

cd taxa
print_in_green "ko_jgi"
# Merge KO to JGI files
mkdir ko_jgi
for i in `ls *.csv | cut -f1,2,3,4,5 -d'_'`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_ko_jgi.py ${i}_jgi.csv ../../best_eval_uniprot/ko/${i}_uniprot.csv ko_jgi/$i.csv
    echo $i
done

cd ko_jgi
print_in_green "numreads_jgi"
# Merge JGI and numreads
mkdir numreads_jgi
for i in `ls *.csv | cut -f1 -d'.'`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_numreads_bac.py $i.csv ../../../../assembly/quant_$i/quant.sf numreads_jgi/$i.tsv
    echo $i
done
print_in_green "Fungi sum"
pwd
cd numreads_jgi
mkdir sum_kegg
for i in `ls *tsv`; do
   # python /mnt/disk2/Vasuki/merge_scripts/sum_ko.py $i sum_kegg/$i
    echo $i
done



print_in_green "JGI finished"
pwd
echo
################################################ BACTERIA ##############################################################################################################################

print_in_green "bac started"
print_in_green
#move to bac_diamond
cd ../../../../../
pwd
print_in_green "best_eval bac"
cd bac_diamond
mkdir best_eval_bac
for i in `ls *.csv`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/filter_eval_bac.py $i best_eval_bac/$i
    echo $i
done

cd best_eval_bac
pwd
print_in_green "bac taxa"
# Merge taxonomy to NCBI from taxonomy file
mkdir taxa
for i in `ls *.csv`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/taxa_merge_ncbi.py $i /mnt/disk2/Vasuki/database/bac_nr_ncbi/taxids_taxanomy_nr_bac_edit.tsv taxa/$i
    echo $i
done
cd taxa
pwd
print_in_green "ko_bac"
# Merge KO to NCBI
mkdir ko_bac
for i in `ls *.csv | cut -f1,2,3,4,5 -d'_'`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_ko.py ${i}_ncbi.csv ../../../diamond/best_eval_uniprot/ko/${i}_uniprot.csv ko_bac/$i.tsv
    echo $i
done 

cd ko_bac
pwd
print_in_green "bac numreads"
# Merge numreads to NCBI
mkdir numreads
for i in `ls *.tsv | cut -f1 -d'.'`; do
#    python /home/omics/aman_link/Vasuki/merge_scripts/merge_numreads_bac.py $i.tsv ../../../../assembly/quant_$i/quant.sf numreads/$i
    echo $i
done


# Merge pathways
cd numreads
pwd
print_in_green "bac pathways"
mkdir pathway
for i in `ls`; do
#    python /mnt/disk2/Vasuki/merge_scripts/merge_pathway.py $i /mnt/disk2/Vasuki/database/KEGG_Pathways.tab pathway/$i.tsv
    echo $i
done

# Get sum on each KEGG IDs
cd pathway
pwd
print_in_green "bac sum"
mkdir sum_kegg
for i in `ls *tsv`; do
#    python /mnt/disk2/Vasuki/merge_scripts/sum_ko.py $i sum_kegg/$i
    echo $i
done

print_in_green "bac finished"

echo ""
print_in_green "script finished.... "
date
# Filter CAZy
#cd ../../../cazy


# Filter CAZy blast hits
#mkdir best_eval
#for i in `ls *.csv`; do
#    python ../../../../Aman/merge_scripts/filter_eval_best_cayz.py $i best_eval/$i
#    print_in_green$i
#done

# Merge numreads for CAZy
#mkdir merge_numreads
#for i in `ls *.csv | cut -f1,2,3,4,5,6,7 -d'_'`; do
#    python ../../../../merge_scripts/merge_numreads_cazy.py ${i}_cazy.csv ../../../../Aman/sfb_aq_uls_21_MT_total_RNA_results/assembly/quant_$i/quant.sf numreads/$i.tsv
#    echo $i
#done
