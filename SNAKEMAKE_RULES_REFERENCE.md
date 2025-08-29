# Snakemake Rules Reference - Vasuki Pipeline

This document provides comprehensive documentation for all Snakemake rules in the Vasuki metatranscriptomics pipeline.

## Table of Contents

- [Preprocessing Rules](#preprocessing-rules)
- [Filtering Rules](#filtering-rules)
- [Assembly Rules](#assembly-rules)
- [Annotation Rules](#annotation-rules)
- [Database Rules](#database-rules)
- [Merging and Analysis Rules](#merging-and-analysis-rules)

## Preprocessing Rules

### Quality Control Rules (`rules/preprocessing.smk`)

#### `fastqc`
Performs quality assessment of raw sequencing reads using FastQC.

**Purpose:** Generate quality control reports for raw FASTQ files to assess read quality, adapter content, and other sequencing metrics.

**Input:**
- `{raw}/{sample}_{read}.fastq.gz` - Raw paired-end FASTQ files

**Output:**
- `{results}/qc/fastqc/{sample}_{read}_fastqc.zip` - FastQC analysis archive
- `{results}/qc/fastqc/{sample}_{read}_fastqc.html` - FastQC HTML report

**Parameters:**
- `outdir`: Output directory for FastQC reports
- `threads`: Number of threads for parallel processing

**Conda Environment:** `../envs/preprocessing.yaml`

**Example Usage:**
```bash
# Generate FastQC reports for all samples
snakemake -s Snakefile.smk --configfile config.yaml \
  results/qc/fastqc/sample1_R1_fastqc.html \
  results/qc/fastqc/sample1_R2_fastqc.html
```

#### `multiqc`
Aggregates multiple FastQC reports into a single comprehensive report.

**Purpose:** Create a unified quality control report across all samples for easy comparison and assessment.

**Input:**
- `{results}/qc/fastqc/{sample}_{read}_fastqc.zip` - FastQC reports for all samples

**Output:**
- `{results}/qc/multiqc_report.html` - Aggregated quality report

**Parameters:**
- `indir`: Input directory containing FastQC reports
- `outdir`: Output directory for MultiQC report

**Conda Environment:** `../envs/preprocessing.yaml`

**Example Usage:**
```bash
# Generate aggregated quality report
snakemake -s Snakefile.smk --configfile config.yaml \
  results/qc/multiqc_report.html
```

#### `cutadapt`
Removes adapters and performs quality trimming on sequencing reads.

**Purpose:** Clean raw reads by removing adapter sequences and low-quality bases to improve downstream analysis quality.

**Input:**
- `{raw}/{sample}_{read}.{format}.gz` - Raw sequencing files

**Output:**
- `{results}/qc/cleaned/{sample}_{read}.{format}.gz` - Cleaned sequencing files (temporary)

**Log:**
- `{results}/qc/cleaned/{sample}.log` - Cutadapt processing log

**Parameters:**
- `adapter`: Adapter sequence to remove (from config)
- `format`: File format (fastq/fasta)
- `threads`: Number of threads for processing

**Quality Trimming Settings:**
- Minimum quality score: 20
- Minimum read length after trimming: 50bp

**Conda Environment:** `../envs/preprocessing.yaml`

**Script:** `../scripts/cutadapt.py`

**Example Usage:**
```bash
# Clean adapters from all samples
snakemake -s Snakefile.smk --configfile config.yaml \
  results/qc/cleaned/sample1_R1.fastq.gz \
  results/qc/cleaned/sample1_R2.fastq.gz
```

## Filtering Rules

### rRNA/mRNA Separation (`rules/sortmerna.smk`)

#### `sortmerna_paired`
Separates ribosomal RNA (rRNA) from messenger RNA (mRNA) in paired-end reads.

**Purpose:** Remove rRNA contamination to focus analysis on protein-coding mRNA transcripts.

**Input:**
- `{results}/qc/cleaned/{sample}_{read}.fastq.gz` - Cleaned paired-end reads

**Output:**
- `{results}/mrna/{sample}_{read}.fastq` - mRNA reads
- `{results}/rrna/{sample}_{read}.fastq` - rRNA reads

**Parameters:**
- Database references for rRNA detection
- Number of threads for parallel processing

**Conda Environment:** `../envs/sortmerna.yaml`

### Plant Read Filtering (`rules/filter_plant_reads.smk`)

#### `build_bowtie_index`
Builds Bowtie2 index for plant genome reference.

**Purpose:** Create index files for efficient alignment and removal of plant host reads.

**Input:**
- `database/alnus/alnus_genome.fna` - Plant reference genome

**Output:**
- `database/alnus/alnus_index.{n}.bt2` - Bowtie2 index files

**Conda Environment:** `../envs/bowtie.yml`

#### `filter_plant_reads`
Removes plant host reads from the dataset using Bowtie2 alignment.

**Purpose:** Filter out host contamination to focus on microbial transcripts.

**Input:**
- `{results}/qc/cleaned/{sample}_{read}.fastq.gz` - Cleaned reads
- Bowtie2 index files

**Output:**
- `{results}/unmapped/{sample}.sam` - Alignment file
- `{results}/unmapped/{sample}_{read}.fastq` - Filtered reads (host-free)

**Parameters:**
- Bowtie2 alignment parameters
- Number of threads

**Conda Environment:** `../envs/bowtie.yml`

## Assembly Rules

### Trinity Assembly (`rules/assembly.smk`)

#### `trinity_fastq_paired`
Performs de novo transcriptome assembly using Trinity assembler.

**Purpose:** Reconstruct full-length transcripts from short sequencing reads without a reference genome.

**Input:**
- `{results}/unmapped/{sample}_{read}.fastq` - Host-filtered paired-end reads

**Output:**
- `{results}/assembly/trinity_{sample}/Trinity.fasta` - Assembled transcriptome

**Parameters:**
- `memory`: Maximum memory allocation (calculated from config)
- `outdir`: Output directory for assembly
- `threads`: Number of CPU threads

**Resources:**
- `mem_mb`: Memory limit in megabytes

**Log:** `{results}/assembly/trinity_{sample}/Trinity.log`

**Conda Environment:** `../envs/assembly.yaml`

**Command Details:**
- Uses Trinity with default parameters
- Salmon quantification disabled (`--no_salmon`)
- Supports both single-end and paired-end data

**Example Usage:**
```bash
# Assemble transcriptome for sample1
snakemake -s Snakefile.smk --configfile config.yaml \
  results/assembly/trinity_sample1/Trinity.fasta
```

#### `abundance_paired`
Estimates transcript abundance using Salmon quantification.

**Purpose:** Quantify transcript expression levels (TPM - Transcripts Per Million) for assembled transcripts.

**Input:**
- `{results}/unmapped/{sample}_{read}.fastq` - Filtered reads
- `{results}/assembly/trinity_{sample}/Trinity.fasta` - Assembled transcriptome

**Output:**
- `{results}/assembly/quant_{sample}/quant.sf` - Transcript quantification file

**Parameters:**
- `outdir`: Output directory for quantification
- `threads`: Number of threads

**Log:** `{results}/assembly/quant_{sample}/quant.log`

**Conda Environment:** `../envs/assembly.yaml`

**Method:** Uses Trinity's `align_and_estimate_abundance.pl` script with Salmon

### SPAdes Assembly (`rules/assembly_spades.smk`)

#### `spades_assembly`
Alternative assembly method using SPAdes assembler.

**Purpose:** Provide an alternative to Trinity for transcriptome assembly, particularly useful for certain data types.

**Input:**
- Filtered paired-end reads

**Output:**
- `{results}/assembly/spades_{sample}/transcripts.fasta` - SPAdes assembly

**Parameters:**
- `memory`: Memory limit
- `threads`: CPU threads
- `outdir`: Output directory

**Conda Environment:** `../envs/assemblyspades.yaml`

## Annotation Rules

### Protein Database Searches

#### `diamond_uniprot` (`rules/uniprot.smk`)
Performs protein sequence alignment against UniProt database using Diamond.

**Purpose:** Annotate assembled transcripts with protein function information from UniProt database.

**Input:**
- `{results}/assembly/trinity_{sample}/Trinity.fasta` - Assembled transcriptome

**Output:**
- `{results}/diamond/{sample}_uniprot.csv` - Diamond alignment results

**Parameters:**
- Database path: UniProt protein database
- E-value threshold: 1e-5
- Number of threads
- Output format: tabular

**Conda Environment:** `../envs/diamond.yaml`

**Example Usage:**
```bash
# Annotate transcripts with UniProt
snakemake -s Snakefile.smk --configfile config.yaml \
  results/diamond/sample1_uniprot.csv
```

#### `diamond_jgi_search` (`rules/diamond_jgi_search.smk`)
Searches assembled transcripts against JGI protein database.

**Purpose:** Annotate transcripts using JGI (Joint Genome Institute) protein sequences for taxonomic and functional classification.

**Input:**
- Assembled transcriptome
- JGI protein database

**Output:**
- `{results}/annotation/{sample}/{sample}_jgi_tax.tsv` - JGI taxonomic annotations

**Parameters:**
- Diamond alignment parameters
- E-value threshold
- Output format

**Conda Environment:** `../envs/diamond.yaml`

### MEGAN Taxonomic Analysis (`rules/megan_taxonomy_prok.smk`)

#### `megan_analysis`
Performs taxonomic classification using MEGAN6 software.

**Purpose:** Assign taxonomic classifications to assembled transcripts using NCBI taxonomy.

**Input:**
- Diamond alignment results against NCBI database

**Output:**
- `{results}/megan/{sample}_megan.daa` - MEGAN analysis file
- `{results}/megan/{sample}_taxinfo.txt` - Taxonomic classification

**Parameters:**
- MEGAN database files
- Taxonomy assignment parameters

**Requirements:**
- MEGAN6 software installation
- NCBI taxonomy database

## Database Rules

### Database Preparation

#### `create_diamond_db` (`rules/index_ncbi_diamond.smk`)
Creates Diamond database from protein sequences.

**Purpose:** Build searchable Diamond database from NCBI or other protein sequence collections.

**Input:**
- Protein FASTA files

**Output:**
- Diamond database files (`.dmnd`)

**Parameters:**
- Database name
- Input protein sequences

**Conda Environment:** `../envs/diamond.yaml`

#### `download_jgi_database` (`rules/JGI_download.smk`)
Downloads protein sequences and annotations from JGI database.

**Purpose:** Retrieve organism-specific protein sequences and functional annotations from JGI portal.

**Input:**
- `jgi_download.config` - JGI download configuration
- `fungi_ids_list.txt` - List of organism IDs

**Output:**
- Downloaded JGI files in `JGI_Database/` directory

**Script:** `../scripts/jgi_download.py`

**Configuration Requirements:**
- JGI portal credentials
- List of target organisms
- File types to download

### KEGG Database Preparation (`rules/create_kegg_mapping.smk`)

#### `create_kegg_pathways`
Creates KEGG pathway mapping files.

**Purpose:** Generate mapping between KEGG orthology (KO) identifiers and metabolic pathways.

**Input:**
- KEGG database files
- KO genes list

**Output:**
- `database/bac_nr_ncbi/ko2pathway.txt` - KO to pathway mapping

**Parameters:**
- KEGG database location
- Output format

#### `create_uniprot_ko_mapping` (`rules/create_uniprot_db.smk`)
Maps UniProt protein IDs to KEGG orthology identifiers.

**Purpose:** Create cross-reference between UniProt proteins and KEGG functional classifications.

**Input:**
- UniProt ID mapping file
- KEGG KO genes list

**Output:**
- `database/bac_nr_ncbi/uniprot2ko.txt` - UniProt to KO mapping
- `database/bac_nr_ncbi/uniprot2kegg.txt` - UniProt to KEGG mapping

**Script:** `../scripts/uniprot2koMapper.py`

## Merging and Analysis Rules

### Data Integration

#### `merge_jgi_tpm` (`rules/jgi_tpm_merge.smk`)
Merges JGI annotations with transcript abundance data.

**Purpose:** Combine functional annotations from JGI with expression quantification (TPM values).

**Input:**
- JGI annotation results
- Transcript quantification data

**Output:**
- `{results}/annotation/{sample}/jgi_tpm_tax.txt` - Merged JGI annotations with TPM

**Script:** `../scripts/merge_anot_tpm_jgi.py`

#### `merge_megan_tpm` (`rules/megan_tpm_merge.smk`)
Integrates MEGAN taxonomic classifications with expression data.

**Purpose:** Combine taxonomic assignments with transcript abundance for community analysis.

**Input:**
- MEGAN taxonomic results
- TPM quantification data

**Output:**
- `{results}/annotation/{sample}/megan_tax_tpm_unip.txt` - Merged taxonomic and expression data

**Script:** `../scripts/merge_anot_tpm.py`

#### `merge_uniprot_annotations`
Combines UniProt functional annotations with expression data.

**Purpose:** Integrate protein function annotations with transcript expression levels.

**Input:**
- UniProt annotation results
- TPM data
- KEGG mappings

**Output:**
- `{results}/annotation/{sample}/jgi_tax_tpm_unip.txt` - Complete functional and taxonomic annotation

### Abundance Editing (`rules/edit_abundance.smk`)

#### `edit_abundance_tpm`
Modifies abundance estimates for downstream analysis.

**Purpose:** Format and normalize TPM values for compatibility with analysis tools.

**Input:**
- `{results}/assembly/quant_{sample}/quant.sf` - Raw quantification

**Output:**
- `{results}/assembly/quant_{sample}/quant_edit.sf` - Formatted quantification

**Script:** `../scripts/edit_abundance_tpm.smk`

## Rule Dependencies and Workflow

### Processing Order

1. **Quality Control:** `fastqc` → `multiqc` → `cutadapt`
2. **Filtering:** `sortmerna` → `filter_plant_reads`
3. **Assembly:** `trinity_fastq_paired` → `abundance_paired`
4. **Annotation:** `diamond_uniprot`, `diamond_jgi_search`, `megan_analysis`
5. **Integration:** `merge_jgi_tpm`, `merge_megan_tpm`, `merge_uniprot_annotations`

### Resource Requirements

| Rule Category | Typical Memory | Typical Threads | Runtime |
|---------------|----------------|-----------------|---------|
| Quality Control | 4-8 GB | 4-8 | 30-60 min |
| Filtering | 8-16 GB | 8-16 | 1-3 hours |
| Assembly | 100-500 GB | 20-40 | 4-24 hours |
| Annotation | 16-64 GB | 8-20 | 2-8 hours |
| Merging | 2-8 GB | 1-4 | 10-30 min |

### Performance Optimization

#### Memory Management
```yaml
# Adjust memory limits based on available resources
maxmem: 500000  # 500 GB for large assemblies
maxmem: 100000  # 100 GB for smaller datasets
```

#### Thread Allocation
```yaml
# Balance thread usage across rules
threads: 40  # For compute-intensive steps
threads: 8   # For I/O intensive steps
```

#### Temporary Files
Many rules use `temp()` outputs to save disk space:
- Cleaned reads after filtering
- Intermediate assembly files
- Temporary annotation files

### Error Handling

#### Common Rule Failures

1. **Memory Errors:**
   - Reduce `maxmem` parameter
   - Use SPAdes instead of Trinity
   - Process samples individually

2. **Database Errors:**
   - Verify database file paths
   - Check database format compatibility
   - Ensure sufficient disk space

3. **Network Errors (JGI download):**
   - Verify internet connectivity
   - Check JGI portal credentials
   - Retry failed downloads

#### Debugging Tips

1. **Check log files:**
   ```bash
   # View detailed logs for specific rules
   cat results/assembly/trinity_sample1/Trinity.log
   cat results/qc/cleaned/sample1.log
   ```

2. **Run specific rules:**
   ```bash
   # Test individual rules
   snakemake -s Snakefile.smk --configfile config.yaml -n \
     results/assembly/trinity_sample1/Trinity.fasta
   ```

3. **Validate configuration:**
   ```bash
   # Check config file syntax
   snakemake -s Snakefile.smk --configfile config.yaml --validate
   ```

This comprehensive reference covers all major Snakemake rules in the Vasuki pipeline. Each rule is documented with its purpose, inputs, outputs, parameters, and usage examples to facilitate understanding and troubleshooting.