# Vasuki Database Setup Guide

This guide provides detailed instructions for setting up all required databases for the Vasuki metatranscriptomic analysis pipeline.

## Overview

Vasuki requires several databases for comprehensive annotation of metatranscriptomic data:

1. **UniProt Database** - Universal protein functional annotation
2. **JGI Database** - Fungal genome/proteome sequences  
3. **NCBI Database** - Bacterial protein sequences
4. **CAZy Database** - Carbohydrate-active enzymes
5. **KEGG Database** - Pathway and orthology information
6. **Plant Reference** - Host genome for read filtering
7. **SortMeRNA Database** - rRNA detection and removal

## Directory Structure

Create the following directory structure in your workspace:

```
database/
├── jgi/                          # JGI fungal proteomes
├── uniprot/                      # UniProt database
├── ncbi/                         # NCBI bacterial database
├── cazy/                         # CAZy enzyme database
├── kegg/                         # KEGG pathway/orthology data
├── plant_genomes/                # Host reference genomes
├── sortmerna/                    # SortMeRNA rRNA databases
└── megan/                        # MEGAN taxonomy files
```

## Database Setup Instructions

### 1. UniProt Database Setup

**Purpose:** Functional annotation and KEGG orthology mapping

**Download:**
```bash
# Create directory
mkdir -p database/uniprot

# Download UniProt Swiss-Prot (curated)
cd database/uniprot
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz

# Download UniProt TrEMBL (larger, less curated)
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz

# Combine databases (optional - for comprehensive coverage)
gunzip *.fasta.gz
cat uniprot_sprot.fasta uniprot_trembl.fasta > uniprot_combined.fasta

# Create DIAMOND database
diamond makedb --in uniprot_sprot.fasta --db uniprot_sprot
```

**Required Files:**
- `uniprot_sprot.fasta` (or `uniprot_combined.fasta`)
- `uniprot_sprot.dmnd` (DIAMOND index)

### 2. JGI Database Setup

**Purpose:** Fungal protein annotation and taxonomy

