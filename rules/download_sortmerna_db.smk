# Download sortMeRNA database ##################################################

import os
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider

 # variables ###################################################################

# HTTP Provider
HTTP = HTTPRemoteProvider()
#Sortme_DB = "github.com/biocore/sortmerna/releases/download/{}/database.tar.gz".format(config["sortmerna"])
Sortme_DB = "github.com/biocore/sortmerna/releases/download/v4.2.0/database.tar.gz"

# rules ########################################################################

rule download_database:
    input:
        HTTP.remote(Sortme_DB, keep_local=True, allow_redirects=True)
    output:
        db = "database.tar.gz"
    threads: 1
    shell:
        "mv {input} {output.db}"

# rule download_database:
#     params: Sortme_DB
#     output:
#         db = "database.tar.gz"
#     shell:
#         "wget {params}"

rule unzip_db:
    input:
        db = "database.tar.gz"
    output:
        fasta = "default_db.fasta"
    threads: 1
    shell:
        """
            tar -xzf {input.db}
            mv *_default_db.fasta {output.fasta}
        """
