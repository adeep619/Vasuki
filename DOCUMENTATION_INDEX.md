# Vasuki Documentation Index

Welcome to the comprehensive documentation for Vasuki, a metatranscriptomic analysis pipeline. This index provides an organized overview of all available documentation.

## Quick Start
- 📖 **[README.md](readme.md)** - Main overview, features, and quick start guide
- 🚀 **[INSTALLATION.md](INSTALLATION.md)** - Complete installation instructions
- ⚙️ **[CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md)** - Configuration setup and examples

## Detailed Documentation

### Setup and Installation
- **[INSTALLATION.md](INSTALLATION.md)** (456 lines)
  - System requirements and dependencies
  - Multiple installation methods (Conda, manual, containers)
  - Platform-specific instructions (Ubuntu, CentOS, macOS, HPC)
  - Troubleshooting and verification

- **[DATABASE_SETUP.md](DATABASE_SETUP.md)** (395 lines)
  - Required databases (UniProt, JGI, NCBI, CAZy, KEGG)
  - Step-by-step download and setup instructions
  - Database maintenance and updates
  - Storage requirements and optimization

### Configuration and Usage
- **[CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md)** (270 lines)
  - Detailed configuration file structure
  - Sample configurations for different use cases
  - Performance parameter tuning
  - Environment-specific configurations

### Pipeline Details
- **[PIPELINE_WORKFLOW.md](PIPELINE_WORKFLOW.md)** (366 lines)
  - Complete workflow documentation
  - Step-by-step process description
  - Rule dependencies and data flow
  - Performance considerations and optimization

## Documentation Summary

| Document | Purpose | Lines | Key Topics |
|----------|---------|-------|------------|
| [README.md](readme.md) | Overview & Quick Start | 185 | Features, installation, basic usage |
| [INSTALLATION.md](INSTALLATION.md) | Setup Guide | 456 | Dependencies, installation methods, troubleshooting |
| [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md) | Configuration | 270 | Config files, parameters, examples |
| [PIPELINE_WORKFLOW.md](PIPELINE_WORKFLOW.md) | Workflow Details | 366 | Pipeline steps, rules, data flow |
| [DATABASE_SETUP.md](DATABASE_SETUP.md) | Database Setup | 395 | Database downloads, indexing, maintenance |

**Total Documentation:** 1,672 lines across 5 comprehensive guides

## Getting Started Workflow

For new users, follow this recommended reading order:

1. **Start Here:** [README.md](readme.md)
   - Understand what Vasuki does
   - Review features and requirements
   - Run through quick start example

2. **Install:** [INSTALLATION.md](INSTALLATION.md)
   - Choose installation method
   - Install dependencies and tools
   - Verify installation

3. **Setup Databases:** [DATABASE_SETUP.md](DATABASE_SETUP.md)
   - Download required databases
   - Build database indices
   - Verify database integrity

4. **Configure:** [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md)
   - Create configuration file
   - Set parameters for your data
   - Optimize for your system

5. **Run Pipeline:** [PIPELINE_WORKFLOW.md](PIPELINE_WORKFLOW.md)
   - Understand workflow steps
   - Monitor pipeline execution
   - Interpret results

## Key Features Covered

### ✅ Complete Installation Guide
- Multiple installation methods
- Platform-specific instructions
- Dependency management
- Troubleshooting procedures

### ✅ Comprehensive Database Setup
- All required databases documented
- Download and setup scripts
- Maintenance procedures
- Storage optimization

### ✅ Detailed Configuration
- Full parameter documentation
- Example configurations
- Performance tuning
- Environment-specific settings

### ✅ Workflow Documentation
- Step-by-step pipeline description
- Rule dependencies
- Data flow diagrams
- Performance considerations

### ✅ User-Friendly Organization
- Clear navigation structure
- Cross-referenced documentation
- Practical examples
- Troubleshooting guides

## Pipeline Capabilities

Vasuki provides comprehensive metatranscriptomic analysis including:

- **Quality Control:** FastQC, Cutadapt trimming
- **Host Filtering:** Plant/host read removal
- **Assembly:** Trinity or SPAdes options
- **Quantification:** Salmon abundance estimation
- **Functional Annotation:** UniProt, JGI, NCBI, CAZy databases
- **Taxonomic Classification:** MEGAN-based analysis
- **Pathway Analysis:** KEGG orthology and pathways
- **Result Integration:** Automated merging and reporting

## Support and Maintenance

### Documentation Maintenance
- Regular updates with pipeline changes
- Version compatibility notes
- User feedback integration
- Best practices updates

### Getting Help
- Check troubleshooting sections in each guide
- Verify configuration against examples
- Review installation verification steps
- Consult tool-specific documentation

## Contributing to Documentation

To improve or update documentation:
1. Follow the established structure and style
2. Include practical examples
3. Test all instructions
4. Update cross-references
5. Maintain the documentation index

---

**Last Updated:** August 29, 2024  
**Documentation Version:** 1.0  
**Pipeline Compatibility:** Vasuki v2.0+

This comprehensive documentation provides everything needed to successfully install, configure, and run the Vasuki metatranscriptomic analysis pipeline.