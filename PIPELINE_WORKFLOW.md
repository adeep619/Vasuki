# Vasuki Pipeline Workflow Documentation

This document provides a detailed overview of the Vasuki metatranscriptomic analysis pipeline workflow, including all steps, rules, and data flow.

## Pipeline Overview

Vasuki is a Snakemake-based pipeline that processes paired-end RNA-seq data through multiple stages of quality control, assembly, annotation, and integration. The pipeline is designed for environmental metatranscriptomic samples with mixed bacterial and fungal communities.

## Workflow Diagram

```
Raw Reads (FASTQ)
        ↓
   Quality Control (FastQC)
        ↓
   Adapter Trimming (Cutadapt)
        ↓
   Host Read Removal (Bowtie2)
        ↓
   Assembly (Trinity/SPAdes)
        ↓
   Quantification (Salmon)
        ↓
   ┌─────────────────────┬─────────────────────┬─────────────────────┐
   ↓                     ↓                     ↓                     ↓
UniProt Search       JGI Search          NCBI Search          CAZy Search
(DIAMOND)            (DIAMOND)           (DIAMOND)            (DIAMOND)
   ↓                     ↓                     ↓                     ↓
KEGG Mapping         Taxonomy            MEGAN Analysis       Enzyme Classes
   ↓                     ↓                     ↓                     ↓
   └─────────────────────┴─────────────────────┴─────────────────────┘
                                ↓
                        Result Integration
                                ↓
                      Final Annotation Tables
```

## Detailed Workflow Steps

### 1. Quality Control (`rules/qc.smk`)

**Purpose:** Assess and improve raw read quality

**Input:** Raw FASTQ files
**Output:** FastQC reports, trimmed reads

**Steps:**
1. **FastQC Analysis**
   - Generate quality reports for raw reads
   - Assess per-base quality, GC content, adapter presence
   - Output: `{results}/qc/fastqc/{sample}_{read}_fastqc.zip`

2. **Adapter Trimming (Cutadapt)**
   - Remove adapter sequences and low-quality bases
   - Filter reads by minimum length
   - Output: `{results}/qc/cleaned/{sample}_{read}.fastq.gz`

**Key Tools:**
- FastQC v0.11+
- Cutadapt v3.0+

### 2. Host Read Filtering (`rules/filter_plant_reads.smk`)

**Purpose:** Remove host/plant contamination from environmental samples

**Input:** Quality-trimmed reads
**Output:** Host-filtered reads

**Steps:**
1. **Reference Indexing**
   - Build Bowtie2 index for plant reference genome
   - Example: Alnus (alder) genome for tree-associated samples

2. **Read Mapping and Filtering**
   - Map reads to host reference genome
   - Extract unmapped (non-host) reads
   - Output: `{results}/unmapped/{sample}_{read}.fastq`

**Key Tools:**
- Bowtie2 v2.4+

### 3. Assembly (`rules/assembly.smk` or `rules/assembly_spades.smk`)

**Purpose:** Reconstruct transcripts from filtered reads

**Input:** Host-filtered reads
**Output:** Assembled transcripts

**Assembly Options:**

#### Trinity Assembly
- **Best for:** Eukaryotic transcriptomes, complex alternative splicing
- **Memory requirement:** High (>100GB for large datasets)
- **Output:** `{results}/assembly/trinity_{sample}/Trinity.fasta`

#### SPAdes Assembly
- **Best for:** Bacterial/prokaryotic data, memory-limited environments
- **Memory requirement:** Moderate (configurable)
- **Output:** `{results}/assembly/spades_{sample}/transcripts.fasta`

**Key Tools:**
- Trinity v2.11+
- SPAdes v3.15+

### 4. Quantification (`rules/edit_abundance.smk`)

**Purpose:** Estimate transcript abundance

**Input:** Assembled transcripts, filtered reads
**Output:** Abundance estimates (TPM values)

**Steps:**
1. **Salmon Indexing**
   - Build salmon index from assembled transcripts

2. **Quantification**
   - Map reads back to transcripts
   - Calculate TPM (Transcripts Per Million) values
   - Output: `{results}/assembly/quant_{sample}/quant.sf`

3. **Abundance Editing**
   - Process salmon output for downstream analysis
   - Output: `{results}/assembly/quant_{sample}/quant_edit.sf`

