rule bowtie2_build:
    input:
        ref=expand("database/alnus/alnus_genome.fna"),
    output:
        multiext(
            "alnus_genome",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        "logs/bowtie2_build/build.log",
    params:
        extra="",  # optional parameters
    threads: 20
    wrapper:
        "v1.7.1/bio/bowtie2/build"
