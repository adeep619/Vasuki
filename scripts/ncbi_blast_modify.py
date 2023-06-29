file2=open(snakemake.output[0], 'w')
file2.write(f'#trinityId\taccession.version\n')
with open(snakemake.input[0], 'r') as file:
    for line in file:
        if not "*" in line:
            list1 = line.split('\t')
            file2.write(f'{list1[0]}\t{list1[1]}\n')
