# Complete API Reference - Vasuki Pipeline

This document provides a comprehensive API reference for all public functions, components, and interfaces in the Vasuki metatranscriptomics pipeline.

## Table of Contents

- [Pipeline Overview](#pipeline-overview)
- [Core API Components](#core-api-components)
- [Snakemake Rules API](#snakemake-rules-api)
- [Python Scripts API](#python-scripts-api)
- [Configuration API](#configuration-api)
- [File Format Specifications](#file-format-specifications)
- [Command Line Interface](#command-line-interface)
- [Integration Examples](#integration-examples)

## Pipeline Overview

### Architecture

The Vasuki pipeline follows a modular architecture with the following key components:

```
Vasuki Pipeline
├── Core Workflow (Snakefile.smk)
├── Rules Modules (rules/*.smk)
├── Processing Scripts (scripts/*.py)
├── Environment Definitions (envs/*.yaml)
├── Configuration Files (*.yaml)
└── Database Components (database/)
```

### Data Flow

```
Raw Reads → QC → Filtering → Assembly → Annotation → Analysis
     ↓        ↓       ↓         ↓          ↓         ↓
   FastQC  Cutadapt  SortMeRNA  Trinity   Diamond   Merge
```

## Core API Components

### Main Workflow Entry Point

#### `Snakefile.smk`

The main workflow coordinator that orchestrates all analysis steps.

**Global Variables:**
- `config`: Configuration dictionary loaded from YAML
- `samples`: Sample names from configuration
- `results`: Output directory path

**Key Functions:**

##### `rule all`
Master rule that defines all final outputs.

```python
rule all:
    input:
        # Quality control outputs
        expand("{results}/qc/multiqc_report.html", results=config["results"]),
        # Assembly outputs
        expand("{results}/assembly/trinity_{sample}/Trinity.fasta", 
               results=config["results"], sample=config["samples"]),
        # Annotation outputs
        expand("{results}/annotation/{sample}/jgi_tax_tpm_unip.txt",
               results=config["results"], sample=config["samples"])
```

**Input Parameters:**
- Configuration file (--configfile)
- Number of cores (-j)
- Conda environment usage (--use-conda)

**Output:**
- Complete analysis results in specified results directory

### Workflow Control Functions

#### `wildcard_constraints`
Defines pattern constraints for Snakemake wildcards.

```python
wildcard_constraints:
    read = "R\d",  # Matches R1, R2, etc.
    sample = "[A-Za-z0-9_-]+",  # Alphanumeric sample names
```

## Snakemake Rules API

### Quality Control Rules

#### `fastqc`
Performs quality assessment of raw sequencing reads.

**Interface:**
```python
rule fastqc:
    input: expand("{raw}/{sample}_{read}.fastq.gz", ...)
    output: expand("{results}/qc/fastqc/{sample}_{read}_fastqc.zip", ...)
    params:
        outdir: str  # Output directory path
    threads: int     # Number of threads
    conda: str       # Environment file path
```

**Function Signature:**
```python
def fastqc(input_files: List[str], 
          output_dir: str, 
          threads: int = 1) -> List[str]
```

#### `multiqc`
Aggregates multiple quality control reports.

**Interface:**
```python
rule multiqc:
    input: List[str]     # FastQC report files
    output: str          # Aggregated HTML report
    params:
        indir: str       # Input directory
        outdir: str      # Output directory
    threads: int = 1
```

#### `cutadapt`
Removes adapters and performs quality trimming.

**Interface:**
```python
rule cutadapt:
    input: List[str]     # Raw FASTQ files
    output: List[str]    # Cleaned FASTQ files
    log: str            # Log file path
    params:
        adapter: str     # Adapter sequence
        format: str      # File format
    threads: int
    script: str         # Python script path
```

### Assembly Rules

#### `trinity_fastq_paired`
Performs de novo transcriptome assembly using Trinity.

**Interface:**
```python
rule trinity_fastq_paired:
    input:
        reads: List[str]  # Paired-end FASTQ files
    output: str          # Assembly FASTA file
    params:
        memory: str      # Memory allocation
        outdir: str      # Output directory
    resources:
        mem_mb: int      # Memory in MB
    threads: int
    log: str
```

**Function Signature:**
```python
def trinity_assembly(input_reads: List[str],
                     output_dir: str,
                     max_memory: str,
                     threads: int,
                     seqtype: str = "fq") -> str
```

#### `abundance_paired`
Estimates transcript abundance using Salmon.

**Interface:**
```python
rule abundance_paired:
    input:
        reads: List[str]     # Input reads
        assembly: str        # Assembly file
    output: str             # Quantification file
    params:
        outdir: str         # Output directory
    threads: int
    log: str
```

### Annotation Rules

#### `diamond_uniprot`
Performs protein sequence alignment against UniProt database.

**Interface:**
```python
rule diamond_uniprot:
    input: str              # Assembly FASTA
    output: str             # Alignment results
    params:
        database: str       # Database path
        evalue: float       # E-value threshold
        format: int         # Output format
    threads: int
    conda: str
```

**Function Signature:**
```python
def diamond_search(query_file: str,
                  database: str,
                  output_file: str,
                  evalue: float = 1e-5,
                  max_targets: int = 10,
                  threads: int = 1) -> str
```

## Python Scripts API

### Data Download Scripts

#### `jgi_download.py`

**Class Definition:**
```python
class JGIDownloader:
    def __init__(self, username: str, password: str):
        self.session = requests.Session()
        self.login_credentials = {
            'login': username,
            'password': password
        }
```

**Methods:**

##### `authenticate()`
Authenticates with JGI portal.

```python
def authenticate(self) -> bool:
    """
    Authenticate with JGI portal.
    
    Returns:
        bool: True if authentication successful
    
    Raises:
        ConnectionError: If authentication fails
    """
```

##### `download_organism_files(organism_id, file_types)`
Downloads files for specified organism.

```python
def download_organism_files(self, 
                          organism_id: str, 
                          file_types: List[str],
                          output_dir: str = "JGI_Database") -> Dict[str, str]:
    """
    Download files for a specific organism.
    
    Args:
        organism_id: JGI organism identifier
        file_types: List of file types to download
        output_dir: Base output directory
    
    Returns:
        dict: Mapping of file types to downloaded file paths
    
    Raises:
        ValueError: If organism_id is invalid
        IOError: If download fails
    """
```

### Data Processing Scripts

#### `cutadapt.py`

**Function Definition:**
```python
def run_cutadapt(input_files: List[str],
                output_files: List[str],
                adapter: str,
                quality_threshold: int = 20,
                min_length: int = 50,
                threads: int = 1,
                log_file: str = None) -> subprocess.CompletedProcess:
    """
    Execute Cutadapt for adapter removal and quality trimming.
    
    Args:
        input_files: List of input FASTQ files
        output_files: List of output file paths
        adapter: Adapter sequence to remove
        quality_threshold: Minimum quality score
        min_length: Minimum read length after trimming
        threads: Number of threads to use
        log_file: Optional log file path
    
    Returns:
        subprocess.CompletedProcess: Process result
    
    Raises:
        subprocess.CalledProcessError: If cutadapt fails
    """
```

#### `uniprot2koMapper.py`

**Class Definition:**
```python
class UniProtKOMapper:
    def __init__(self, idmapping_file: str, ko_file: str):
        self.idmapping_file = idmapping_file
        self.ko_file = ko_file
        self.mapping_data = {}
```

**Methods:**

##### `create_mapping()`
Creates UniProt to KO mapping.

```python
def create_mapping(self, output_file: str) -> pd.DataFrame:
    """
    Create comprehensive UniProt to KO mapping.
    
    Args:
        output_file: Path for output mapping file
    
    Returns:
        pd.DataFrame: Mapping dataframe
    
    Raises:
        FileNotFoundError: If input files not found
        ValueError: If mapping data is invalid
    """
```

##### `load_uniprot_kegg_mapping()`
Loads UniProt-KEGG cross-references.

```python
def load_uniprot_kegg_mapping(self) -> pd.DataFrame:
    """
    Load UniProt to KEGG gene mappings.
    
    Returns:
        pd.DataFrame: UniProt-KEGG mappings
    """
```

### Annotation Merge Scripts

#### `merge_anot_tpm.py`

**Function Definition:**
```python
def merge_annotation_tpm(taxonomy_file: str,
                        tpm_file: str,
                        output_file: str,
                        join_type: str = "left") -> pd.DataFrame:
    """
    Merge taxonomic annotations with TPM quantification data.
    
    Args:
        taxonomy_file: Path to taxonomy annotation file
        tpm_file: Path to TPM quantification file
        output_file: Path for merged output file
        join_type: Type of pandas join operation
    
    Returns:
        pd.DataFrame: Merged annotation and TPM data
    
    Raises:
        FileNotFoundError: If input files don't exist
        ValueError: If file formats are incompatible
    """
```

## Configuration API

### Configuration Schema

#### Main Configuration Object

```python
class PipelineConfig:
    """Main configuration class for Vasuki pipeline."""
    
    def __init__(self, config_file: str):
        self.config_data = self._load_config(config_file)
    
    @property
    def samples(self) -> Dict[str, str]:
        """Sample name to identifier mapping."""
        return self.config_data.get('samples', {})
    
    @property
    def raw_data_path(self) -> str:
        """Path to raw sequencing data."""
        return self.config_data.get('raw', '')
    
    @property
    def results_path(self) -> str:
        """Path to results directory."""
        return self.config_data.get('results', 'results')
    
    @property
    def file_format(self) -> str:
        """Sequencing file format (fastq/fasta)."""
        return self.config_data.get('format', 'fastq')
    
    @property
    def read_types(self) -> List[str]:
        """Read types (R1, R2 for paired-end)."""
        return self.config_data.get('reads', ['R1', 'R2'])
    
    @property
    def performance_settings(self) -> Dict[str, int]:
        """Performance configuration settings."""
        return {
            'threads': self.config_data.get('threads', 1),
            'maxmem': self.config_data.get('maxmem', 8000),
            'io': self.config_data.get('io', 1)
        }
```

#### Configuration Validation

```python
def validate_config(config: Dict[str, Any]) -> List[str]:
    """
    Validate pipeline configuration.
    
    Args:
        config: Configuration dictionary
    
    Returns:
        list: List of validation errors (empty if valid)
    """
    errors = []
    
    # Required fields
    required_fields = ['samples', 'raw', 'results', 'format', 'reads']
    for field in required_fields:
        if field not in config:
            errors.append(f"Missing required field: {field}")
    
    # Validate sample format
    if 'samples' in config:
        if not isinstance(config['samples'], dict):
            errors.append("'samples' must be a dictionary")
        elif len(config['samples']) == 0:
            errors.append("At least one sample must be specified")
    
    # Validate file format
    if 'format' in config:
        if config['format'] not in ['fastq', 'fasta']:
            errors.append("'format' must be 'fastq' or 'fasta'")
    
    return errors
```

## File Format Specifications

### Input File Formats

#### Raw Sequencing Data

**FASTQ Format:**
```
@sequence_identifier
GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
```

**Naming Convention:**
```
{sample}_{read}.fastq.gz
# Examples:
# sample1_R1.fastq.gz
# sample1_R2.fastq.gz
```

#### Configuration Files

**YAML Configuration:**
```yaml
# Sample configuration
samples:
  sample_name: "sample_identifier"

# Path configuration
raw: "path/to/raw/data"
results: "path/to/results"

# Processing parameters
threads: 16
maxmem: 128000
```

### Output File Formats

#### Quality Control Reports

**FastQC Output:**
- `{sample}_{read}_fastqc.html`: HTML quality report
- `{sample}_{read}_fastqc.zip`: Complete analysis archive

**MultiQC Output:**
- `multiqc_report.html`: Aggregated quality report
- `multiqc_data/`: Supporting data files

#### Assembly Files

**Trinity Assembly:**
```
>TRINITY_DN0_c0_g1_i1 len=247 path=[0:0-246]
GATCGGAAGAGCACACGTCTGAACTCCAGTCACATCACGATCTCGTATGCCGTCTTCTGCTT
```

**Quantification Files:**
```
Name	Length	EffectiveLength	TPM	NumReads
TRINITY_DN0_c0_g1_i1	247	97.5	10.5	2.0
```

#### Annotation Files

**Diamond Output:**
```
query_id	subject_id	%_identity	align_length	mismatches	gap_opens	q_start	q_end	s_start	s_end	evalue	bit_score
```

**Merged Annotation:**
```
Name	TPM	EffectiveLength	Length	NumReads	Taxonomy	Function	KO_ID
```

## Command Line Interface

### Primary Commands

#### Basic Execution

```bash
snakemake -s Snakefile.smk \
  --configfile config.yaml \
  --use-conda \
  -j 16
```

**Parameters:**
- `-s, --snakefile`: Snakefile path
- `--configfile`: Configuration file path
- `--use-conda`: Enable conda environments
- `-j, --cores`: Number of cores

#### Advanced Options

```bash
snakemake -s Snakefile.smk \
  --configfile config.yaml \
  --use-conda \
  -j 16 \
  --rerun-incomplete \
  --keep-going \
  --printshellcmds \
  --resources mem_mb=100000
```

**Additional Parameters:**
- `--rerun-incomplete`: Rerun incomplete jobs
- `--keep-going`: Continue on error
- `--printshellcmds`: Show shell commands
- `--resources`: Resource constraints

#### Specific Target Execution

```bash
# Run only quality control
snakemake -s Snakefile.smk --configfile config.yaml \
  results/qc/multiqc_report.html

# Run only assembly
snakemake -s Snakefile.smk --configfile config.yaml \
  results/assembly/trinity_sample1/Trinity.fasta

# Run specific annotation
snakemake -s Snakefile.smk --configfile config.yaml \
  results/annotation/sample1/jgi_tax_tpm_unip.txt
```

### Pipeline Utility Commands

#### Workflow Visualization

```bash
# Generate workflow diagram
snakemake -s Snakefile.smk --configfile config.yaml \
  --dag | dot -Tpng > workflow.png

# Generate rule graph
snakemake -s Snakefile.smk --configfile config.yaml \
  --rulegraph | dot -Tpng > rules.png
```

#### Dry Run and Validation

```bash
# Dry run (show what would be executed)
snakemake -s Snakefile.smk --configfile config.yaml --dry-run

# Validate workflow
snakemake -s Snakefile.smk --configfile config.yaml --validate

# Show planned jobs
snakemake -s Snakefile.smk --configfile config.yaml --summary
```

## Integration Examples

### Custom Rule Integration

#### Adding Custom Annotation

```python
# custom_rules.smk
rule custom_annotation:
    input:
        assembly="{results}/assembly/trinity_{sample}/Trinity.fasta"
    output:
        annotation="{results}/custom/{sample}_custom.tsv"
    params:
        database="custom_db/proteins.dmnd",
        evalue=1e-5
    threads: 8
    conda:
        "../envs/diamond.yaml"
    shell:
        """
        diamond blastx -d {params.database} \
            -q {input.assembly} \
            -o {output.annotation} \
            --evalue {params.evalue} \
            --threads {threads}
        """

# Include in main Snakefile
include: "rules/custom_rules.smk"
```

#### Custom Python Script Integration

```python
# custom_script.py
import pandas as pd

def process_custom_data(input_file, output_file, threshold=0.01):
    """Process custom annotation data."""
    df = pd.read_csv(input_file, sep='\t')
    filtered_df = df[df['evalue'] < threshold]
    filtered_df.to_csv(output_file, sep='\t', index=False)
    return len(filtered_df)

# Snakemake integration
rule process_custom:
    input: "{results}/custom/{sample}_custom.tsv"
    output: "{results}/processed/{sample}_processed.tsv"
    script: "../scripts/custom_script.py"
```

### External Tool Integration

#### Adding New Assembly Tool

```python
# rules/megahit_assembly.smk
rule megahit_assembly:
    input:
        r1="{results}/unmapped/{sample}_R1.fastq",
        r2="{results}/unmapped/{sample}_R2.fastq"
    output:
        "{results}/assembly/megahit_{sample}/final.contigs.fa"
    params:
        outdir="{results}/assembly/megahit_{sample}",
        min_contig_len=200
    threads: 16
    conda:
        "../envs/megahit.yaml"
    shell:
        """
        megahit -1 {input.r1} -2 {input.r2} \
            -o {params.outdir} \
            --min-contig-len {params.min_contig_len} \
            --num-cpu-threads {threads}
        """
```

### Configuration Extension

#### Custom Configuration Schema

```python
# config_extensions.py
class ExtendedConfig(PipelineConfig):
    """Extended configuration with custom parameters."""
    
    @property
    def custom_databases(self) -> Dict[str, str]:
        """Custom database paths."""
        return self.config_data.get('custom_databases', {})
    
    @property
    def analysis_parameters(self) -> Dict[str, Any]:
        """Custom analysis parameters."""
        return self.config_data.get('analysis_params', {})
    
    def validate_custom_config(self) -> List[str]:
        """Validate custom configuration parameters."""
        errors = super().validate_config(self.config_data)
        
        # Add custom validation
        if 'custom_databases' in self.config_data:
            for db_name, db_path in self.custom_databases.items():
                if not os.path.exists(db_path):
                    errors.append(f"Custom database not found: {db_path}")
        
        return errors
```

This complete API reference provides developers and advanced users with detailed information for extending, customizing, and integrating the Vasuki pipeline into larger bioinformatics workflows.