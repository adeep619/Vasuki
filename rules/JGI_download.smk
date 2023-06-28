rule download_jgi_database:
    input: config = expand("{config_file}", config_file=config["jgi_config"]),
         organism_ids= expand("{org_ids}", org_ids=config["jgi_organism_ids"])
    output: "JGI_Database/download.log"
    script:
        "../scripts/jgi_download.py"



