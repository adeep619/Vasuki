 # Vasuki - Metatranscriptomic Analysis Pipeline

Vasuki is a comprehensive Snakemake-based pipeline for metatranscriptomic analysis, designed to process RNA-seq data from environmental samples with a focus on bacterial and fungal annotation.

## Features

- **Quality Control**: FastQC analysis and read trimming with Cutadapt
- **Plant Read Filtering**: Remove host plant reads using Bowtie2
- **Assembly**: Trinity or SPAdes assembly options
- **Quantification**: Salmon-based transcript abundance estimation
- **Functional Annotation**: 
  - DIAMOND search against UniProt, JGI, and NCBI databases
  - KEGG pathway annotation
  - CAZy (Carbohydrate-Active enzymes) annotation
- **Taxonomic Classification**: MEGAN-based taxonomic assignment
- **Results Integration**: Automated merging of annotation and abundance data

## Installation

### Prerequisites
- Conda/Mamba package manager
- Snakemake workflow management system
- MEGAN software (for taxonomic analysis)

### Environment Setup
Create the Vasuki environment using the provided environment file:

```bash
conda create --name vasuki --file metatrans.yaml
conda activate vasuki
```

### Database Requirements
This pipeline requires several databases in a `database/` folder:

#### Required Database Files:
- **JGI Database**: Fungal protein sequences from Joint Genome Institute
- **UniProt Database**: For protein functional annotation
- **NCBI Database**: For bacterial annotation (if using MEGAN)
- **CAZy Database**: `dbcan cazy.fa` for carbohydrate-active enzyme annotation
- **KEGG Database**: For pathway annotation
- **Plant Reference**: For host read removal (e.g., Alnus genome)

See `database/files.txt` for a complete list of required database files.

## Quick Start

1. **Prepare your configuration file**: Copy and modify one of the example config files:
   ```bash
   cp config_test.yaml my_config.yaml
   ```

2. **Edit the configuration**: Modify sample names, paths, and parameters in `my_config.yaml`

3. **Run the pipeline**:
   ```bash
   snakemake -j 50 -s Snakefile.smk --use-conda --configfile my_config.yaml -k --debug -npr
   ```

## Configuration

### Sample Configuration
```yaml
samples:
    sample1: "sample1"
    sample2: "sample2"

raw: "path/to/raw/data"
results: "results_folder"
format: "fastq"
reads: ["R1", "R2"]
```

### Performance Parameters
```yaml
threads: 40        # Maximum threads per rule
maxmem: 500000     # Maximum memory in MB
io: 5              # I/O restrictions
```

### Assembly Options
```yaml
assembly: "SPADES"  # or "TRINITY"
```

### Analysis Toggles
```yaml
fastqc: true       # Run FastQC quality control
KEGG: true         # Enable KEGG annotation
megan: true        # Enable MEGAN taxonomic analysis
```

## Pipeline Workflow

1. **Quality Control** (`rules/qc.smk`)
   - FastQC analysis of raw reads
   - Read trimming with Cutadapt

2. **Host Filtering** (`rules/filter_plant_reads.smk`)
   - Build Bowtie2 index for plant genome
   - Remove plant/host reads

3. **Assembly** (`rules/assembly.smk` or `rules/assembly_spades.smk`)
   - Trinity or SPAdes assembly of filtered reads
   - Quality assessment of assemblies

4. **Quantification** (`rules/edit_abundance.smk`)
   - Salmon quantification of transcript abundance
   - TPM (Transcripts Per Million) calculation

5. **Functional Annotation**
   - **UniProt** (`rules/uniprot.smk`): Protein function and KEGG orthology
   - **JGI** (`rules/diamond_jgi_search.smk`): Fungal protein annotation
   - **NCBI** (`rules/diamond_ncbi_search.smk`): Bacterial protein annotation
   - **CAZy** (`rules/diamond_cazy.smk`): Carbohydrate-active enzymes

6. **Taxonomic Analysis** (`rules/megan_taxonomy_prok.smk`)
   - MEGAN-based taxonomic assignment
   - Integration with abundance data

7. **Results Integration**
   - Merge annotation results with abundance data
   - Generate comprehensive output tables

## Output Structure

```
results/
├── qc/                    # Quality control reports
├── unmapped/              # Host-filtered reads
├── assembly/              # Assembly results and quantification
├── diamond/               # DIAMOND search results
├── bac_diamond/           # Bacterial annotation results
├── uniprot/               # UniProt annotation and KEGG mapping
├── megan/                 # MEGAN taxonomic analysis
└── anotation/             # Integrated annotation results
    └── {sample}/
        ├── jgi_tax_tpm_unip.txt           # Combined JGI, taxonomy, and UniProt
        ├── megan_tpm_tax.txt              # MEGAN taxonomy with abundance
        └── megan_tax_tpm_unip.txt         # Complete integrated results
```

## Post-Processing

Use the provided Python script for additional result merging:

```bash
python bash_pipeline_merge_anot.py
```

This script:
- Filters and processes DIAMOND results
- Merges KEGG orthology annotations
- Integrates taxonomic and functional data
- Generates final analysis tables

## Change Log

### Version 2023-07-06
- Added GPU and CPU mode support
- DIAMOND search with CAZy database
- Bacterial DIAMOND with MEGAN or NCBI nr
- Script to merge KO, Taxa and pathways
- Improved result integration pipeline

## Troubleshooting

### Common Issues

1. **Memory Issues**: Increase `maxmem` parameter for large datasets
2. **Database Errors**: Ensure all required databases are properly indexed
3. **MEGAN Errors**: Verify MEGAN installation and license
4. **Assembly Failures**: Check read quality and consider different assemblers

### Support

For issues and questions, please check:
- Configuration file format
- Database file requirements
- Snakemake documentation
- Individual tool documentation

## Citation

If you use Vasuki in your research, please cite the relevant tools and databases used in your analysis. 
