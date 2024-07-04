# Define a dictionary to store the best E-value for each seqid
import sys
best_evalues = {}

# Define a dictionary to store the top line for each seqid
top_lines = {}

# Open the Diamond output file for reading
with open(sys.argv[1], 'r') as infile:
    for line in infile:
        # Split the line into columns assuming tab as the delimiter
        columns = line.strip().split('\t')
#       qseqid sseqid score evalue pident staxids
        # Ensure the line has enough columns
        if len(columns) == 5:
            seqid = columns[0]
            evalue = float(columns[3])

            # Check if seqid is already in the dictionary
            if seqid in best_evalues:
                # If the current E-value is smaller than the stored best E-value, update it
                if evalue < best_evalues[seqid]:
                    best_evalues[seqid] = evalue
                    top_lines[seqid] = line.strip()
            else:
                # If seqid is not in the dictionary, add it with the current E-value
                best_evalues[seqid] = evalue
                top_lines[seqid] = line.strip()

file=open(sys.argv[2], 'w')
# Print the top lines for each seqid
for seqid, line in top_lines.items():
    columns = line.strip().split('\t')
    #print(columns)
    file.write(f"{columns[0]}\t{columns[1]}\t{columns[3]}\n")
    #print(line)

file.close()
