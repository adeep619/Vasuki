# Vasuki Configuration Guide

This guide provides detailed information about configuring the Vasuki metatranscriptomic analysis pipeline.

## Configuration File Structure

The pipeline uses YAML configuration files to define samples, parameters, and analysis options. The main configuration sections are:

### 1. Sample Configuration

```yaml
samples:
    sample1: "sample1_name"
    sample2: "sample2_name"
    sample3: "sample3_name"
```

- **Key**: Internal sample identifier used in the pipeline
- **Value**: Actual sample name matching your input files

### 2. Input/Output Paths

```yaml
raw: "../data/raw_sequences"           # Path to raw sequencing data
results: "analysis_results"            # Output directory (will be created)
format: "fastq"                        # Input file format: "fastq" or "fasta"
reads: ["R1", "R2"]                    # Read identifiers for paired-end data
```

### 3. Performance Parameters

```yaml
threads: 40                            # Maximum threads per rule
maxmem: 500000                         # Maximum memory in MB (500GB)
io: 5                                  # I/O operation restrictions
```

**Memory Guidelines:**
- Small datasets (< 10M reads): 50GB (50000 MB)
- Medium datasets (10-50M reads): 200GB (200000 MB)
- Large datasets (> 50M reads): 500GB+ (500000+ MB)

### 4. Assembly Configuration

```yaml
assembly: "SPADES"                     # Assembly method: "SPADES" or "TRINITY"
```

**Assembly Method Comparison:**
- **SPAdes**: Better for bacterial/prokaryotic data, memory efficient
- **Trinity**: Better for eukaryotic transcriptomes, requires more memory

### 5. Quality Control

```yaml
adapter: "GATCGGAAGAGCA"              # Adapter sequence for trimming
fastqc: true                          # Enable FastQC quality analysis
```

### 6. Database Configuration

```yaml
# NCBI Database
NCBI: "v5"                            # NCBI database version

# SortMeRNA
sortmerna: "v4.2.0"                   # SortMeRNA database version

# JGI Configuration
jgi_config: "jgi_download.config"     # JGI download configuration file
jgi_organism_ids: "fungi_ids_list.txt" # List of JGI organism IDs

# KEGG Configuration
KO_list_file: "/path/to/ko_genes.list"        # KEGG orthology gene list
KEGG_pathways: "/path/to/pathway.list"        # KEGG pathway definitions
```

### 7. Analysis Toggles

```yaml
KEGG: true                            # Enable KEGG pathway annotation
megan: true                           # Enable MEGAN taxonomic analysis
```

## Example Configurations

### Basic Configuration (Small Dataset)

```yaml
# Basic configuration for small metatranscriptomic dataset
samples:
    control1: "control_sample_1"
    treatment1: "treatment_sample_1"

raw: "data/raw"
results: "results_basic"
format: "fastq"
reads: ["R1", "R2"]

threads: 20
maxmem: 100000
io: 3

assembly: "SPADES"
adapter: "GATCGGAAGAGCA"

NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"

fastqc: true
KEGG: true
megan: true
```

### High-Performance Configuration (Large Dataset)

```yaml
# High-performance configuration for large datasets
samples:
    site1_rep1: "environmental_site1_replicate1"
    site1_rep2: "environmental_site1_replicate2"
    site1_rep3: "environmental_site1_replicate3"
    site2_rep1: "environmental_site2_replicate1"
    site2_rep2: "environmental_site2_replicate2"
    site2_rep3: "environmental_site2_replicate3"

raw: "/data/metatranscriptomes/raw"
results: "comprehensive_analysis_2024"
format: "fastq"
reads: ["R1", "R2"]

threads: 64
maxmem: 1000000  # 1TB
io: 10

assembly: "TRINITY"  # Better for complex communities
adapter: "GATCGGAAGAGCA"

NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"
jgi_organism_ids: "comprehensive_fungi_ids.txt"

KO_list_file: "/databases/KEGG/ko_genes.list"
KEGG_pathways: "/databases/KEGG/pathway.list"

fastqc: true
KEGG: true
megan: true
```

### Minimal Configuration (Testing)

```yaml
# Minimal configuration for testing
samples:
    test: "test_sample"

raw: "test_data"
results: "test_results"
format: "fastq"
reads: ["R1", "R2"]

threads: 8
maxmem: 32000
io: 2

assembly: "SPADES"
adapter: "GATCGGAAGAGCA"

NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"

fastqc: false  # Skip for faster testing
KEGG: false    # Skip for faster testing
megan: false   # Skip for faster testing
```

## Database Setup Configuration

### JGI Download Configuration (`jgi_download.config`)

```
username=your_jgi_username
password=your_jgi_password
```

### Organism ID Lists

Create text files with JGI organism IDs (one per line):

**fungi_ids_list.txt:**
```
12345
12346
12347
```

## File Naming Conventions

### Input Files
Your raw sequencing files should follow this naming pattern:
```
{sample}_{read}.{format}.gz
```

Examples:
- `sample1_R1.fastq.gz`
- `sample1_R2.fastq.gz`
- `treatment_A_R1.fastq.gz`
- `treatment_A_R2.fastq.gz`

### Configuration File Naming
- Main config: `config.yaml` or `my_analysis_config.yaml`
- Test config: `config_test.yaml`
- Project-specific: `config_{project_name}.yaml`

## Validation and Testing

Before running the full pipeline, validate your configuration:

```bash
# Dry run to check configuration
snakemake -n -s Snakefile.smk --configfile your_config.yaml

# Test with a subset of rules
snakemake -j 4 -s Snakefile.smk --configfile your_config.yaml --until qc
```

## Common Configuration Issues

### 1. Memory Problems
**Error:** Jobs killed due to memory limits
**Solution:** Increase `maxmem` parameter or reduce `threads`

### 2. Path Issues
**Error:** Input files not found
**Solution:** Check `raw` path and file naming conventions

### 3. Database Issues
**Error:** Database files not found
**Solution:** Verify database paths in configuration and ensure databases are built

### 4. Threading Issues
**Error:** Too many threads requested
**Solution:** Adjust `threads` parameter based on available CPU cores

## Environment-Specific Configurations

### HPC/Slurm Clusters
```yaml
threads: 32      # Match node specifications
maxmem: 500000   # Match node memory
io: 8            # Higher for network storage
```

### Local Workstations
```yaml
threads: 8       # Conservative for desktop use
maxmem: 64000    # Typical workstation memory
io: 3            # Lower for local storage
```

### Cloud Computing
```yaml
threads: 16      # Instance-dependent
maxmem: 120000   # Instance-dependent
io: 5            # Network storage considerations
```