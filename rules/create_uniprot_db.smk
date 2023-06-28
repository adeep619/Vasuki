# Create Uniprot database and mappings #########################################

# RUN: snakemake -s create_uniprot_db.sm

# import modules ###############################################################

from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
from collections import defaultdict

# set variables ################################################################

# FTP Uniprot
FTP = FTPRemoteProvider()
UNIPROTID = "ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz"
UNIPROTDB = "ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"
#UNIPROTID = "localhost:2212/mnt/Disk2/Data/MTT_mbs/taxmapper_supplement/databases/bkp/idmapping.dat.gz" #### not working

# rule all #####################################################################


# rules ########################################################################

# download new Uniprot database
rule download:
    input:
        id = FTP.remote(UNIPROTID, static=True),
    output:
        id = "database/bac_nr_ncbi/idmapping.dat.gz",
    shell:
        """
            mv {input.id} {output.id};
        """

rule get_KOs:
    input: "database/bac_nr_ncbi/idmapping.dat.gz", config["KO_list_file"]
    output: "database/bac_nr_ncbi/uniprot2ko.txt","database/bac_nr_ncbi/uniprot2kegg.txt"
    script: "../scripts/uniprot2koMapper.py"

################################################################################
