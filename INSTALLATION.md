# Vasuki Installation Guide

This guide provides step-by-step instructions for installing Vasuki and all its dependencies on various systems.

## System Requirements

### Minimum Requirements
- **OS:** Linux (Ubuntu 18.04+, CentOS 7+) or macOS 10.14+
- **CPU:** 8 cores
- **RAM:** 32 GB
- **Storage:** 100 GB free space
- **Python:** 3.7+

### Recommended Requirements
- **OS:** Linux (Ubuntu 20.04+)
- **CPU:** 32+ cores
- **RAM:** 128+ GB
- **Storage:** 1 TB free space (500 GB for databases)
- **Python:** 3.8+

## Installation Methods

### Method 1: Conda/Mamba Installation (Recommended)

#### Step 1: Install Conda/Mamba

If you don't have Conda installed:
```bash
# Download Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Or install Mamba (faster)
conda install mamba -n base -c conda-forge
```

#### Step 2: Create Vasuki Environment

```bash
# Clone the repository
git clone https://github.com/your-username/vasuki.git
cd vasuki

# Create environment using the provided file
conda create --name vasuki --file metatrans.yaml

# Activate environment
conda activate vasuki
```

#### Step 3: Verify Installation

```bash
# Check Snakemake
snakemake --version

# Check key tools
diamond version
bowtie2 --version
salmon --version
```

### Method 2: Manual Installation

#### Step 1: Install Core Dependencies

**Python packages:**
```bash
pip install snakemake>=6.0
pip install pandas numpy biopython
pip install pyyaml configargparse
```

