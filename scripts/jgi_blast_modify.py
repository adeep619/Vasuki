file2=open(snakemake.output[0], 'w')
file2.write(f'#trinityId\t#proteinId\t#organismId\n')
with open(snakemake.input[0], 'r') as file:
    for line in file:
        if 'jgi' in line:
            list1 = line.split('\t')
            list2 = list1[1].split('|')
            file2.write(f'{list1[0]}\t{list2[1]}|{list2[2]}\t{list2[1]}\n')
