import deepdish as dd
from collections import defaultdict

d = defaultdict(list)
with open(snakemake.input[0], 'r') as f:
    for line in f:
        line = line.rstrip()
        line = line.split("\t")
        for k, v in [tuple(line)]:
            d[k].append(v)
dd.io.save(snakemake.output[0], d)