**Key Tools:**
- Salmon v1.4+

### 5. Functional Annotation

The pipeline performs parallel functional annotation using multiple databases:

#### 5.1 UniProt Annotation (`rules/uniprot.smk`)

**Purpose:** Functional annotation and KEGG orthology mapping

**Steps:**
1. **DIAMOND Search**
   - Search assembled transcripts against UniProt database
   - Use sensitive mode for better accuracy
   - Output: `{results}/diamond/{sample}_uniprot.csv`

2. **KEGG Mapping**
   - Map UniProt hits to KEGG orthology (KO) terms
   - Generate pathway annotations
   - Output: `{results}/uniprot/{sample}_uniprot_ko.tab`

#### 5.2 JGI Annotation (`rules/diamond_jgi_search.smk`)

**Purpose:** Fungal protein annotation using JGI database

**Steps:**
1. **Database Preparation**
   - Download and index JGI fungal proteomes
   - Build DIAMOND database

2. **Annotation Search**
   - DIAMOND search against JGI database
   - Focus on fungal protein functions
   - Output: `{results}/anotation/{sample}/{sample}_jgi_tax.tsv`

#### 5.3 NCBI Annotation (`rules/diamond_ncbi_search.smk`)

**Purpose:** Bacterial protein annotation

**Steps:**
1. **DIAMOND Search**
   - Search against NCBI bacterial protein database
   - Optimized for prokaryotic sequences
   - Output: `{results}/bac_diamond/{sample}_ncbi.csv`

2. **Taxonomic Assignment**
   - Integrate with NCBI taxonomy
   - Assign bacterial lineages

#### 5.4 CAZy Annotation (`rules/diamond_cazy.smk`)

**Purpose:** Carbohydrate-active enzyme classification

**Steps:**
1. **CAZy Search**
   - Search against dbCAN CAZy database
   - Identify carbohydrate-active enzymes
   - Classify into enzyme families (GH, GT, PL, CE, AA, CBM)

### 6. Taxonomic Analysis (`rules/megan_taxonomy_prok.smk`)

**Purpose:** Taxonomic classification of bacterial sequences

**Input:** NCBI DIAMOND results
**Output:** Taxonomic assignments with abundance

**Steps:**
1. **MEGAN Analysis**
   - Import DIAMOND results into MEGAN
   - Perform LCA (Lowest Common Ancestor) analysis
   - Generate taxonomic trees

2. **Abundance Integration**
   - Combine taxonomic assignments with TPM values
   - Output: `{results}/megan/{sample}_taxinfo.txt`

**Key Tools:**
- MEGAN6 Community Edition

### 7. Result Integration

**Purpose:** Merge all annotation results with abundance data

**Key Output Files:**
- `jgi_tax_tpm_unip.txt`: Combined JGI, taxonomy, and UniProt annotations
- `megan_tpm_tax.txt`: MEGAN taxonomy with abundance
- `megan_tax_tpm_unip.txt`: Complete integrated results

## Pipeline Rules Reference

### Core Rules

| Rule File | Purpose | Key Outputs |
|-----------|---------|-------------|
| `qc.smk` | Quality control | FastQC reports, trimmed reads |
| `filter_plant_reads.smk` | Host filtering | Clean reads |
| `assembly.smk` | Trinity assembly | Assembled transcripts |
| `assembly_spades.smk` | SPAdes assembly | Assembled transcripts |
| `edit_abundance.smk` | Quantification | TPM values |

### Annotation Rules

| Rule File | Database | Target Organisms | Output |
|-----------|----------|------------------|--------|
| `uniprot.smk` | UniProt | Universal | Functional annotation, KEGG |
| `diamond_jgi_search.smk` | JGI | Fungi | Taxonomic annotation |
| `diamond_ncbi_search.smk` | NCBI | Bacteria | Taxonomic annotation |
| `diamond_cazy.smk` | CAZy | Universal | Enzyme classification |
| `megan_taxonomy_prok.smk` | NCBI | Bacteria | Taxonomic classification |

### Database Setup Rules

