# Vasuki Metatranscriptomics Pipeline - API Documentation

<p align="left">
<img src="vasuki logo.jfif" alt="logo" width="150"/>
</p>

## Overview

Vasuki is a comprehensive Snakemake-based metatranscriptomics pipeline designed for analyzing RNA-seq data from microbial communities. The pipeline performs quality control, assembly, taxonomic annotation, and functional analysis using various databases including JGI, UniProt, NCBI, and KEGG.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Pipeline Components](#pipeline-components)
- [API Reference](#api-reference)
- [Usage Examples](#usage-examples)
- [Output Files](#output-files)
- [Troubleshooting](#troubleshooting)

## Installation

### Prerequisites

- **Conda/Mamba**: Required for environment management
- **Megan6**: Essential for taxonomic analysis
- **Database Files**: JGI, UniProt, and Megan databases (see `files.txt`)

### Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd vasuki-pipeline
   ```

2. **Create the conda environment:**
   ```bash
   conda env create -f metatrans.yaml
   conda activate vasuki
   ```

3. **Prepare databases:**
   - Download required database files as specified in `files.txt`
   - Place databases in the `database/` directory

## Quick Start

### Basic Usage

```bash
# Activate environment
conda activate vasuki

# Run the pipeline
./pipeline.sh

# Or run directly with snakemake
snakemake -j 50 -s Snakefile.smk --use-conda --configfile config_aq_21_s.yaml -p
```

### Configuration

Edit the configuration file (`config_aq_21_s.yaml`) to specify:
- Sample names and file paths
- Output directories
- Database locations
- Performance parameters

## Configuration

### Main Configuration Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `samples` | Dictionary of sample names and identifiers | `AFP2_C1_E_R_D01: "AFP2_C1_E_R_D01"` |
| `raw` | Path to raw sequencing data | `"../data/sfb_aq_s_21_MT_total_RNA"` |
| `results` | Output directory for results | `"sfb_aq_s_21_MT_total_RNA_results"` |
| `format` | File format (fastq/fasta) | `"fastq"` |
| `reads` | Read types | `["R1", "R2"]` |
| `threads` | Maximum threads per rule | `40` |
| `maxmem` | Maximum memory in MB | `500000` |
| `assembly` | Assembly method | `"SPADES"` or `"TRINITY"` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `NCBI` | NCBI database version | `"v5"` |
| `sortmerna` | SortMeRNA database version | `"v4.2.0"` |
| `jgi_config` | JGI download configuration | `"jgi_download.config"` |
| `KO_list_file` | KEGG KO genes list | `/mnt/biodiv/KEGG/kegg/genes/ko/ko_genes.list` |
| `KEGG_pathways` | KEGG pathways file | `/mnt/biodiv/KEGG/kegg/pathway/pathway.list` |

## Pipeline Components

### 1. Quality Control and Preprocessing
- **FastQC**: Quality assessment of raw reads
- **MultiQC**: Aggregated quality reports
- **Cutadapt**: Adapter removal and quality trimming

### 2. Read Filtering
- **SortMeRNA**: rRNA/mRNA separation
- **Bowtie2**: Plant read filtering (removes host contamination)

### 3. Assembly
- **Trinity**: De novo transcriptome assembly
- **SPAdes**: Alternative assembly method
- **Salmon**: Transcript quantification

### 4. Functional Annotation
- **Diamond**: Protein sequence alignment
- **UniProt**: Protein functional annotation
- **KEGG**: Pathway annotation

### 5. Taxonomic Analysis
- **JGI**: Taxonomic classification using JGI database
- **MEGAN6**: NCBI taxonomic analysis
- **Diamond**: Protein-based taxonomic assignment

## API Reference

### Core Snakemake Rules

#### Quality Control Rules

##### `fastqc`
Performs quality control analysis on raw sequencing reads.

**Input:**
- Raw FASTQ files: `{raw}/{sample}_{read}.fastq.gz`

**Output:**
- FastQC reports: `{results}/qc/fastqc/{sample}_{read}_fastqc.zip`
- HTML reports: `{results}/qc/fastqc/{sample}_{read}_fastqc.html`

**Parameters:**
- `outdir`: Output directory for FastQC reports
- `threads`: Number of threads to use

**Usage:**
```yaml
rule fastqc:
    input: expand("{raw}/{sample}_{read}.fastq.gz", ...)
    output: expand("{results}/qc/fastqc/{sample}_{read}_fastqc.zip", ...)
    conda: "../envs/preprocessing.yaml"
    threads: config["threads"]
```

##### `multiqc`
Aggregates FastQC reports into a single summary report.

**Input:**
- FastQC zip files: `{results}/qc/fastqc/{sample}_{read}_fastqc.zip`

**Output:**
- Aggregated report: `{results}/qc/multiqc_report.html`

##### `cutadapt`
Removes adapters and low-quality sequences from reads.

**Input:**
- Raw FASTQ files

**Output:**
- Cleaned FASTQ files: `{results}/qc/cleaned/{sample}_{read}.{format}.gz`

**Parameters:**
- `adapter`: Adapter sequence to remove
- `format`: File format (fastq/fasta)

#### Assembly Rules

##### `trinity_fastq_paired`
Performs de novo transcriptome assembly using Trinity.

**Input:**
- Cleaned paired-end reads: `{results}/unmapped/{sample}_{read}.fastq`

**Output:**
- Assembled transcriptome: `{results}/assembly/trinity_{sample}/Trinity.fasta`

**Parameters:**
- `memory`: Maximum memory allocation
- `outdir`: Output directory

**Resources:**
- `mem_mb`: Memory in MB

##### `abundance_paired`
Estimates transcript abundance using Salmon.

**Input:**
- Cleaned reads and assembly

**Output:**
- Quantification file: `{results}/assembly/quant_{sample}/quant.sf`

#### Annotation Rules

##### `diamond_uniprot`
Performs protein sequence alignment against UniProt database.

**Input:**
- Assembled transcripts

**Output:**
- Diamond alignment results: `{results}/diamond/{sample}_uniprot.csv`

##### `diamond_jgi`
Performs alignment against JGI protein database.

**Input:**
- Assembled transcripts

**Output:**
- JGI alignment results

### Python Scripts API

#### `jgi_download.py`
Downloads protein sequences and annotations from JGI database.

**Functions:**

##### `download_jgi_files(organism_id, file_types)`
Downloads specified file types for a given organism from JGI.

**Parameters:**
- `organism_id` (str): JGI organism identifier
- `file_types` (list): List of file types to download

**Returns:**
- Downloads files to `JGI_Database/{organism_id}/` directory

**Usage:**
```python
# Configure organism list in fungi_id_list.txt
# Configure file types in list_files_download.config
# Run script to download all specified files
```

#### `uniprot2koMapper.py`
Maps UniProt protein IDs to KEGG Orthology (KO) identifiers.

**Functions:**

##### `map_uniprot_to_ko(idmapping_file, ko_file, output_file)`
Creates mapping between UniProt and KEGG identifiers.

**Parameters:**
- `idmapping_file` (str): UniProt ID mapping file path
- `ko_file` (str): KEGG KO genes file path  
- `output_file` (str): Output mapping file path

**Returns:**
- Tab-separated mapping file with UniProt ID and KO mappings

**Usage:**
```python
# Used internally by Snakemake rules
# Input: UniProt idmapping.dat and KEGG ko_genes.list
# Output: uniprot2ko.tab mapping file
```

#### `cutadapt.py`
Wrapper script for adapter trimming using Cutadapt.

**Functions:**

##### `run_cutadapt(input_files, output_files, adapter, threads)`
Removes adapters and performs quality trimming.

**Parameters:**
- `input_files` (list): Input FASTQ files
- `output_files` (list): Output cleaned files
- `adapter` (str): Adapter sequence
- `threads` (int): Number of threads

**Quality Parameters:**
- Minimum quality score: 20
- Minimum read length: 50

#### `merge_anot_tpm.py`
Merges annotation and TPM (Transcripts Per Million) data.

**Functions:**

##### `merge_annotation_tpm(annotation_file, tpm_file, output_file)`
Combines functional annotation with expression quantification.

**Parameters:**
- `annotation_file` (str): Functional annotation file
- `tpm_file` (str): TPM quantification file
- `output_file` (str): Merged output file

### Configuration API

#### Sample Configuration
```yaml
samples:
  sample_name: "sample_identifier"
```

#### Path Configuration
```yaml
raw: "path/to/raw/data"           # Raw sequencing data
results: "path/to/results"        # Output directory
```

#### Performance Configuration
```yaml
threads: 40                       # Maximum threads per rule
maxmem: 500000                   # Maximum memory in MB
io: 5                            # I/O operation limit
```

#### Database Configuration
```yaml
jgi_config: "jgi_download.config"
jgi_organism_ids: "fungi_ids_list.txt"
KO_list_file: "/path/to/ko_genes.list"
KEGG_pathways: "/path/to/pathway.list"
```

## Usage Examples

### Example 1: Basic Pipeline Execution

```bash
# 1. Prepare configuration
cp config_aq_21_s.yaml my_config.yaml
# Edit my_config.yaml with your sample information

# 2. Run preprocessing and quality control
snakemake -s Snakefile.smk --configfile my_config.yaml -j 10 \
  results/qc/multiqc_report.html

# 3. Run full pipeline
snakemake -s Snakefile.smk --configfile my_config.yaml -j 50 --use-conda
```

### Example 2: Assembly Only

```bash
# Run only assembly steps
snakemake -s Snakefile.smk --configfile my_config.yaml -j 20 \
  results/assembly/trinity_sample1/Trinity.fasta \
  results/assembly/quant_sample1/quant.sf
```

### Example 3: Custom JGI Download

```bash
# 1. Prepare organism list
echo -e "organism_id\tdescription" > my_organisms.txt
echo -e "12345\tFungal_species_1" >> my_organisms.txt

# 2. Configure download types
echo "proteins.fasta,annotations.gff" > download_config.txt

# 3. Run JGI download
python scripts/jgi_download.py
```

### Example 4: Single Sample Analysis

```yaml
# minimal_config.yaml
samples:
  test_sample: "test_sample"
raw: "data/test"
results: "results/test"
format: "fastq"
reads: ["R1", "R2"]
threads: 8
maxmem: 32000
assembly: "TRINITY"
```

```bash
snakemake -s Snakefile.smk --configfile minimal_config.yaml -j 8 --use-conda
```

## Output Files

### Quality Control
- `{results}/qc/fastqc/`: FastQC reports for each sample
- `{results}/qc/multiqc_report.html`: Aggregated quality report
- `{results}/qc/cleaned/`: Adapter-trimmed reads

### Assembly
- `{results}/assembly/trinity_{sample}/Trinity.fasta`: Assembled transcriptome
- `{results}/assembly/quant_{sample}/quant.sf`: Transcript quantification

### Annotation
- `{results}/diamond/{sample}_uniprot.csv`: UniProt protein annotations
- `{results}/annotation/{sample}/jgi_tax_tpm_unip.txt`: Merged taxonomic and functional annotations
- `{results}/uniprot/{sample}_uniprot_ko.tab`: KEGG Orthology mappings

### Taxonomic Analysis
- `{results}/megan/{sample}_megan.daa`: MEGAN analysis files
- `{results}/megan/{sample}_taxinfo.txt`: Taxonomic information
- `{results}/annotation/{sample}/megan_tax_tpm_unip.txt`: Merged taxonomic data

### Filtering
- `{results}/unmapped/{sample}_{read}.fastq`: Plant-filtered reads
- `{results}/rrna/{sample}_{read}.fastq`: rRNA reads
- `{results}/mrna/{sample}_{read}.fastq`: mRNA reads

## Troubleshooting

### Common Issues

#### 1. Memory Errors
```bash
# Reduce memory usage in config
maxmem: 100000  # Reduce from 500000
threads: 20     # Reduce from 40
```

#### 2. Database Connection Issues
```bash
# Check JGI credentials in jgi_download.py
# Verify database paths in config file
# Ensure internet connectivity for downloads
```

#### 3. Assembly Failures
```bash
# Try alternative assembler
assembly: "SPADES"  # Instead of "TRINITY"

# Or reduce memory requirements
maxmem: 200000
```

#### 4. Missing Dependencies
```bash
# Recreate conda environment
conda env remove -n vasuki
conda env create -f metatrans.yaml
conda activate vasuki
```

### Log Files
- Assembly logs: `{results}/assembly/trinity_{sample}/Trinity.log`
- Quantification logs: `{results}/assembly/quant_{sample}/quant.log`
- Cutadapt logs: `{results}/qc/cleaned/{sample}.log`

### Performance Optimization

#### CPU Optimization
```yaml
threads: 40  # Adjust based on available cores
```

#### Memory Optimization
```yaml
maxmem: 500000  # Adjust based on available RAM
```

#### I/O Optimization
```yaml
io: 5  # Limit concurrent I/O operations
```

## Support

For issues and questions:
1. Check log files in the results directory
2. Verify configuration parameters
3. Ensure all databases are properly installed
4. Review the troubleshooting section above

## Citation

If you use Vasuki in your research, please cite:
[Citation information to be added]

## License

[License information to be added]