**Prerequisites:**
- JGI Portal account (https://genome.jgi.doe.gov/)
- JGI download configuration file

**Setup JGI Configuration:**
```bash
# Create JGI config file
cat > jgi_download.config << EOF
username=your_jgi_username
password=your_jgi_password
EOF
```

**Download JGI Proteomes:**
```bash
mkdir -p database/jgi

# Create organism ID list (example fungi)
cat > fungi_ids_list.txt << EOF
12345
12346
12347
EOF

# Download using provided script
python scripts/jgi_download.py --config jgi_download.config --ids fungi_ids_list.txt --output database/jgi/

# Combine all proteomes
cat database/jgi/*.faa > database/jgi/jgi_combined.fasta

# Create DIAMOND database
cd database/jgi
diamond makedb --in jgi_combined.fasta --db jgi_combined
```

**Required Files:**
- `jgi_combined.fasta`
- `jgi_combined.dmnd`
- `Final_correct_jgi_taxonomy.txt` (taxonomy mapping)

### 3. NCBI Database Setup

**Purpose:** Bacterial protein annotation

**Download:**
```bash
mkdir -p database/ncbi

# Download NCBI nr database (large - ~200GB)
cd database/ncbi
wget https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz

# Or download bacterial subset (recommended)
wget https://ftp.ncbi.nlm.nih.gov/refseq/release/bacteria/bacteria.*.protein.faa.gz

# Combine bacterial files
gunzip bacteria.*.protein.faa.gz
cat bacteria.*.protein.faa > bacteria_combined.fasta

# Create DIAMOND database
diamond makedb --in bacteria_combined.fasta --db bacteria_combined

# Download taxonomy information
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip
unzip taxdmp.zip
```

**Required Files:**
- `bacteria_combined.fasta`
- `bacteria_combined.dmnd`
- `nodes.dmp`, `names.dmp` (taxonomy)
- `taxids_taxanomy_nr_bac_edit.tsv` (processed taxonomy)

### 4. CAZy Database Setup

**Purpose:** Carbohydrate-active enzyme classification

**Download:**
```bash
mkdir -p database/cazy

# Download dbCAN CAZy database
cd database/cazy
wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-HMMdb-V11.txt
wget http://bcb.unl.edu/dbCAN2/download/Databases/CAZyDB.07302020.fasta

# Rename for pipeline compatibility
mv CAZyDB.07302020.fasta cazy.fa

# Create DIAMOND database
diamond makedb --in cazy.fa --db cazy
```

**Required Files:**
- `cazy.fa`
- `cazy.dmnd`
- `dbCAN-HMMdb-V11.txt` (HMM profiles)

### 5. KEGG Database Setup

**Purpose:** Pathway and orthology annotation

**Note:** KEGG requires a license for academic use

**Download (with license):**
```bash
mkdir -p database/kegg

# Download KEGG databases (requires subscription)
# Contact KEGG for access: https://www.kegg.jp/kegg/download/

# Required files (obtain from KEGG):
# - ko_genes.list (KO to gene mapping)
# - pathway.list (pathway definitions)
# - uniprot2ko.txt (UniProt to KO mapping)

# Alternative: Use free KEGG orthology mappings
wget http://rest.kegg.jp/list/ko -O database/kegg/ko_list.txt
```

**Required Files:**
- `ko_genes.list`
- `pathway.list`
- `uniprot2ko.txt`
- `KEGG_Pathways.tab`

### 6. Plant Reference Genome Setup

**Purpose:** Host read filtering

**Example (Alnus/Alder genome):**
```bash
mkdir -p database/plant_genomes/alnus

# Download plant reference genome
cd database/plant_genomes/alnus
# Replace with actual genome URL
wget https://example.com/alnus_genome.fasta.gz
gunzip alnus_genome.fasta.gz
mv alnus_genome.fasta alnus_genome.fna

# Build Bowtie2 index
bowtie2-build alnus_genome.fna alnus_index
```

**Required Files:**
- `alnus_genome.fna` (reference genome)
- `alnus_index.*.bt2` (Bowtie2 indices)

### 7. SortMeRNA Database Setup

**Purpose:** rRNA detection and removal

**Download:**
```bash
mkdir -p database/sortmerna

# Download SortMeRNA databases
cd database/sortmerna
wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz
tar -xzf database.tar.gz

# Index databases for SortMeRNA
for db in *.fasta; do
    sortmerna --ref $db --index 1 --workdir .
done
```

**Required Files:**
- Various rRNA database files (`.fasta`)
- Corresponding index files

### 8. MEGAN Database Setup

**Purpose:** Taxonomic analysis

**Download:**
```bash
mkdir -p database/megan

# Download MEGAN mapping files
cd database/megan
wget https://software-ab.informatik.uni-tuebingen.de/download/megan6/megan-map-Jul2020-2.db.zip
unzip megan-map-Jul2020-2.db.zip

# Download NCBI taxonomy
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip
unzip taxdmp.zip
```

**Required Files:**
- `megan-map-Jul2020-2.db` (MEGAN mapping database)
- `nodes.dmp`, `names.dmp` (NCBI taxonomy)

## Database Verification

After setting up databases, verify they are properly configured:

### Check File Integrity
```bash
# Verify DIAMOND databases
diamond dbinfo --db database/uniprot/uniprot_sprot.dmnd
diamond dbinfo --db database/jgi/jgi_combined.dmnd
diamond dbinfo --db database/ncbi/bacteria_combined.dmnd
diamond dbinfo --db database/cazy/cazy.dmnd

# Verify Bowtie2 indices
ls database/plant_genomes/alnus/alnus_index.*.bt2

# Check file sizes
du -sh database/*/
```

### Test Database Searches
```bash
# Test DIAMOND search
diamond blastp --db database/uniprot/uniprot_sprot.dmnd --query test_sequences.fasta --out test_results.tsv

# Test Bowtie2 mapping
bowtie2 -x database/plant_genomes/alnus/alnus_index -1 test_R1.fastq -2 test_R2.fastq -S test_mapping.sam
```

## Database Maintenance

### Regular Updates

**Monthly:**
- Check for UniProt updates
- Update CAZy database

**Quarterly:**
- Update NCBI databases
- Refresh JGI organism lists
- Update MEGAN mappings

**Annually:**
- Major KEGG updates (if licensed)
- Plant reference genome updates

### Update Scripts

Create automated update scripts:

```bash
#!/bin/bash
# update_databases.sh

echo "Updating UniProt database..."
cd database/uniprot
wget -N https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip -f uniprot_sprot.fasta.gz
diamond makedb --in uniprot_sprot.fasta --db uniprot_sprot

echo "Updating CAZy database..."
cd ../cazy
wget -N http://bcb.unl.edu/dbCAN2/download/Databases/CAZyDB.07302020.fasta
mv CAZyDB.07302020.fasta cazy.fa
diamond makedb --in cazy.fa --db cazy

echo "Database updates complete!"
```

## Storage Requirements

Estimate storage needs for databases:

| Database | Size (Compressed) | Size (Uncompressed) | Index Size |
|----------|------------------|---------------------|------------|
| UniProt SwissProt | 300 MB | 1.2 GB | 2 GB |
| UniProt TrEMBL | 20 GB | 80 GB | 100 GB |
| JGI Combined | 2 GB | 8 GB | 10 GB |
| NCBI Bacteria | 15 GB | 60 GB | 80 GB |
| CAZy | 50 MB | 200 MB | 500 MB |
| Plant Genome | 100 MB | 400 MB | 1 GB |
| SortMeRNA | 500 MB | 2 GB | 3 GB |
| **Total** | **~40 GB** | **~150 GB** | **~200 GB** |

**Recommended Storage:** 500 GB for databases and intermediate files

## Troubleshooting

### Common Issues

1. **Download Failures**
   - Check internet connection
   - Verify URLs are current
   - Use resume options for large files

2. **Index Building Errors**
   - Ensure sufficient disk space
   - Check memory availability
   - Verify input file integrity

3. **Permission Issues**
   - Set appropriate file permissions
   - Check directory write access

4. **Version Compatibility**
   - Match database versions with tools
   - Update tool versions if needed

### Performance Optimization

1. **SSD Storage:** Use SSD for database storage when possible
2. **Memory:** Allocate sufficient RAM for index building
3. **Parallel Downloads:** Use parallel download tools for large databases
4. **Compression:** Keep compressed versions for backup

## Configuration Integration

Update your Vasuki configuration file with database paths:

```yaml
# Database configuration
database_dir: "database/"
uniprot_db: "database/uniprot/uniprot_sprot.dmnd"
jgi_db: "database/jgi/jgi_combined.dmnd"
ncbi_db: "database/ncbi/bacteria_combined.dmnd"
cazy_db: "database/cazy/cazy.dmnd"
plant_index: "database/plant_genomes/alnus/alnus_index"
sortmerna_db: "database/sortmerna/"
megan_db: "database/megan/megan-map-Jul2020-2.db"

# KEGG files
KO_list_file: "database/kegg/ko_genes.list"
KEGG_pathways: "database/kegg/pathway.list"
uniprot2ko_mapping: "database/kegg/uniprot2ko.txt"
```

This comprehensive database setup will provide the foundation for accurate and comprehensive metatranscriptomic analysis with Vasuki.