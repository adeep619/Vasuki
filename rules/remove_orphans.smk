rule orphan_removed:
    input:
        "unmapped_fastq r1 and r2"
    output:
        "out r1 out r2"
    script:
          "perl script -1 R1 -2 R2"
rule rename:
    input:
         "out r1 out r2 from orphan_removed"
    output:
         "same name as uunmapped"
    shell:
        "mv paired_{sample_name}_R1 {sample_name}_R1; mv paired_{sample_name}_R2 {sample_name}_R2;"