| Rule File | Purpose | Database |
|-----------|---------|----------|
| `create_uniprot_db.smk` | UniProt indexing | UniProt |
| `index_jgi_diamond.smk` | JGI indexing | JGI |
| `index_ncbi_diamond.smk` | NCBI indexing | NCBI |
| `CAzy_download.smk` | CAZy setup | dbCAN |

## Data Flow and Dependencies

### File Dependencies

```
Raw FASTQ → QC → Host Filter → Assembly → Quantification
                                    ↓
                              ┌─────────────┐
                              │ Annotation  │
                              │ (Parallel)  │
                              └─────────────┘
                                    ↓
                              Integration
```

### Critical Checkpoints

1. **Post-QC:** Verify read quality improvement
2. **Post-Assembly:** Check assembly statistics (N50, total transcripts)
3. **Post-Quantification:** Validate TPM distributions
4. **Post-Annotation:** Verify hit rates across databases

## Performance Considerations

### Memory Usage by Step

| Step | Typical Memory | Peak Memory |
|------|----------------|-------------|
| FastQC | 2-4 GB | 8 GB |
| Cutadapt | 4-8 GB | 16 GB |
| Bowtie2 | 8-16 GB | 32 GB |
| Trinity | 100-500 GB | 1 TB |
| SPAdes | 20-100 GB | 200 GB |
| Salmon | 8-16 GB | 32 GB |
| DIAMOND | 16-64 GB | 128 GB |
| MEGAN | 16-32 GB | 64 GB |

### Threading Efficiency

| Tool | Scaling | Optimal Threads |
|------|---------|-----------------|
| FastQC | Poor | 1-2 |
| Cutadapt | Good | 4-8 |
| Bowtie2 | Good | 8-16 |
| Trinity | Excellent | 16-32 |
| SPAdes | Good | 8-16 |
| Salmon | Good | 8-16 |
| DIAMOND | Excellent | 16-64 |

## Error Handling and Recovery

### Common Failure Points

1. **Assembly Memory Exhaustion**
   - Solution: Increase memory allocation or switch to SPAdes
   - Prevention: Monitor memory usage during assembly

2. **Database Index Corruption**
   - Solution: Rebuild database indices
   - Prevention: Verify database integrity before running

3. **Disk Space Issues**
   - Solution: Clean intermediate files, expand storage
   - Prevention: Monitor disk usage throughout pipeline

### Recovery Strategies

1. **Partial Rerun:** Use Snakemake's built-in recovery
2. **Checkpoint Restart:** Resume from last successful rule
3. **Parameter Adjustment:** Modify configuration and restart

## Validation and Quality Control

### Assembly Quality Metrics

- **N50:** Measure of assembly contiguity
- **Total Transcripts:** Number of assembled sequences
- **Total Assembly Length:** Sum of all transcript lengths
- **Annotation Rate:** Percentage of transcripts with functional annotation

### Annotation Quality Metrics

- **UniProt Hit Rate:** Percentage with UniProt matches
- **KEGG Coverage:** Percentage with KEGG annotations
- **Taxonomic Coverage:** Percentage with taxonomic assignment
- **Database Concordance:** Agreement between annotation sources

## Customization Options

### Rule Modifications

1. **Assembly Parameters:** Adjust k-mer sizes, coverage thresholds
2. **Search Sensitivity:** Modify DIAMOND sensitivity settings
3. **Filtering Criteria:** Change e-value thresholds, hit coverage
4. **Database Versions:** Update to newer database releases

### Additional Analyses

1. **Pathway Enrichment:** Extend KEGG analysis
2. **Comparative Analysis:** Multi-sample comparisons
3. **Visualization:** Generate plots and charts
4. **Statistical Analysis:** Add differential expression analysis

## Output File Formats

### Primary Outputs

| File Type | Format | Description |
|-----------|--------|-------------|
| Assembly | FASTA | Assembled transcript sequences |
| Quantification | TSV | Transcript abundance (TPM) |
| Annotation | CSV/TSV | Functional annotations |
| Taxonomy | TXT | Taxonomic classifications |
| Integration | TXT | Combined results |

### Intermediate Files

- DIAMOND results (`.csv`)
- Salmon quantification (`.sf`)
- MEGAN exports (`.txt`)
- Index files (`.bt2`, `.fai`, `.dmnd`)

This workflow documentation provides the foundation for understanding and customizing the Vasuki pipeline for specific research needs.