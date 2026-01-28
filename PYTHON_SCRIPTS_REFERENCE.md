# Python Scripts Reference - Vasuki Pipeline

This document provides comprehensive documentation for all Python scripts used in the Vasuki metatranscriptomics pipeline.

## Table of Contents

- [Data Download Scripts](#data-download-scripts)
- [Data Processing Scripts](#data-processing-scripts)
- [Annotation Merge Scripts](#annotation-merge-scripts)
- [Database Mapping Scripts](#database-mapping-scripts)
- [Utility Scripts](#utility-scripts)

## Data Download Scripts

### `jgi_download.py`

**Purpose:** Downloads protein sequences and functional annotations from the Joint Genome Institute (JGI) portal for specified organisms.

**Dependencies:**
- `requests`: HTTP requests for web scraping
- `bs4` (BeautifulSoup): HTML parsing
- `urllib.request`: URL handling
- `os`: File system operations

**Input Files:**
- `fungi_id_list.txt`: List of JGI organism IDs (tab-separated)
- `list_files_download.config`: Comma-separated list of file types to download

**Output:**
- `JGI_Database/{organism_id}/`: Downloaded files for each organism
- `JGI_Database/download.log`: Download operation log

**Key Functions:**

#### `download_organism_files(organism_id)`
Downloads all specified file types for a given organism.

**Parameters:**
- `organism_id` (str): JGI organism identifier

**Process:**
1. Authenticates with JGI portal using provided credentials
2. Retrieves file listing for the organism
3. Filters files based on configuration
4. Downloads matching files to organism-specific directory

**Configuration:**
```python
# Login credentials (should be configured per user)
login_payload = {
    'login': 'your_email@domain.com',
    'password': 'your_password',
}

# File types configuration in list_files_download.config
# Example: "proteins.fasta,annotations.gff,ko_annotations.tab"
```

**Usage Example:**
```bash
# 1. Prepare organism list
echo -e "12345\tFungal_species_1" > fungi_id_list.txt
echo -e "67890\tFungal_species_2" >> fungi_id_list.txt

# 2. Configure file types
echo "proteins.fasta,annotations.gff" > list_files_download.config

# 3. Run download script
python scripts/jgi_download.py
```

**Error Handling:**
- Checks for download errors in response content
- Logs failed downloads
- Creates directories if they don't exist

### `total_cazy_link_download_from_jgi.py`

**Purpose:** Downloads CAZyme (Carbohydrate-Active enZYmes) annotations from JGI Mycocosm portal.

**Dependencies:**
- `requests`: Web requests
- `bs4`: HTML parsing
- `csv`: CSV file handling

**Output:**
- `table_out_from_jgi_cazy_all.csv`: CAZyme annotation table

**Key Features:**
- Authenticates with JGI portal
- Scrapes CAZyme annotation tables
- Extracts protein information including domains and annotations

**Data Fields:**
- `protein_id`: Protein identifier
- `loc`: Genomic location
- `gene_len`: Gene length
- `prot_len`: Protein length
- `anot`: Functional annotation
- `domain`: CAZyme domain classification

**Note:** This script has known limitations and may require manual browser session for proper functionality.

## Data Processing Scripts

### `cutadapt.py`

**Purpose:** Wrapper script for Cutadapt tool to remove adapters and perform quality trimming.

**Dependencies:**
- `subprocess`: System command execution

**Key Functions:**

#### `run_cutadapt()`
Executes Cutadapt with appropriate parameters based on input configuration.

**Parameters (from Snakemake):**
- `snakemake.input`: Input FASTQ files
- `snakemake.output`: Output cleaned files
- `snakemake.params.adapter`: Adapter sequence
- `snakemake.params.format`: File format (fastq/fasta)
- `snakemake.threads`: Number of threads

**Quality Parameters:**
- `-q 20`: Minimum quality score of 20
- `-m 50`: Minimum read length of 50bp after trimming
- `-j {threads}`: Multi-threading support

**Processing Logic:**
```python
# For paired-end FASTQ
if len(snakemake.input) == 2 and format == "fastq":
    cutadapt -a ADAPTER -q 20 -j THREADS -m 50 \
        -o output1 -p output2 input1 input2

# For single-end FASTQ  
else:
    cutadapt -a ADAPTER -q 20 -j THREADS -m 50 \
        -o output input
```

**Usage Example:**
```bash
# Called automatically by Snakemake preprocessing rule
# Manual execution (not recommended):
python scripts/cutadapt.py
```

## Annotation Merge Scripts

### `merge_anot_tpm.py`

**Purpose:** Merges taxonomic annotation results with transcript abundance (TPM) data.

**Dependencies:**
- `pandas`: Data manipulation

**Key Functions:**

#### `merge_annotations()`
Combines taxonomic classifications with expression quantification.

**Input Files (via Snakemake):**
- `snakemake.input[0]`: Taxonomy annotation file
- `snakemake.input[1]`: TPM quantification file

**Output:**
- `snakemake.output[0]`: Merged annotation and TPM file

**Processing Steps:**
1. Load taxonomy file with columns: `['Name', 'Taxonomy']`
2. Load TPM file (format varies by source)
3. Perform left join on transcript names
4. Export merged results

**Data Schema:**
```python
# Input taxonomy file
columns = ['Name', 'Taxonomy']

# Merged output includes all TPM columns plus taxonomy
# Missing taxonomic assignments are preserved as NaN
```

**Usage Example:**
```python
# Input files:
# taxonomy.txt: Name\tTaxonomy
# tpm.txt: Name\tTPM\tEffectiveLength\t...

# Output:
# merged.txt: Name\tTPM\tEffectiveLength\t...\tTaxonomy
```

### `merge_anot_tpm_jgi.py`

**Purpose:** Integrates JGI protein annotations with transcript expression data.

**Dependencies:**
- `pandas`: Data manipulation

**Key Functions:**

#### `merge_jgi_annotations()`
Combines JGI taxonomic and functional annotations with TPM values.

**Input Schema:**
```python
# JGI annotation file (no header)
jgi_columns = ['Name', '#proteinId', '#organismId', 'lineage']

# TPM file (with header)
# Varies by quantification method
```

**Processing Features:**
- Handles large files with `low_memory=False`
- Performs left join to preserve all TPM entries
- Maintains original column structure with added annotations

**Output Format:**
- All original TPM columns
- Added JGI annotation columns
- Missing annotations marked as NaN

### `merge_anot_tpm_unip.py`

**Purpose:** Merges UniProt protein annotations with transcript abundance data.

**Key Functions:**

#### `merge_uniprot_annotations()`
Combines UniProt functional annotations with expression quantification.

**Input Processing:**
```python
# UniProt BLAST results formatting
blast_columns = ["Name", "uniprotId", "len", "Eval", "per_%"]

# Merge with TPM data on transcript name
# Remove statistical columns (last 3) for cleaner output
```

**Features:**
- Standardizes UniProt BLAST column names
- Performs left join on transcript names
- Optional column filtering for cleaner output

### `merge_jgi_anot.py`

**Purpose:** Merges BLAST search results with JGI taxonomic annotations.

**Key Functions:**

#### `merge_jgi_blast_results()`
Combines protein alignment results with taxonomic classifications.

**Processing:**
```python
# Inner join on protein ID
# Only keeps transcripts with both BLAST hits and taxonomic assignments
merge_type = "inner"  # Strict matching only
```

**Usage:**
- Quality control step to ensure complete annotation
- Filters out transcripts without reliable taxonomic assignment

## Database Mapping Scripts

### `uniprot2koMapper.py`

**Purpose:** Creates comprehensive mapping between UniProt protein identifiers and KEGG Orthology (KO) classifications.

**Dependencies:**
- `pandas`: Data manipulation
- `pathlib`: File path handling

**Key Functions:**

#### `create_uniprot_kegg_mapping()`
Generates cross-reference mapping between protein and functional databases.

**Input Files:**
- `idmapping_file`: UniProt ID mapping file (compressed)
- `kofile`: KEGG KO genes list
- `uniprot_list_file`: Intermediate UniProt-KEGG mapping

**Processing Pipeline:**

1. **Extract KEGG mappings from UniProt:**
```bash
# Creates intermediate file if it doesn't exist
echo 'Entry\tCross-reference (KEGG)' > uniprot2kegg.txt
zcat idmapping.dat.gz | grep -P '\tKEGG\t' | cut -f1,3 >> uniprot2kegg.txt
```

2. **Process KO gene mappings:**
```python
# Group multiple KOs per gene
gene2_ko = pd.read_csv(kofile).groupby(['geneID'], as_index=False)\
    .agg({'kID': lambda x: ";".join(set(x)).replace("ko:", "")})
```

3. **Create final mappings:**
```python
# Handle multiple KO assignments per UniProt ID
for entry in multi_ko_entries:
    uniprot_id = entry[1].strip()
    kIDs = entry[-1].strip().split(";")
    for kID in kIDs:
        # Create separate entry for each KO assignment
        add_mapping(uniprot_id, kID)
```

**Output Format:**
```
Entry	Cross-reference (KEGG)
P12345	K00001
P12345	K00002
P67890	K00003
```

**Performance Features:**
- Handles large datasets efficiently
- Memory optimization for big files
- Processes multi-valued mappings correctly

### `uniprot2ko_merge.py`

**Purpose:** Merges UniProt BLAST results with KEGG Orthology mappings.

**Key Functions:**

#### `merge_uniprot_ko_annotations()`
Combines protein alignments with functional classifications.

**Input Processing:**
```python
# Standardize column names
blast_columns = ["#trinityId", "uniprotID", "length", "eval", "match"]
ko_columns = ["uniprotId", "Cross-reference (KEGG)"]

# Parse UniProt ID format: "sp|P61272|RL35A_MACFA" -> "P61272"
df3 = df1['uniprotID'].str.split(pat="|", expand=True)
df1["uniprotId"] = df3["uniprotId"]  # Extract actual ID
```

**Output Columns:**
```python
output_columns = ['#trinityId', 'uniprotId', 'Cross-reference (KEGG)']
```

**Features:**
- Handles Swiss-Prot ID format parsing
- Left join preserves all BLAST hits
- Filters output to essential columns

### `ko_mapping_uniprot.py`

**Purpose:** Creates HDF5-formatted mapping dictionary for KEGG Orthology assignments.

**Dependencies:**
- `deepdish`: HDF5 data storage
- `collections.defaultdict`: Dictionary operations

**Key Functions:**

#### `create_ko_hdf5_mapping()`
Converts text-based mappings to efficient binary format.

**Processing:**
```python
# Create dictionary from tab-separated mapping file
d = defaultdict(list)
with open(input_file, 'r') as f:
    for line in f:
        k, v = line.rstrip().split("\t")
        d[k] = v

# Save as HDF5 for fast access
dd.io.save(output_file, d)
```

**Usage:**
- Optimizes lookup performance for large mapping datasets
- Reduces memory usage in downstream applications
- Compatible with various analysis tools

## Utility Scripts

### `jgi_blast_modify.py`

**Purpose:** Reformats JGI BLAST results for downstream processing.

**Key Functions:**

#### `reformat_jgi_blast()`
Standardizes JGI protein identifiers and organism information.

**Input Format:**
- Standard BLAST output with JGI protein IDs

**Processing Logic:**
```python
# Filter for JGI entries only
if 'jgi' in line:
    fields = line.split('\t')
    protein_info = fields[1].split('|')
    
    # Extract organism and protein ID
    organism_id = protein_info[1]
    protein_id = f"{protein_info[1]}|{protein_info[2]}"
    
    # Reformat output
    output_line = f"{fields[0]}\t{protein_id}\t{organism_id}\n"
```

**Output Format:**
```
#trinityId	#proteinId	#organismId
trinity_c0_g1_i1	12345|protein_001	12345
trinity_c0_g2_i1	12345|protein_002	12345
```

### `edit_abundance_tpm.smk`

**Purpose:** Reformats transcript quantification files for compatibility with analysis tools.

**Processing:**
- Standardizes TPM value formats
- Adjusts column headers
- Ensures numeric data types

### `merge_bac_ncbi.py`

**Purpose:** Processes NCBI bacterial database search results.

**Key Functions:**
- Merges bacterial taxonomy with BLAST results
- Filters for bacterial classifications only
- Standardizes taxonomic nomenclature

### Helper Scripts for HDF5 Mapping

#### `hdf5_KO_mapping.py`
Creates HDF5 mapping for KEGG Orthology classifications.

#### `hdf5_gene_mapping.py`
Generates HDF5 mapping for gene identifiers.

#### `hdf5_pathway_mapping.py`
Creates HDF5 mapping for metabolic pathway classifications.

**Common Pattern:**
```python
import deepdish as dd
from collections import defaultdict

# Load mapping data
d = defaultdict(list)
with open(input_file, 'r') as f:
    for line in f:
        k, v = line.rstrip().split("\t")
        d[k] = v

# Save as HDF5
dd.io.save(output_file, d)
```

## Script Integration in Pipeline

### Snakemake Integration

Most scripts are called through Snakemake rules:

```python
# Example rule using Python script
rule merge_annotations:
    input:
        taxonomy="results/taxonomy/{sample}.txt",
        tpm="results/quant/{sample}.sf"
    output:
        "results/merged/{sample}_annotated.txt"
    script:
        "../scripts/merge_anot_tpm.py"
```

### Input/Output Management

Scripts use Snakemake's automatic variable passing:

```python
# Accessing Snakemake variables in scripts
input_file1 = snakemake.input[0]
input_file2 = snakemake.input[1]
output_file = snakemake.output[0]
parameters = snakemake.params
threads = snakemake.threads
log_file = snakemake.log
```

### Error Handling

#### Common Patterns:
```python
# Memory optimization for large files
df = pd.read_table(file, low_memory=False)

# Safe file operations
if not os.path.exists(directory):
    os.makedirs(directory)

# Logging
with open(log_file, 'w') as log:
    log.write(f"Processing {input_file}\n")
```

## Performance Considerations

### Memory Management
- Use `low_memory=False` for large CSV/TSV files
- Process files in chunks for very large datasets
- Clean up temporary variables

### File I/O Optimization
- Use pandas for efficient data manipulation
- Prefer tab-separated formats for large datasets
- Implement streaming for very large files

### Parallel Processing
- Scripts support multi-threading where applicable
- Use Snakemake's thread allocation
- Consider memory vs. speed trade-offs

## Troubleshooting

### Common Issues

1. **Memory Errors:**
   ```python
   # Solution: Use chunked processing
   chunk_size = 10000
   for chunk in pd.read_csv(file, chunksize=chunk_size):
       process_chunk(chunk)
   ```

2. **File Format Issues:**
   ```python
   # Solution: Verify delimiters and encoding
   df = pd.read_csv(file, sep='\t', encoding='utf-8')
   ```

3. **Missing Dependencies:**
   ```bash
   # Solution: Install required packages
   conda install pandas deepdish beautifulsoup4
   ```

### Debugging Tips

1. **Check input file formats:**
   ```python
   print(f"Input file shape: {df.shape}")
   print(f"Columns: {df.columns.tolist()}")
   print(df.head())
   ```

2. **Validate merge operations:**
   ```python
   print(f"Before merge: {len(df1)} x {len(df2)}")
   merged = pd.merge(df1, df2, on='key', how='left')
   print(f"After merge: {len(merged)}")
   print(f"Missing values: {merged.isnull().sum()}")
   ```

3. **Monitor resource usage:**
   ```bash
   # Check memory usage during execution
   top -p $(pgrep -f python)
   ```

This comprehensive reference covers all Python scripts used in the Vasuki pipeline, providing detailed documentation for developers and users to understand, modify, and troubleshoot the analysis workflow.