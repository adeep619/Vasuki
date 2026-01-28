# Usage Examples and Tutorials - Vasuki Pipeline

This document provides comprehensive tutorials and usage examples for the Vasuki metatranscriptomics pipeline, from basic setup to advanced analysis workflows.

## Table of Contents

- [Quick Start Tutorial](#quick-start-tutorial)
- [Basic Usage Examples](#basic-usage-examples)
- [Advanced Workflows](#advanced-workflows)
- [Troubleshooting Examples](#troubleshooting-examples)
- [Performance Optimization](#performance-optimization)
- [Real-World Case Studies](#real-world-case-studies)

## Quick Start Tutorial

### Prerequisites Check

Before starting, ensure you have the required software and databases:

```bash
# Check conda installation
conda --version

# Check available memory (should be >16GB for small datasets)
free -h

# Check available disk space (should be >100GB for moderate datasets)
df -h

# Check CPU cores
nproc
```

### Step 1: Environment Setup

```bash
# 1. Clone the repository (or download)
git clone <repository-url>
cd vasuki-pipeline

# 2. Create conda environment
conda env create -f metatrans.yaml
conda activate vasuki

# 3. Verify installation
snakemake --version
python --version
```

### Step 2: Prepare Test Data

```bash
# Create test directory structure
mkdir -p test_data
mkdir -p test_results

# Download test data (example)
# Replace with your actual sequencing files
wget -O test_data/sample1_R1.fastq.gz "https://example.com/test_R1.fastq.gz"
wget -O test_data/sample1_R2.fastq.gz "https://example.com/test_R2.fastq.gz"

# Verify files
ls -la test_data/
```

### Step 3: Create Basic Configuration

```bash
# Create minimal test configuration
cat > test_config.yaml << EOF
samples:
    sample1: "sample1"

raw: "test_data"
results: "test_results"
format: "fastq"
reads: ["R1", "R2"]

threads: 4
maxmem: 16000
io: 2

assembly: "SPADES"
adapter: "GATCGGAAGAGCA"

NCBI: "v5"
sortmerna: "v4.2.0"
jgi_config: "jgi_download.config"
jgi_organism_ids: "fungi_ids_list.txt"
EOF
```

### Step 4: Run Test Pipeline

```bash
# Dry run to check configuration
snakemake -s Snakefile.smk --configfile test_config.yaml --dry-run

# Run quality control only (fast test)
snakemake -s Snakefile.smk --configfile test_config.yaml --use-conda -j 4 \
    test_results/qc/multiqc_report.html

# Run full pipeline (takes longer)
snakemake -s Snakefile.smk --configfile test_config.yaml --use-conda -j 4
```

### Step 5: Examine Results

```bash
# Check output structure
tree test_results/

# View quality control report
firefox test_results/qc/multiqc_report.html

# Check assembly statistics
head test_results/assembly/trinity_sample1/Trinity.fasta

# View annotation results
head test_results/annotation/sample1/jgi_tax_tpm_unip.txt
```

## Basic Usage Examples

### Example 1: Single Sample Analysis

**Scenario:** Analyze one sample with basic settings

```bash
# 1. Configuration
cat > single_sample.yaml << EOF
samples:
    my_sample: "my_sample"

raw: "data/raw_reads"
results: "results/my_sample"
format: "fastq"
reads: ["R1", "R2"]

threads: 8
maxmem: 32000
assembly: "TRINITY"
EOF

# 2. Run analysis
snakemake -s Snakefile.smk --configfile single_sample.yaml --use-conda -j 8

# 3. Check key outputs
ls results/my_sample/assembly/trinity_my_sample/Trinity.fasta
ls results/my_sample/annotation/my_sample/jgi_tax_tpm_unip.txt
```

### Example 2: Multiple Sample Batch Processing

**Scenario:** Process multiple samples from the same experiment

```bash
# 1. Create sample list
cat > batch_samples.yaml << EOF
samples:
    control_rep1: "CTRL_01"
    control_rep2: "CTRL_02"
    control_rep3: "CTRL_03"
    treatment_rep1: "TREAT_01"
    treatment_rep2: "TREAT_02"
    treatment_rep3: "TREAT_03"

raw: "data/batch_experiment"
results: "results/batch_analysis"
format: "fastq"
reads: ["R1", "R2"]

threads: 16
maxmem: 128000
assembly: "SPADES"  # Faster for multiple samples
EOF

# 2. Run batch analysis
snakemake -s Snakefile.smk --configfile batch_samples.yaml --use-conda -j 16

# 3. Compare results across samples
for sample in CTRL_01 CTRL_02 CTRL_03 TREAT_01 TREAT_02 TREAT_03; do
    echo "=== $sample assembly stats ==="
    grep ">" results/batch_analysis/assembly/trinity_$sample/Trinity.fasta | wc -l
done
```

### Example 3: Quality Control Only

**Scenario:** Run only QC steps to assess data quality before full analysis

```bash
# 1. QC-focused configuration
cat > qc_only.yaml << EOF
samples:
    sample1: "sample1"
    sample2: "sample2"

raw: "data/new_sequencing"
results: "results/qc_check"
format: "fastq"
reads: ["R1", "R2"]

threads: 8
maxmem: 16000
EOF

# 2. Run QC steps only
snakemake -s Snakefile.smk --configfile qc_only.yaml --use-conda -j 8 \
    results/qc_check/qc/multiqc_report.html

# 3. Review QC results
firefox results/qc_check/qc/multiqc_report.html
```

### Example 4: Assembly Comparison

**Scenario:** Compare Trinity vs SPAdes assembly for the same sample

```bash
# 1. Trinity assembly
cat > trinity_config.yaml << EOF
samples:
    test_sample: "test_sample"
raw: "data/test"
results: "results/trinity_test"
assembly: "TRINITY"
threads: 16
maxmem: 128000
EOF

# 2. SPAdes assembly
cat > spades_config.yaml << EOF
samples:
    test_sample: "test_sample"
raw: "data/test"
results: "results/spades_test"
assembly: "SPADES"
threads: 16
maxmem: 64000
EOF

# 3. Run both assemblies
snakemake -s Snakefile.smk --configfile trinity_config.yaml --use-conda -j 16 \
    results/trinity_test/assembly/trinity_test_sample/Trinity.fasta

snakemake -s Snakefile.smk --configfile spades_config.yaml --use-conda -j 16 \
    results/spades_test/assembly/spades_test_sample/transcripts.fasta

# 4. Compare assembly statistics
echo "Trinity assembly:"
grep ">" results/trinity_test/assembly/trinity_test_sample/Trinity.fasta | wc -l

echo "SPAdes assembly:"
grep ">" results/spades_test/assembly/spades_test_sample/transcripts.fasta | wc -l
```

## Advanced Workflows

### Workflow 1: Custom Database Integration

**Scenario:** Use custom protein database for annotation

```bash
# 1. Prepare custom database
mkdir -p custom_databases
# Download or create your protein database
# Format: custom_proteins.fasta

# 2. Create Diamond database
conda activate vasuki
diamond makedb --in custom_databases/custom_proteins.fasta \
    --db custom_databases/custom_proteins

# 3. Modify Snakemake rule (create custom rule file)
cat > rules/custom_annotation.smk << 'EOF'
rule diamond_custom:
    input:
        "{results}/assembly/trinity_{sample}/Trinity.fasta"
    output:
        "{results}/custom_annotation/{sample}_custom.tsv"
    conda:
        "../envs/diamond.yaml"
    threads: config["threads"]
    shell:
        """
        diamond blastx -d custom_databases/custom_proteins \
            -q {input} -o {output} -f 6 --evalue 1e-5 \
            --threads {threads}
        """
EOF

# 4. Include custom rule in main Snakefile
echo 'include: "rules/custom_annotation.smk"' >> Snakefile.smk

# 5. Run with custom annotation
snakemake -s Snakefile.smk --configfile config.yaml --use-conda -j 16 \
    results/custom_annotation/sample1_custom.tsv
```

### Workflow 2: Time-Series Analysis

**Scenario:** Analyze samples collected over time

```bash
# 1. Organize time-series data
mkdir -p data/timeseries
# Structure: timepoint_replicate format
# T0_rep1, T0_rep2, T24_rep1, T24_rep2, T48_rep1, T48_rep2

# 2. Create time-series configuration
cat > timeseries_config.yaml << EOF
samples:
    T0_rep1: "T0_rep1"
    T0_rep2: "T0_rep2"
    T24_rep1: "T24_rep1"
    T24_rep2: "T24_rep2"
    T48_rep1: "T48_rep1"
    T48_rep2: "T48_rep2"

raw: "data/timeseries"
results: "results/timeseries"
format: "fastq"
reads: ["R1", "R2"]

threads: 20
maxmem: 256000
assembly: "TRINITY"
EOF

# 3. Run time-series analysis
snakemake -s Snakefile.smk --configfile timeseries_config.yaml --use-conda -j 20

# 4. Create time-series comparison script
cat > scripts/timeseries_analysis.py << 'EOF'
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load TPM data for all timepoints
timepoints = ['T0', 'T24', 'T48']
replicates = ['rep1', 'rep2']

tpm_data = {}
for tp in timepoints:
    for rep in replicates:
        sample = f"{tp}_{rep}"
        file_path = f"results/timeseries/assembly/quant_{sample}/quant.sf"
        df = pd.read_csv(file_path, sep='\t')
        tpm_data[sample] = df[['Name', 'TPM']].set_index('Name')

# Merge all TPM data
merged_tpm = pd.concat(tpm_data.values(), axis=1, keys=tpm_data.keys())
merged_tpm.columns = merged_tpm.columns.get_level_values(0)

# Calculate mean TPM per timepoint
for tp in timepoints:
    tp_samples = [f"{tp}_{rep}" for rep in replicates]
    merged_tpm[f"{tp}_mean"] = merged_tpm[tp_samples].mean(axis=1)

# Save results
merged_tpm.to_csv("results/timeseries/timeseries_tpm_analysis.csv")
print("Time-series analysis complete!")
EOF

python scripts/timeseries_analysis.py
```

### Workflow 3: Comparative Metatranscriptomics

**Scenario:** Compare different environmental conditions

```bash
# 1. Set up comparative study
cat > comparative_config.yaml << EOF
samples:
    # Condition A samples
    condA_rep1: "conditionA_replicate1"
    condA_rep2: "conditionA_replicate2"
    condA_rep3: "conditionA_replicate3"
    # Condition B samples
    condB_rep1: "conditionB_replicate1"
    condB_rep2: "conditionB_replicate2"
    condB_rep3: "conditionB_replicate3"

raw: "data/comparative_study"
results: "results/comparative"
format: "fastq"
reads: ["R1", "R2"]

threads: 24
maxmem: 512000
assembly: "TRINITY"
EOF

# 2. Run full comparative analysis
snakemake -s Snakefile.smk --configfile comparative_config.yaml --use-conda -j 24

# 3. Create comparison analysis script
cat > scripts/comparative_analysis.R << 'EOF'
library(DESeq2)
library(ggplot2)
library(pheatmap)

# Load TPM data
samples <- c("condA_rep1", "condA_rep2", "condA_rep3", 
            "condB_rep1", "condB_rep2", "condB_rep3")

# Read quantification data
count_data <- list()
for(sample in samples) {
    file_path <- paste0("results/comparative/assembly/quant_", sample, "/quant.sf")
    df <- read.table(file_path, header=TRUE, sep="\t")
    count_data[[sample]] <- df[, c("Name", "NumReads")]
}

# Merge count data
merged_counts <- Reduce(function(x, y) merge(x, y, by="Name", all=TRUE), count_data)
colnames(merged_counts) <- c("Name", samples)
rownames(merged_counts) <- merged_counts$Name
merged_counts <- merged_counts[, -1]

# Create sample metadata
sample_data <- data.frame(
    sample = samples,
    condition = rep(c("A", "B"), each=3),
    replicate = rep(1:3, 2)
)
rownames(sample_data) <- samples

# Run DESeq2 analysis
dds <- DESeqDataSetFromMatrix(countData = round(merged_counts),
                              colData = sample_data,
                              design = ~ condition)
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "B", "A"))

# Save results
write.csv(res, "results/comparative/differential_expression.csv")

# Create heatmap of top differentially expressed genes
top_genes <- head(order(res$padj), 50)
heatmap_data <- assay(vst(dds))[top_genes, ]

pdf("results/comparative/heatmap_top_genes.pdf")
pheatmap(heatmap_data, 
         annotation_col = sample_data[, "condition", drop=FALSE],
         scale = "row",
         clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean")
dev.off()

print("Comparative analysis complete!")
EOF

# Run R analysis (requires R and packages)
Rscript scripts/comparative_analysis.R
```

## Troubleshooting Examples

### Example 1: Memory Issues

**Problem:** Trinity assembly fails with memory error

```bash
# Error message:
# "Trinity command failed with exit code: 1"
# Check log: cat results/assembly/trinity_sample/Trinity.log

# Solution 1: Reduce memory usage
cat > low_memory_config.yaml << EOF
samples:
    sample1: "sample1"
raw: "data"
results: "results"
threads: 8
maxmem: 64000  # Reduced from higher value
assembly: "SPADES"  # Use SPAdes instead of Trinity
EOF

# Solution 2: Use Trinity with memory limit
cat > trinity_limited_config.yaml << EOF
samples:
    sample1: "sample1"
raw: "data"
results: "results"
threads: 16
maxmem: 100000
assembly: "TRINITY"
trinity_max_memory: "80G"  # Explicit Trinity memory limit
EOF

# Solution 3: Process subsets of reads
# Create a rule to subsample reads before assembly
cat > rules/subsample.smk << 'EOF'
rule subsample_reads:
    input:
        r1="{results}/qc/cleaned/{sample}_R1.fastq.gz",
        r2="{results}/qc/cleaned/{sample}_R2.fastq.gz"
    output:
        r1="{results}/subsampled/{sample}_R1.fastq.gz",
        r2="{results}/subsampled/{sample}_R2.fastq.gz"
    shell:
        """
        seqtk sample -s100 {input.r1} 0.5 | gzip > {output.r1}
        seqtk sample -s100 {input.r2} 0.5 | gzip > {output.r2}
        """
EOF
```

### Example 2: Database Download Issues

**Problem:** JGI download fails or is incomplete

```bash
# Problem diagnosis
ls -la JGI_Database/*/  # Check downloaded files
cat JGI_Database/download.log  # Check error messages

# Solution 1: Manual verification and retry
python << 'EOF'
import os
import glob

# Check for incomplete downloads
jgi_dirs = glob.glob("JGI_Database/*/")
for dir_path in jgi_dirs:
    org_id = os.path.basename(dir_path.rstrip('/'))
    files = os.listdir(dir_path)
    print(f"{org_id}: {len(files)} files downloaded")
    
    # Check for error indicators
    for file in files:
        filepath = os.path.join(dir_path, file)
        if os.path.getsize(filepath) < 1000:  # Very small files might be errors
            print(f"  WARNING: {file} is very small ({os.path.getsize(filepath)} bytes)")
EOF

# Solution 2: Retry specific organisms
# Edit fungi_ids_list.txt to include only failed organisms
echo "12345" > retry_organisms.txt

# Modify configuration to retry
sed -i 's/fungi_ids_list.txt/retry_organisms.txt/' config.yaml

# Solution 3: Use alternative download method
wget -O backup_proteins.fasta "https://alternative-source.com/proteins.fasta"
```

### Example 3: Environment Conflicts

**Problem:** Conda environment creation fails

```bash
# Problem: Package conflicts or missing channels

# Solution 1: Clean conda and retry
conda clean --all
conda env remove -n vasuki
conda env create -f metatrans.yaml

# Solution 2: Create environment manually
conda create -n vasuki_manual python=3.8
conda activate vasuki_manual
conda install -c bioconda snakemake=6.15.5
conda install -c bioconda trinity=2.9.1
conda install -c bioconda diamond=2.0.4
# ... add other packages as needed

# Solution 3: Use mamba for faster dependency resolution
conda install mamba
mamba env create -f metatrans.yaml

# Solution 4: Create minimal environment and add packages incrementally
cat > minimal_env.yaml << EOF
name: vasuki_minimal
channels:
  - conda-forge
  - bioconda
dependencies:
  - python=3.8
  - snakemake=6.15.5
EOF

conda env create -f minimal_env.yaml
conda activate vasuki_minimal

# Add packages one by one
conda install -c bioconda trinity=2.9.1
conda install -c bioconda diamond=2.0.4
# ... continue as needed
```

## Performance Optimization

### CPU Optimization Examples

```bash
# Example 1: Multi-core optimization
cat > high_performance.yaml << EOF
samples:
    sample1: "sample1"
threads: 32  # Use most available cores
maxmem: 256000
assembly: "TRINITY"

# Custom threading for specific rules
rule_threads:
    trinity: 24
    diamond: 16
    fastqc: 8
EOF

# Example 2: Cluster optimization
cat > cluster_config.yaml << EOF
samples:
    sample1: "sample1"
threads: 64  # High-core cluster node
maxmem: 1000000
assembly: "TRINITY"

# Cluster-specific settings
cluster:
    partition: "high_memory"
    time: "24:00:00"
    memory: "1000G"
EOF

# Run on cluster
sbatch --partition=high_memory --time=24:00:00 --mem=1000G \
    --wrap="snakemake -s Snakefile.smk --configfile cluster_config.yaml --use-conda -j 64"
```

### Memory Optimization Examples

```bash
# Example 1: Progressive memory allocation
cat > memory_efficient.yaml << EOF
samples:
    sample1: "sample1"

# Start with conservative memory
threads: 8
maxmem: 32000
assembly: "SPADES"  # More memory efficient

# If successful, increase for better quality
# maxmem: 128000
# assembly: "TRINITY"
EOF

# Example 2: Memory monitoring during execution
# Create monitoring script
cat > scripts/monitor_memory.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): Memory usage"
    free -h
    echo "$(date): Top memory consumers"
    ps aux --sort=-%mem | head -10
    echo "---"
    sleep 60
done
EOF

chmod +x scripts/monitor_memory.sh

# Run monitoring in background
./scripts/monitor_memory.sh > memory_usage.log 2>&1 &
MONITOR_PID=$!

# Run analysis
snakemake -s Snakefile.smk --configfile config.yaml --use-conda -j 8

# Stop monitoring
kill $MONITOR_PID
```

### I/O Optimization Examples

```bash
# Example 1: SSD optimization
cat > ssd_optimized.yaml << EOF
samples:
    sample1: "sample1"
threads: 16
maxmem: 128000
io: 12  # Higher I/O for SSD

# Use local SSD for temporary files
temp_dir: "/tmp/vasuki_analysis"
EOF

# Create temporary directory
mkdir -p /tmp/vasuki_analysis

# Example 2: Network storage optimization
cat > network_optimized.yaml << EOF
samples:
    sample1: "sample1"
threads: 8
maxmem: 64000
io: 3  # Lower I/O for network storage

# Minimize network I/O by using local staging
stage_locally: true
EOF
```

## Real-World Case Studies

### Case Study 1: Marine Microbiome Analysis

**Scenario:** Analyzing marine microbial communities from different depths

```bash
# 1. Study design
cat > marine_study.yaml << EOF
samples:
    surface_rep1: "surface_rep1"
    surface_rep2: "surface_rep2"
    surface_rep3: "surface_rep3"
    mid_depth_rep1: "mid_depth_rep1"
    mid_depth_rep2: "mid_depth_rep2"
    mid_depth_rep3: "mid_depth_rep3"
    deep_rep1: "deep_rep1"
    deep_rep2: "deep_rep2"
    deep_rep3: "deep_rep3"

raw: "data/marine_samples"
results: "results/marine_study"
format: "fastq"
reads: ["R1", "R2"]

threads: 24
maxmem: 512000
assembly: "TRINITY"

# Marine-specific database configuration
jgi_config: "marine_jgi.config"
jgi_organism_ids: "marine_organisms.txt"
EOF

# 2. Create marine-specific organism list
cat > marine_organisms.txt << EOF
# Marine bacteria and archaea
123456	Prochlorococcus_marinus
234567	Synechococcus_sp
345678	Candidatus_Pelagibacter
456789	Nitrosopumilus_maritimus
567890	Thaumarchaeota_sp
EOF

# 3. Configure marine-specific file downloads
echo "aa.fasta.gz,KEGG.tab.gz,GO.tab.gz,gff.gz" > marine_jgi.config

# 4. Run marine analysis
snakemake -s Snakefile.smk --configfile marine_study.yaml --use-conda -j 24

# 5. Marine-specific analysis script
cat > scripts/marine_analysis.py << 'EOF'
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load annotation data for all samples
samples = {
    'surface': ['surface_rep1', 'surface_rep2', 'surface_rep3'],
    'mid_depth': ['mid_depth_rep1', 'mid_depth_rep2', 'mid_depth_rep3'],
    'deep': ['deep_rep1', 'deep_rep2', 'deep_rep3']
}

# Analyze functional profiles by depth
functional_profiles = {}
for depth, sample_list in samples.items():
    depth_functions = []
    for sample in sample_list:
        file_path = f"results/marine_study/annotation/{sample}/jgi_tax_tpm_unip.txt"
        df = pd.read_csv(file_path, sep='\t')
        # Extract KEGG functional categories
        kegg_functions = df.groupby('KEGG_category')['TPM'].sum()
        depth_functions.append(kegg_functions)
    
    # Combine replicates
    functional_profiles[depth] = pd.concat(depth_functions, axis=1).mean(axis=1)

# Create functional comparison plot
comparison_df = pd.DataFrame(functional_profiles)
comparison_df.plot(kind='bar', figsize=(12, 8))
plt.title('Functional Profiles by Ocean Depth')
plt.xlabel('KEGG Functional Categories')
plt.ylabel('Mean TPM')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('results/marine_study/functional_depth_comparison.png', dpi=300)

print("Marine microbiome analysis complete!")
EOF

python scripts/marine_analysis.py
```

### Case Study 2: Soil Microbiome Temporal Study

**Scenario:** Tracking soil microbial communities over a growing season

```bash
# 1. Temporal study configuration
cat > soil_temporal.yaml << EOF
samples:
    # Spring samples
    spring_week1_rep1: "spring_week1_rep1"
    spring_week1_rep2: "spring_week1_rep2"
    spring_week2_rep1: "spring_week2_rep1"
    spring_week2_rep2: "spring_week2_rep2"
    # Summer samples
    summer_week1_rep1: "summer_week1_rep1"
    summer_week1_rep2: "summer_week1_rep2"
    summer_week2_rep1: "summer_week2_rep1"
    summer_week2_rep2: "summer_week2_rep2"
    # Fall samples
    fall_week1_rep1: "fall_week1_rep1"
    fall_week1_rep2: "fall_week1_rep2"
    fall_week2_rep1: "fall_week2_rep1"
    fall_week2_rep2: "fall_week2_rep2"

raw: "data/soil_temporal"
results: "results/soil_temporal"
format: "fastq"
reads: ["R1", "R2"]

threads: 20
maxmem: 256000
assembly: "SPADES"  # Faster for many samples
EOF

# 2. Run temporal analysis
snakemake -s Snakefile.smk --configfile soil_temporal.yaml --use-conda -j 20

# 3. Temporal analysis script
cat > scripts/temporal_soil_analysis.R << 'EOF'
library(vegan)
library(ggplot2)
library(dplyr)

# Load and process data
samples <- list(
    spring = c("spring_week1_rep1", "spring_week1_rep2", "spring_week2_rep1", "spring_week2_rep2"),
    summer = c("summer_week1_rep1", "summer_week1_rep2", "summer_week2_rep1", "summer_week2_rep2"),
    fall = c("fall_week1_rep1", "fall_week1_rep2", "fall_week2_rep1", "fall_week2_rep2")
)

# Create community matrix
community_data <- data.frame()
for(season in names(samples)) {
    for(sample in samples[[season]]) {
        file_path <- paste0("results/soil_temporal/annotation/", sample, "/jgi_tax_tpm_unip.txt")
        df <- read.table(file_path, header=TRUE, sep="\t")
        
        # Aggregate by taxonomic family
        family_abundance <- aggregate(df$TPM, by=list(Family=df$Family), FUN=sum)
        family_abundance$Sample <- sample
        family_abundance$Season <- season
        
        community_data <- rbind(community_data, family_abundance)
    }
}

# Reshape for analysis
community_matrix <- reshape2::dcast(community_data, Sample + Season ~ Family, value.var="x", fill=0)
rownames(community_matrix) <- community_matrix$Sample

# PCA analysis
pca_result <- rda(community_matrix[, -(1:2)])
biplot(pca_result, display=c("sites", "species"))

# Save results
write.csv(community_matrix, "results/soil_temporal/community_matrix.csv")
pdf("results/soil_temporal/temporal_pca.pdf")
biplot(pca_result, main="Soil Microbiome Temporal PCA")
dev.off()

print("Temporal soil analysis complete!")
EOF

Rscript scripts/temporal_soil_analysis.R
```

### Case Study 3: Industrial Bioreactor Monitoring

**Scenario:** Monitoring microbial communities in an industrial fermentation process

```bash
# 1. Bioreactor study setup
cat > bioreactor_study.yaml << EOF
samples:
    # Time points during fermentation
    T0h_rep1: "T0h_rep1"
    T0h_rep2: "T0h_rep2"
    T6h_rep1: "T6h_rep1"
    T6h_rep2: "T6h_rep2"
    T12h_rep1: "T12h_rep1"
    T12h_rep2: "T12h_rep2"
    T24h_rep1: "T24h_rep1"
    T24h_rep2: "T24h_rep2"
    T48h_rep1: "T48h_rep1"
    T48h_rep2: "T48h_rep2"

raw: "data/bioreactor"
results: "results/bioreactor"
format: "fastq"
reads: ["R1", "R2"]

threads: 16
maxmem: 128000
assembly: "SPADES"

# Focus on bacterial and yeast organisms
jgi_organism_ids: "industrial_microbes.txt"
EOF

# 2. Create industrial microbe list
cat > industrial_microbes.txt << EOF
# Industrial fermentation microbes
112233	Saccharomyces_cerevisiae
223344	Lactobacillus_acidophilus
334455	Escherichia_coli
445566	Bacillus_subtilis
556677	Zymomonas_mobilis
EOF

# 3. Run bioreactor analysis
snakemake -s Snakefile.smk --configfile bioreactor_study.yaml --use-conda -j 16

# 4. Process optimization analysis
cat > scripts/bioreactor_analysis.py << 'EOF'
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Define time points
timepoints = ['T0h', 'T6h', 'T12h', 'T24h', 'T48h']

# Load metabolic pathway data
pathway_data = {}
for tp in timepoints:
    tp_pathways = []
    for rep in ['rep1', 'rep2']:
        sample = f"{tp}_{rep}"
        file_path = f"results/bioreactor/annotation/{sample}/jgi_tax_tpm_unip.txt"
        df = pd.read_csv(file_path, sep='\t')
        
        # Focus on metabolic pathways
        metabolic_pathways = df[df['KEGG_pathway'].str.contains('Metabolic', na=False)]
        pathway_summary = metabolic_pathways.groupby('KEGG_pathway')['TPM'].sum()
        tp_pathways.append(pathway_summary)
    
    # Average replicates
    pathway_data[tp] = pd.concat(tp_pathways, axis=1).mean(axis=1)

# Create pathway dynamics plot
pathway_df = pd.DataFrame(pathway_data)
pathway_df.T.plot(kind='line', figsize=(15, 10), marker='o')
plt.title('Metabolic Pathway Dynamics During Fermentation')
plt.xlabel('Time Point')
plt.ylabel('Total TPM')
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.savefig('results/bioreactor/pathway_dynamics.png', dpi=300, bbox_inches='tight')

# Identify key fermentation pathways
fermentation_pathways = [
    'Glycolysis / Gluconeogenesis',
    'Citrate cycle (TCA cycle)',
    'Pentose phosphate pathway',
    'Pyruvate metabolism'
]

plt.figure(figsize=(12, 8))
for pathway in fermentation_pathways:
    if pathway in pathway_df.index:
        plt.plot(timepoints, pathway_df.loc[pathway], marker='o', label=pathway, linewidth=2)

plt.title('Key Fermentation Pathways Over Time')
plt.xlabel('Time Point')
plt.ylabel('TPM')
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('results/bioreactor/key_pathways.png', dpi=300)

# Export data for process optimization
pathway_df.to_csv('results/bioreactor/pathway_timecourse.csv')

print("Bioreactor analysis complete!")
print("Key findings saved to results/bioreactor/")
EOF

python scripts/bioreactor_analysis.py
```

This comprehensive tutorial and example collection provides users with practical, real-world guidance for using the Vasuki pipeline effectively across various research scenarios and computational environments.