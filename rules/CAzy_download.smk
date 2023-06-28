# Download CAzy dbCAN2 database ##################################################

 # variables ###################################################################
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
# HTTP Provider
HTTP = HTTPRemoteProvider()
cazy_activity_DB = "https://bcb.unl.edu/dbCAN2/download/Databases/V10/CAZyDB.07292021.fam-activities.txt"
cazy_accession_DB = "https://bcb.unl.edu/dbCAN2/download/Databases/V10/CAZyDB.07292021.fam.subfam.ec.txt"
cazy_fasta_DB = "https://bcb.unl.edu/dbCAN2/download/Databases/V10/CAZyDB.09242021.fa"

# rules ########################################################################

rule download_cazy_database:
    input:
        f1 = HTTP.remote(cazy_activity_DB, keep_local=True, allow_redirects=True),
        f2 = HTTP.remote(cazy_accession_DB, keep_local=True, allow_redirects=True),
        f3 = HTTP.remote(cazy_fasta_DB, keep_local=True, allow_redirects=True)
    output:
        db = "database/bac_nr_ncbi/"
    threads: 1
    shell:
        "mv {input.f1} ../{output.db} ; mv {input.f2} ../{output.db} ; {input.f3} ../{output.db} ;"


