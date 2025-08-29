# Dependencies and Environment Reference - Vasuki Pipeline

This document provides comprehensive documentation for all software dependencies, environment requirements, and installation procedures for the Vasuki metatranscriptomics pipeline.

## Table of Contents

- [System Requirements](#system-requirements)
- [Core Dependencies](#core-dependencies)
- [Conda Environments](#conda-environments)
- [External Databases](#external-databases)
- [Installation Guide](#installation-guide)
- [Troubleshooting Dependencies](#troubleshooting-dependencies)
- [Version Compatibility](#version-compatibility)

## System Requirements

### Minimum Requirements

| Component | Specification | Notes |
|-----------|---------------|-------|
| **CPU** | 4 cores | Assembly will be slow |
| **RAM** | 16 GB | Minimum for small datasets |
| **Storage** | 100 GB free | For small datasets and databases |
| **OS** | Linux (64-bit) | Ubuntu 18.04+, CentOS 7+, or equivalent |
| **Python** | 3.6+ | Managed by conda environments |

### Recommended Requirements

| Component | Specification | Notes |
|-----------|---------------|-------|
| **CPU** | 16+ cores | Optimal for parallel processing |
| **RAM** | 64+ GB | Required for Trinity assembly |
| **Storage** | 500+ GB free | For multiple samples and databases |
| **OS** | Ubuntu 20.04 LTS | Well-tested environment |
| **Network** | High-speed internet | For database downloads |

### High-Performance Requirements

| Component | Specification | Notes |
|-----------|---------------|-------|
| **CPU** | 32+ cores | For production workflows |
| **RAM** | 256+ GB | For large assemblies |
| **Storage** | 2+ TB (SSD) | Fast I/O for optimal performance |
| **Network** | 10+ Gbps | For rapid database downloads |

## Core Dependencies

### Workflow Management

#### Snakemake
- **Version**: 6.15.5+
- **Purpose**: Workflow orchestration and dependency management
- **Installation**: Via conda
- **Dependencies**: Python 3.6+

```bash
# Install Snakemake
conda install -c bioconda snakemake=6.15.5
```

### Data Processing Tools

#### Quality Control
- **FastQC** (v0.11.9): Quality assessment of sequencing reads
- **MultiQC** (v1.8): Aggregation of quality control reports
- **Cutadapt** (latest): Adapter removal and quality trimming

#### Assembly Tools
- **Trinity** (v2.9.1): De novo transcriptome assembly
- **SPAdes** (latest): Alternative genome/transcriptome assembler
- **Salmon** (bundled): Transcript quantification

#### Sequence Alignment
- **Diamond** (v2.0.4): High-performance protein sequence aligner
- **Bowtie2** (v2.4): Read alignment for filtering
- **SAMtools** (v1.3.1): SAM/BAM file processing

#### Filtering Tools
- **SortMeRNA** (v4.2.0): rRNA/mRNA separation
- **BEDtools** (v2.30.0): Genomic interval operations

#### Annotation Tools
- **RAPSearch** (v2.24): Protein sequence search
- **MEGAN6** (external): Taxonomic analysis (requires separate installation)

### Python Libraries

#### Data Processing
- **Pandas** (latest): Data manipulation and analysis
- **NumPy** (latest): Numerical computing
- **DeepDish** (v0.3.4): HDF5 data storage

#### Web Scraping (for JGI downloads)
- **Requests** (latest): HTTP library
- **BeautifulSoup4** (latest): HTML parsing
- **urllib3** (latest): URL handling

#### Bioinformatics
- **Biopython** (latest): Biological sequence analysis
- **Pysam** (latest): SAM/BAM file manipulation

## Conda Environments

### Main Environment: `metatrans.yaml`

```yaml
# Platform: linux-64
# Contains all core packages for the pipeline
# Based on Python 3.6.13 with bioinformatics tools
```

**Key packages:**
- Python 3.6.13
- Pandas 1.1.5
- NumPy 1.19.2
- Snakemake 3.13.3 (Note: older version in main env)

### Specialized Environments

#### 1. Preprocessing Environment (`envs/preprocessing.yaml`)

```yaml
name: preprocessing
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - cutadapt          # Latest version
  - fastqc=0.11.9     # Specific version for consistency
  - multiqc=1.8       # Specific version for compatibility
```

**Purpose**: Quality control and read preprocessing
**Tools**: Cutadapt, FastQC, MultiQC
**Resource Usage**: Low to moderate

#### 2. Assembly Environment (`envs/assembly.yaml`)

```yaml
name: assembly
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - trinity=2.9.1     # Specific version for reproducibility
```

**Purpose**: De novo transcriptome assembly
**Tools**: Trinity (includes Bowtie2, Jellyfish, Salmon)
**Resource Usage**: Very high memory and CPU

#### 3. Alternative Assembly Environment (`envs/assemblyspades.yaml`)

```yaml
name: assemblyspades
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - spades            # Latest version
  - salmon            # For quantification
```

**Purpose**: Alternative assembly method
**Tools**: SPAdes, Salmon
**Resource Usage**: High, but lower than Trinity

#### 4. Diamond Environment (`envs/diamond.yaml`)

```yaml
name: diamond
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - diamond=2.0.4     # Specific version for consistency
```

**Purpose**: Protein sequence alignment
**Tools**: Diamond BLAST
**Resource Usage**: Moderate to high

#### 5. Read Filtering Environment (`envs/bowtie.yml`)

```yaml
name: diamond  # Note: should be renamed to 'bowtie'
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - bowtie2=2.4       # Read alignment
  - samtools=1.3.1    # SAM/BAM processing
  - bedtools=2.30.0   # Genomic intervals
```

**Purpose**: Host read filtering and alignment
**Tools**: Bowtie2, SAMtools, BEDtools
**Resource Usage**: Moderate

#### 6. rRNA Filtering Environment (`envs/sortmerna.yaml`)

```yaml
name: sortmerna
channels:
  - bioconda
  - conda-forge
  - defaults
  - r
dependencies:
  - sortmerna=4.2.0   # Specific version for database compatibility
```

**Purpose**: Ribosomal RNA filtering
**Tools**: SortMeRNA
**Resource Usage**: Moderate

#### 7. UniProt Processing Environment (`envs/uniprot.yml`)

```yaml
name: uniprot
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - deepdish=0.3.4    # HDF5 data handling
  - rapsearch=2.24    # Protein search
  - python=3.8.2      # Specific Python version
```

**Purpose**: UniProt annotation processing
**Tools**: DeepDish, RAPSearch, Python
**Resource Usage**: Low to moderate

## External Databases

### Required Databases

#### NCBI Databases
- **NCBI NR**: Non-redundant protein sequences
- **NCBI Taxonomy**: Taxonomic classifications
- **Version**: Configurable (default: v5)
- **Size**: ~200-500 GB
- **Update frequency**: Monthly

#### JGI Databases
- **Source**: Joint Genome Institute portal
- **Content**: Organism-specific protein sequences and annotations
- **Access**: Requires JGI portal account
- **Size**: Variable (1-100 GB per organism)

#### UniProt Databases
- **UniProt KB**: Protein knowledge base
- **ID Mapping**: Cross-references between databases
- **Size**: ~50-100 GB
- **Update frequency**: Monthly

#### KEGG Databases
- **KO Genes**: KEGG Orthology gene classifications
- **Pathways**: Metabolic pathway definitions
- **Access**: Requires KEGG license for full access
- **Size**: ~1-5 GB

### Optional Databases

#### SortMeRNA Databases
- **rRNA sequences**: For filtering ribosomal RNA
- **Version**: v4.2.0 compatible
- **Size**: ~1-2 GB
- **Source**: SILVA, Greengenes, RFAM

#### MEGAN Databases
- **Taxonomy mapping**: For MEGAN6 analysis
- **Size**: ~10-50 GB
- **Source**: NCBI taxonomy dumps

## Installation Guide

### Step 1: System Preparation

```bash
# Update system packages (Ubuntu/Debian)
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y wget curl git build-essential

# Install conda/miniconda if not present
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc
```

### Step 2: Pipeline Installation

```bash
# Clone repository
git clone <vasuki-pipeline-repository>
cd vasuki-pipeline

# Create main environment
conda env create -f metatrans.yaml

# Activate environment
conda activate vasuki

# Verify installation
snakemake --version
python --version
```

### Step 3: Environment Setup

```bash
# Create all specialized environments
conda env create -f envs/preprocessing.yaml
conda env create -f envs/assembly.yaml
conda env create -f envs/assemblyspades.yaml
conda env create -f envs/diamond.yaml
conda env create -f envs/bowtie.yml
conda env create -f envs/sortmerna.yaml
conda env create -f envs/uniprot.yml

# List created environments
conda env list
```

### Step 4: Database Setup

```bash
# Create database directory
mkdir -p database

# Download NCBI databases (example)
# Note: Actual download commands depend on your setup
wget -O database/ncbi_nr.tar.gz "ftp://ftp.ncbi.nlm.nih.gov/blast/db/nr.*.tar.gz"

# Extract databases
cd database
tar -xzf ncbi_nr.tar.gz

# Set up JGI credentials (edit scripts/jgi_download.py)
# Configure KEGG paths in config files
```

### Step 5: External Tool Installation

#### MEGAN6 Installation

```bash
# Download MEGAN6 (requires registration)
# Install according to MEGAN documentation
wget -O MEGAN6.zip "https://software-ab.informatik.uni-tuebingen.de/download/megan6/MEGAN6.zip"
unzip MEGAN6.zip
sudo ln -s $(pwd)/MEGAN6/MEGAN /usr/local/bin/MEGAN

# Verify installation
MEGAN -h
```

## Troubleshooting Dependencies

### Common Issues and Solutions

#### 1. Conda Environment Creation Fails

**Problem**: Package conflicts or missing channels

```bash
# Solution 1: Clean conda cache
conda clean --all

# Solution 2: Use mamba for faster resolution
conda install mamba -c conda-forge
mamba env create -f metatrans.yaml

# Solution 3: Install packages individually
conda create -n vasuki_custom python=3.8
conda activate vasuki_custom
conda install -c bioconda snakemake
conda install -c bioconda trinity
# ... continue with other packages
```

#### 2. Trinity Installation Issues

**Problem**: Trinity compilation fails

```bash
# Check system dependencies
sudo apt install -y build-essential cmake zlib1g-dev

# Alternative: Use Docker
docker pull trinityrnaseq/trinityrnaseq:latest

# Use in Snakemake rule
container: "docker://trinityrnaseq/trinityrnaseq:latest"
```

#### 3. Diamond Database Creation

**Problem**: Diamond database format errors

```bash
# Recreate Diamond database
conda activate diamond
diamond makedb --in proteins.fasta --db proteins_db

# Verify database
diamond dbinfo -d proteins_db.dmnd
```

#### 4. Memory Issues

**Problem**: Out of memory errors

```bash
# Check available memory
free -h

# Monitor memory usage
htop

# Adjust configuration
# Reduce maxmem parameter
# Use SPAdes instead of Trinity
# Process samples individually
```

#### 5. Network Issues

**Problem**: Database download failures

```bash
# Test network connectivity
ping 8.8.8.8

# Use alternative download methods
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 [URL]

# Set up proxy if needed
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
```

### Environment-Specific Troubleshooting

#### Preprocessing Environment

```bash
# Test FastQC installation
conda activate preprocessing
fastqc --version

# Test Cutadapt
cutadapt --version

# Fix common issues
conda update fastqc
conda update cutadapt
```

#### Assembly Environment

```bash
# Test Trinity installation
conda activate assembly
Trinity --version

# Check Trinity dependencies
Trinity --show_full_usage

# Memory test
Trinity --CPU 1 --max_memory 1G --test
```

#### Diamond Environment

```bash
# Test Diamond installation
conda activate diamond
diamond version

# Test basic functionality
diamond help

# Performance test
diamond makedb --in test.fasta --db test_db
```

## Version Compatibility

### Tested Combinations

#### Stable Configuration
```yaml
Python: 3.8.2
Snakemake: 6.15.5
Trinity: 2.9.1
Diamond: 2.0.4
FastQC: 0.11.9
MultiQC: 1.8
Cutadapt: 3.4
```

#### Legacy Configuration
```yaml
Python: 3.6.13
Snakemake: 3.13.3
Trinity: 2.8.5
Diamond: 2.0.2
FastQC: 0.11.7
MultiQC: 1.6
```

### Compatibility Matrix

| Tool | Min Version | Max Version | Notes |
|------|-------------|-------------|-------|
| Python | 3.6 | 3.9 | 3.10+ may have compatibility issues |
| Snakemake | 5.0 | 7.0 | 7.0+ requires syntax updates |
| Trinity | 2.8 | 2.15 | Newer versions recommended |
| Diamond | 2.0 | 2.1 | Version 2.0.4+ recommended |
| FastQC | 0.11.7 | 0.11.9 | Stable across versions |
| Cutadapt | 3.0 | 4.0 | Version 3.4+ recommended |

### Update Procedures

#### Updating Core Environment

```bash
# Backup current environment
conda env export -n vasuki > vasuki_backup.yaml

# Update packages
conda activate vasuki
conda update --all

# Test functionality
snakemake --version
python -c "import pandas; print(pandas.__version__)"
```

#### Updating Specialized Environments

```bash
# Update preprocessing environment
conda activate preprocessing
conda update cutadapt fastqc multiqc

# Update assembly environment
conda activate assembly
conda update trinity

# Test updates
fastqc --version
Trinity --version
```

### Version Pinning

#### For Reproducibility

```yaml
# Pin specific versions in environment files
dependencies:
  - trinity=2.9.1
  - diamond=2.0.4
  - fastqc=0.11.9
  - multiqc=1.8
```

#### For Flexibility

```yaml
# Allow minor version updates
dependencies:
  - trinity>=2.9,<2.16
  - diamond>=2.0,<2.2
  - fastqc>=0.11.7
  - multiqc>=1.8
```

This comprehensive dependencies reference ensures users can successfully install, configure, and maintain the Vasuki pipeline across different computing environments and system configurations.