**System tools (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y build-essential wget curl git
sudo apt install -y zlib1g-dev libbz2-dev liblzma-dev
```

**System tools (CentOS/RHEL):**
```bash
sudo yum groupinstall "Development Tools"
sudo yum install -y wget curl git zlib-devel bzip2-devel xz-devel
```

#### Step 2: Install Bioinformatics Tools

**FastQC:**
```bash
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc_v0.11.9.zip
chmod +x FastQC/fastqc
# Add to PATH
export PATH=$PATH:/path/to/FastQC
```

**Cutadapt:**
```bash
pip install cutadapt
```

**Bowtie2:**
```bash
wget https://github.com/BenLangmead/bowtie2/releases/download/v2.4.5/bowtie2-2.4.5-linux-x86_64.zip
unzip bowtie2-2.4.5-linux-x86_64.zip
export PATH=$PATH:/path/to/bowtie2-2.4.5-linux-x86_64
```

**DIAMOND:**
```bash
wget https://github.com/bbuchfink/diamond/releases/download/v2.0.15/diamond-linux64.tar.gz
tar xzf diamond-linux64.tar.gz
chmod +x diamond
# Move to system PATH
sudo mv diamond /usr/local/bin/
```

**Trinity (if using Trinity assembly):**
```bash
wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/Trinity-v2.13.2/trinityrnaseq-v2.13.2.FULL.tar.gz
tar xzf trinityrnaseq-v2.13.2.FULL.tar.gz
cd trinityrnaseq-v2.13.2
make
export PATH=$PATH:/path/to/trinityrnaseq-v2.13.2
```

**SPAdes:**
```bash
wget https://github.com/ablab/spades/releases/download/v3.15.5/SPAdes-3.15.5-Linux.tar.gz
tar xzf SPAdes-3.15.5-Linux.tar.gz
export PATH=$PATH:/path/to/SPAdes-3.15.5-Linux/bin
```

**Salmon:**
```bash
wget https://github.com/COMBINE-lab/salmon/releases/download/v1.7.0/salmon-1.7.0_linux_x86_64.tar.gz
tar xzf salmon-1.7.0_linux_x86_64.tar.gz
export PATH=$PATH:/path/to/salmon-latest_linux_x86_64/bin
```

**SortMeRNA:**
```bash
wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/sortmerna-4.3.4-Linux.sh
bash sortmerna-4.3.4-Linux.sh
# Follow installation prompts
```

### Method 3: Container Installation

#### Using Singularity

```bash
# Build Singularity container
singularity build vasuki.sif docker://your-registry/vasuki:latest

# Run pipeline with Singularity
singularity exec vasuki.sif snakemake -j 50 -s Snakefile.smk --configfile config.yaml
```

#### Using Docker

```bash
# Build Docker image
docker build -t vasuki:latest .

# Run pipeline with Docker
docker run -v /path/to/data:/data -v /path/to/results:/results vasuki:latest \
    snakemake -j 50 -s Snakefile.smk --configfile /data/config.yaml
```

## Special Software Installation

### MEGAN6 Installation

MEGAN is required for taxonomic analysis but requires separate installation:

```bash
# Download MEGAN (requires registration)
# Visit: https://software-ab.informatik.uni-tuebingen.de/download/megan6/

# Extract and install
tar xzf MEGAN_Community_unix_6_21_7.tar.gz
cd megan

# Add to PATH
export PATH=$PATH:/path/to/megan

# Verify installation
MEGAN -h
```

### JGI Tools Installation

For JGI database downloads:

```bash
# The pipeline includes JGI download scripts
# No additional installation needed, but requires JGI account
```

## Environment Configuration

### Setting Up Environment Variables

Create a configuration file for easy environment setup:

```bash
# Create vasuki_env.sh
cat > vasuki_env.sh << 'EOF'
#!/bin/bash
# Vasuki Environment Configuration

# Core paths
export VASUKI_HOME="/path/to/vasuki"
export VASUKI_DB="/path/to/vasuki/database"

# Tool paths (adjust as needed)
export PATH=$PATH:/path/to/FastQC
export PATH=$PATH:/path/to/bowtie2
export PATH=$PATH:/path/to/trinityrnaseq
export PATH=$PATH:/path/to/SPAdes/bin
export PATH=$PATH:/path/to/salmon/bin
export PATH=$PATH:/path/to/megan

# Database paths
export UNIPROT_DB="$VASUKI_DB/uniprot/uniprot_sprot.dmnd"
export JGI_DB="$VASUKI_DB/jgi/jgi_combined.dmnd"
export NCBI_DB="$VASUKI_DB/ncbi/bacteria_combined.dmnd"
export CAZY_DB="$VASUKI_DB/cazy/cazy.dmnd"

# Performance settings
export NUMEXPR_MAX_THREADS=32
export OMP_NUM_THREADS=32

echo "Vasuki environment configured!"
EOF

# Make executable and source
chmod +x vasuki_env.sh
source vasuki_env.sh
```

## Platform-Specific Instructions

### Ubuntu/Debian

```bash
# Install dependencies
sudo apt update
sudo apt install -y python3-pip python3-venv
sudo apt install -y build-essential cmake
sudo apt install -y libssl-dev libffi-dev python3-dev
sudo apt install -y zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev

# Install Conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Follow Method 1 above
```

### CentOS/RHEL

```bash
# Enable EPEL repository
sudo yum install -y epel-release

# Install dependencies
sudo yum groupinstall -y "Development Tools"
sudo yum install -y python3-pip python3-devel
sudo yum install -y openssl-devel libffi-devel
sudo yum install -y zlib-devel bzip2-devel xz-devel ncurses-devel

# Install Conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Follow Method 1 above
```

### macOS

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python@3.9
brew install cmake
brew install zlib bzip2 xz

# Install Conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh

# Follow Method 1 above
```

### HPC/Cluster Systems

For HPC environments with module systems:

```bash
# Load required modules (example for SLURM)
module load python/3.8
module load conda/4.10
module load gcc/9.3.0

# Create environment
conda create --name vasuki --file metatrans.yaml
conda activate vasuki

# Create submission script
cat > vasuki_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=vasuki
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem=500G
#SBATCH --time=48:00:00

module load conda/4.10
conda activate vasuki

snakemake -j $SLURM_NTASKS -s Snakefile.smk \
    --configfile config.yaml \
    --cluster "sbatch -N 1 -n {threads} --mem={resources.mem_mb}M -t {resources.runtime}" \
    --jobs 10
EOF
```

## Verification and Testing

### Quick Installation Test

```bash
# Clone test data (if available)
git clone https://github.com/your-username/vasuki-test-data.git

# Run pipeline test
cd vasuki
snakemake -n -s Snakefile.smk --configfile config_test.yaml

# This should show the pipeline DAG without errors
```

### Comprehensive Test

```bash
# Run small test dataset
snakemake -j 4 -s Snakefile.smk --configfile config_test.yaml --until qc

# Check outputs
ls results_test/qc/
```

## Troubleshooting Installation

### Common Issues

#### 1. Conda Environment Creation Fails

**Error:** Package conflicts or missing packages
**Solution:**
```bash
# Try with mamba (faster resolver)
mamba create --name vasuki --file metatrans.yaml

# Or install packages individually
conda create --name vasuki python=3.8
conda activate vasuki
conda install snakemake diamond-aligner bowtie2 salmon cutadapt fastqc -c bioconda
```

#### 2. Tool Not Found Errors

**Error:** Command not found for bioinformatics tools
**Solution:**
```bash
# Check tool installation
which diamond
which bowtie2

# Add to PATH if needed
export PATH=$PATH:/path/to/tool/bin

# Make permanent by adding to ~/.bashrc
echo 'export PATH=$PATH:/path/to/tool/bin' >> ~/.bashrc
```

#### 3. Memory Issues During Installation

**Error:** Out of memory during package installation
**Solution:**
```bash
# Increase virtual memory
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Or install packages one by one
conda install snakemake
conda install diamond-aligner
# etc.
```

#### 4. Permission Issues

**Error:** Permission denied errors
**Solution:**
```bash
# Fix ownership
sudo chown -R $USER:$USER /path/to/vasuki

# Set proper permissions
chmod -R 755 /path/to/vasuki
chmod +x /path/to/vasuki/scripts/*.py
```

### Getting Help

1. **Check tool versions:** Ensure all tools are compatible versions
2. **Review logs:** Check conda/pip installation logs for specific errors
3. **System resources:** Verify sufficient disk space and memory
4. **Dependencies:** Ensure all system dependencies are installed

## Post-Installation Setup

After successful installation:

1. **Set up databases** (see DATABASE_SETUP.md)
2. **Configure pipeline** (see CONFIGURATION_GUIDE.md)
3. **Test with sample data**
4. **Set up regular maintenance scripts**

## Performance Optimization

### System Tuning

```bash
# Optimize for bioinformatics workloads
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'kernel.shmmax=68719476736' | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p
```

### Storage Optimization

- Use SSD storage for databases and temporary files
- Configure separate storage for large intermediate files
- Set up automated cleanup of temporary files

This installation guide should get you up and running with Vasuki. For platform-specific issues, consult your system administrator or the tool-specific documentation.