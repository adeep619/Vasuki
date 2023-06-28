#!/bin/bash
#conda activate metatrans 

cat << EOF

.##.....##....###.....######..##.....##.##....##.####
.##.....##...##.##...##....##.##.....##.##...##...##.
.##.....##..##...##..##.......##.....##.##..##....##.
.##.....##.##.....##..######..##.....##.#####.....##.
..##...##..#########.......##.##.....##.##..##....##.
...##.##...##.....##.##....##.##.....##.##...##...##.
....###....##.....##..######...#######..##....##.####


EOF


#/mnt/xio/botany/mambaforge/bin/conda
export PATH="/mnt/xio_5t/botany/anaconda3/bin/conda:$PATH"
echo "enter the  config name"
read var
#snakemake -j 50 -s totalRNA_search.smk --use-conda --configfile config.yaml -p 
env_loc=$(conda info --base)/etc/profile.d/conda.sh
screen  -S $var bash -c "source $env_loc ; conda activate vasuki ; snakemake -j 50 -s Snakefile.smk --use-conda --configfile $var.yaml -p  ;exec sh"
