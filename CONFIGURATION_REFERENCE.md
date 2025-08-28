# Configuration Reference - Vasuki Pipeline

This document provides comprehensive documentation for all configuration files and parameters used in the Vasuki metatranscriptomics pipeline.

## Table of Contents

- [Main Configuration File](#main-configuration-file)
- [Environment Configurations](#environment-configurations)
- [Database Configurations](#database-configurations)
- [Download Configurations](#download-configurations)
- [Performance Tuning](#performance-tuning)
- [Advanced Configuration](#advanced-configuration)

## Main Configuration File

### `config_aq_21_s.yaml`

The main configuration file defines all parameters for pipeline execution, including samples, paths, databases, and performance settings.

#### Sample Configuration

```yaml
samples:
    AFP2_C1_E_R_D01: "AFP2_C1_E_R_D01"
    AFP2_C1_E_R_D02: "AFP2_C1_E_R_D02"
    # ... additional samples
```

**Purpose:** Defines sample identifiers for processing
**Format:** Dictionary mapping sample names to identifiers
**Usage:** Each key-value pair represents one sample to process

**Example Configurations:**

```yaml
# Single sample
samples:
    my_sample: "my_sample"

# Multiple samples with descriptive names
samples:
    control_rep1: "CTRL_01"
    control_rep2: "CTRL_02"
    treatment_rep1: "TREAT_01"
    treatment_rep2: "TREAT_02"

# Batch processing
samples:
    sample01: "batch1_sample01"
    sample02: "batch1_sample02"
    # ... up to hundreds of samples
```

#### Path Configuration

```yaml
raw: "../data/sfb_aq_s_21_MT_total_RNA"
results: "sfb_aq_s_21_MT_total_RNA_results"
format: "fastq"
reads: ["R1", "R2"]
```

| Parameter | Description | Examples | Required |
|-----------|-------------|----------|----------|
| `raw` | Path to raw sequencing data directory | `"../data/raw_reads"`, `"/absolute/path/to/data"` | Yes |
| `results` | Output directory for all results | `"results"`, `"analysis_output"` | Yes |
| `format` | File format of sequencing data | `"fastq"`, `"fasta"` | Yes |
| `reads` | Read types for paired/single-end data | `["R1", "R2"]`, `["R1"]` | Yes |

**File Naming Conventions:**
```bash
# Expected file naming for paired-end FASTQ
{raw}/{sample}_R1.fastq.gz
{raw}/{sample}_R2.fastq.gz

# Expected file naming for single-end FASTQ
{raw}/{sample}_R1.fastq.gz

# Expected file naming for FASTA
{raw}/{sample}.fasta.gz
```

#### Performance Configuration

```yaml
threads: 40
maxmem: 500000
io: 5
```

| Parameter | Description | Default | Recommendations |
|-----------|-------------|---------|-----------------|
| `threads` | Maximum threads per rule | 40 | Set to available CPU cores |
| `maxmem` | Maximum memory in MB | 500000 | Set to 80% of available RAM |
| `io` | I/O operation limit | 5 | Reduce for slow storage |

**Performance Tuning Guidelines:**

```yaml
# High-performance server (128 cores, 1TB RAM)
threads: 120
maxmem: 800000
io: 10

# Standard workstation (16 cores, 64GB RAM)
threads: 14
maxmem: 50000
io: 4

# Modest computer (8 cores, 16GB RAM)
threads: 6
maxmem: 12000
io: 2
```

#### Assembly Configuration

```yaml
assembly: "SPADES"  # or "TRINITY"
adapter: "GATCGGAAGAGCA"
```

| Parameter | Description | Options | Notes |
|-----------|-------------|---------|-------|
| `assembly` | Assembly method | `"SPADES"`, `"TRINITY"` | SPAdes generally faster, Trinity more sensitive |
| `adapter` | Illumina adapter sequence | First 13bp of adapter | Specific to sequencing protocol |

**Assembly Method Comparison:**

| Feature | SPAdes | Trinity |
|---------|---------|---------|
| Speed | Faster | Slower |
| Memory Usage | Lower | Higher |
| Assembly Quality | Good | Excellent |
| Best For | Large datasets, limited resources | High-quality assemblies |

#### Database Configuration

```yaml
NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"
jgi_organism_ids: "fungi_ids_list.txt"
KO_list_file: "/mnt/biodiv/KEGG/kegg/genes/ko/ko_genes.list"
KEGG_pathways: "/mnt/biodiv/KEGG/kegg/pathway/pathway.list"
```

| Parameter | Description | Format | Purpose |
|-----------|-------------|--------|---------|
| `NCBI` | NCBI database version | Version string | Taxonomic classification |
| `sortmerna` | SortMeRNA database version | Version string | rRNA/mRNA separation |
| `jgi_config` | JGI download configuration | Filename | File types to download |
| `jgi_organism_ids` | JGI organism list | Filename | Target organisms |
| `KO_list_file` | KEGG orthology genes | Full path | Functional annotation |
| `KEGG_pathways` | KEGG pathway information | Full path | Pathway analysis |

### Configuration Templates

#### Minimal Configuration

```yaml
# minimal_config.yaml - For testing or small datasets
samples:
    test_sample: "test_sample"

raw: "test_data"
results: "test_results"
format: "fastq"
reads: ["R1", "R2"]

threads: 4
maxmem: 8000
io: 2

assembly: "SPADES"
adapter: "GATCGGAAGAGCA"

# Use default database settings
NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"
```

#### Production Configuration

```yaml
# production_config.yaml - For large-scale analysis
samples:
    # Import from external file or generate programmatically
    sample01: "experiment_01"
    sample02: "experiment_02"
    # ... many more samples

raw: "/data/sequencing/batch_001"
results: "/results/metatranscriptomics/batch_001"
format: "fastq"
reads: ["R1", "R2"]

# High-performance settings
threads: 80
maxmem: 1000000
io: 15

assembly: "TRINITY"  # For highest quality
adapter: "GATCGGAAGAGCA"

# Production database paths
NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "production_jgi.config"
jgi_organism_ids: "target_organisms.txt"
KO_list_file: "/databases/KEGG/ko_genes.list"
KEGG_pathways: "/databases/KEGG/pathway.list"
```

## Environment Configurations

### Overview

The pipeline uses multiple conda environments to manage dependencies for different analysis steps.

### `envs/preprocessing.yaml`

**Purpose:** Quality control and preprocessing tools

```yaml
name: preprocessing
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - cutadapt          # Adapter removal
  - fastqc=0.11.9     # Quality assessment
  - multiqc=1.8       # Report aggregation
```

**Tools Included:**
- **Cutadapt**: Removes adapters and low-quality sequences
- **FastQC**: Generates quality control reports
- **MultiQC**: Aggregates multiple QC reports

### `envs/assembly.yaml`

**Purpose:** Transcriptome assembly

```yaml
name: assembly
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - trinity=2.9.1     # De novo assembly
```

**Tools Included:**
- **Trinity**: De novo transcriptome assembler
- **Salmon**: Transcript quantification (bundled with Trinity)

### `envs/assemblyspades.yaml`

**Purpose:** Alternative assembly method

```yaml
name: assemblyspades
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - spades            # Alternative assembler
  - salmon            # Transcript quantification
```

### `envs/diamond.yaml`

**Purpose:** Protein sequence alignment

```yaml
name: diamond
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - diamond=2.0.4     # Fast protein aligner
```

**Tools Included:**
- **Diamond**: High-performance protein sequence aligner

### `envs/sortmerna.yaml`

**Purpose:** rRNA/mRNA separation

```yaml
name: sortmerna
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - sortmerna=4.2.0   # rRNA filtering
```

### `envs/bowtie.yml`

**Purpose:** Read alignment and filtering

```yaml
name: diamond  # Note: name should be 'bowtie'
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - bowtie2=2.4       # Read aligner
  - samtools=1.3.1    # SAM/BAM processing
  - bedtools=2.30.0   # Genomic interval tools
```

### `envs/uniprot.yml`

**Purpose:** UniProt annotation processing

```yaml
name: uniprot
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - deepdish=0.3.4    # HDF5 data handling
  - rapsearch=2.24    # Protein search
  - python=3.8.2      # Python runtime
```

### Environment Usage

#### Automatic Environment Management
```bash
# Snakemake automatically creates and uses environments
snakemake --use-conda

# Manual environment creation
conda env create -f envs/preprocessing.yaml
conda activate preprocessing
```

#### Custom Environment Modifications

```yaml
# custom_preprocessing.yaml
name: custom_preprocessing
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - cutadapt=3.4      # Updated version
  - fastqc=0.11.9
  - multiqc=1.10      # Updated version
  - trimmomatic       # Additional tool
```

## Database Configurations

### JGI Download Configuration

#### `jgi_download.config`

```
CDS,aa.fasta.gz,nt.fasta.gz,gff.gz,Repeatmasked.fasta.gz,KEGG.tab.gz,GO.tab.gz,IPR.tab.gz,KOG.tab.gz,SigP.tab.gz,ecpathwayinfo,goinfo,koginfo,signalp,domaininfo,kog.tab.gz,ipr.tab.gz,go.tab.gz,kegg.tab.gz,fasta.gz,gff3
```

**Format:** Comma-separated list of file types to download

**Available File Types:**

| File Type | Description | Size | Priority |
|-----------|-------------|------|----------|
| `CDS` | Coding sequences | Medium | High |
| `aa.fasta.gz` | Amino acid sequences | Large | High |
| `nt.fasta.gz` | Nucleotide sequences | Large | Medium |
| `gff.gz` | Gene annotations | Small | High |
| `KEGG.tab.gz` | KEGG annotations | Small | High |
| `GO.tab.gz` | Gene Ontology annotations | Small | Medium |
| `IPR.tab.gz` | InterPro domains | Small | Medium |
| `KOG.tab.gz` | KOG classifications | Small | Low |
| `SigP.tab.gz` | Signal peptides | Small | Low |

**Custom Configurations:**

```bash
# Minimal download (fastest)
echo "aa.fasta.gz,KEGG.tab.gz" > minimal_jgi.config

# Comprehensive download (most complete)
echo "CDS,aa.fasta.gz,nt.fasta.gz,gff.gz,KEGG.tab.gz,GO.tab.gz,IPR.tab.gz" > complete_jgi.config

# Functional annotation only
echo "KEGG.tab.gz,GO.tab.gz,IPR.tab.gz,KOG.tab.gz" > functional_jgi.config
```

#### `fungi_ids_list.txt`

**Format:** Tab-separated organism identifiers

```
12345	Aspergillus_fumigatus
67890	Candida_albicans
54321	Saccharomyces_cerevisiae
```

**Creating Custom Organism Lists:**

```bash
# From JGI portal organism browser
# 1. Navigate to JGI portal
# 2. Browse available organisms
# 3. Copy organism IDs and names
# 4. Format as tab-separated file

# Example for bacterial organisms
echo -e "organism_id\torganism_name" > bacteria_ids.txt
echo -e "123456\tEscherichia_coli" >> bacteria_ids.txt
echo -e "789012\tBacillus_subtilis" >> bacteria_ids.txt
```

### Database Paths

#### KEGG Database Configuration

```yaml
# Local KEGG installation
KO_list_file: "/databases/KEGG/ko_genes.list"
KEGG_pathways: "/databases/KEGG/pathway.list"

# Network KEGG access (if available)
KO_list_file: "https://kegg.jp/data/ko_genes.list"
KEGG_pathways: "https://kegg.jp/data/pathway.list"

# Shared cluster KEGG
KO_list_file: "/shared/databases/KEGG/ko_genes.list"
KEGG_pathways: "/shared/databases/KEGG/pathway.list"
```

#### NCBI Database Configuration

```yaml
# Version specifications
NCBI: "v5"        # Current version
# NCBI: "v4"      # Previous version for reproducibility
# NCBI: "latest"  # Always use latest (not recommended for production)

# Custom NCBI database path (advanced)
NCBI_path: "/custom/ncbi/database/location"
```

## Download Configurations

### JGI Portal Access

#### Credentials Configuration

```python
# In scripts/jgi_download.py
login_payload = {
    'login': 'your_email@institution.edu',
    'password': 'your_secure_password',
}
```

**Security Best Practices:**

```bash
# Use environment variables
export JGI_LOGIN="your_email@institution.edu"
export JGI_PASSWORD="your_secure_password"

# Modify script to use environment variables
import os
login_payload = {
    'login': os.environ['JGI_LOGIN'],
    'password': os.environ['JGI_PASSWORD'],
}
```

#### Download Configuration Templates

```bash
# Essential files only (minimal storage)
echo "aa.fasta.gz,KEGG.tab.gz" > essential_files.config

# Annotation focus (functional analysis)
echo "aa.fasta.gz,KEGG.tab.gz,GO.tab.gz,IPR.tab.gz,gff.gz" > annotation_files.config

# Complete genome data (comprehensive analysis)
echo "CDS,aa.fasta.gz,nt.fasta.gz,gff.gz,KEGG.tab.gz,GO.tab.gz,IPR.tab.gz,KOG.tab.gz" > complete_files.config
```

## Performance Tuning

### Resource Optimization

#### CPU Configuration

```yaml
# Rule-specific thread allocation
threads: 40  # Global maximum

# Actual usage varies by rule:
# - FastQC: uses all available threads
# - Trinity: uses all available threads
# - Diamond: uses all available threads
# - Merge scripts: typically use 1 thread
```

#### Memory Configuration

```yaml
# Memory allocation guidelines
maxmem: 500000  # 500 GB in MB

# Rule-specific memory usage:
# - Trinity: Can use up to maxmem
# - SPAdes: Typically uses 50-200 GB
# - Diamond: 8-32 GB depending on database
# - Quality control: 2-8 GB
```

#### I/O Configuration

```yaml
# I/O operation limits
io: 5  # Concurrent I/O operations

# Adjust based on storage:
# - SSD storage: io: 10-20
# - HDD storage: io: 2-5
# - Network storage: io: 1-3
```

### Performance Profiles

#### High-Performance Computing (HPC)

```yaml
# HPC cluster configuration
threads: 128
maxmem: 1500000  # 1.5 TB
io: 20

# Additional HPC considerations
cluster_config: "cluster.yaml"
```

#### Cloud Computing

```yaml
# AWS/GCP instance configuration
threads: 32
maxmem: 250000   # 250 GB
io: 8

# Cost optimization
spot_instances: true
auto_scaling: true
```

#### Local Workstation

```yaml
# Typical workstation setup
threads: 16
maxmem: 60000    # 60 GB
io: 4

# Conservative settings to maintain system responsiveness
```

## Advanced Configuration

### Custom Rule Parameters

#### Assembly Optimization

```yaml
# Trinity-specific parameters
trinity_params:
    min_contig_length: 200
    cpu_intensive: true
    normalize_reads: true

# SPAdes-specific parameters
spades_params:
    k_mer_sizes: "21,33,55,77"
    careful_mode: true
```

#### Database Search Parameters

```yaml
# Diamond search parameters
diamond_params:
    evalue: 1e-5
    max_targets: 10
    sensitive_mode: true

# BLAST parameters (if used)
blast_params:
    evalue: 1e-3
    max_target_seqs: 5
```

### Conditional Configuration

#### Sample-Specific Settings

```yaml
# Different settings for different sample types
sample_configs:
    high_biomass:
        assembly: "TRINITY"
        maxmem: 800000
    low_biomass:
        assembly: "SPADES"
        maxmem: 200000
```

#### Environment-Specific Settings

```yaml
# Development environment
development:
    threads: 4
    maxmem: 16000
    samples:
        test1: "test1"
        test2: "test2"

# Production environment
production:
    threads: 80
    maxmem: 1000000
    samples: !include "production_samples.yaml"
```

### Configuration Validation

#### Schema Validation

```yaml
# Required parameters
required:
    - samples
    - raw
    - results
    - format
    - reads
    - threads
    - maxmem

# Optional parameters with defaults
optional:
    assembly: "SPADES"
    adapter: "GATCGGAAGAGCA"
    io: 5
```

#### Configuration Testing

```bash
# Validate configuration syntax
snakemake --configfile config.yaml --validate

# Dry run to check rule dependencies
snakemake --configfile config.yaml --dry-run

# Generate workflow diagram
snakemake --configfile config.yaml --dag | dot -Tpng > workflow.png
```

### Configuration Management

#### Version Control

```bash
# Track configuration changes
git add config*.yaml
git commit -m "Update configuration for batch analysis"

# Tag stable configurations
git tag -a v1.0-config -m "Stable configuration for publication"
```

#### Configuration Templates

```bash
# Create configuration from template
cp config_template.yaml project_config.yaml

# Generate configuration programmatically
python scripts/generate_config.py \
    --samples samples.txt \
    --output project_config.yaml \
    --threads 40 \
    --memory 500000
```

This comprehensive configuration reference provides detailed documentation for all configuration aspects of the Vasuki pipeline, enabling users to customize the analysis for their specific needs and computational resources.