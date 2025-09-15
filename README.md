# 16_PRJ_ANALYSIS

> Complete meta-analysis of NCBI SRA database for sugarcane under water deficit.

---

## 📘 Overview

**16_PRJ_ANALYSIS** is a repository for all scripts used for the Meta-Analysis of projects in the [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra) database for sugarcane under contrasting Water Regimes.

---

## 🛠️ Usage
- Most of the scripts require high computational resources and were writen to run jobs with [Son of Grid Engine (SGE)](https://wiki.archlinux.org/title/Son_of_Grid_Engine).

### [Star Genome Generate](/SCRIPTS/STAR_GENOMEGENERATE.sh) **(SGE)**
- **THIS SCRIPT HAS TO BE EXECUTED FROM THE MAIN FOLDER.**
- This script uses Genome/Transcriptome (not provided) to create the STAR genome reference for further steps.

### [Data Retrieval and STAR Quantification](/SCRIPTS/STAR_RETRIEVAL_QUANT.sh) **(SGE)**
- **THIS SCRIPT REQUIRES [STAR GENOME](#star-genome-generate-sge)** before it can be executed.
- **THIS SCRIPT HAS TO BE EXECUTED FROM INSIDE "16_PRJ_ANALYSIS/PROJECTS" folder since it uses relative path.**
- The script reads all available folders with fixed structure [see below](#-project-structure), each folder represents one of the 16 projects previously selected.
- Each folder (for each of the 16 projects) have one file with Access Number information (SRR_Acc_List.txt), which is the main file for reads information.
- After data retrieval, the script will run [FastP](https://pmc.ncbi.nlm.nih.gov/articles/PMC6129281/) for cleaning and generation of quality reports.
- After cleaning, the script then run [STAR](https://github.com/alexdobin/STAR) for generating quantification tables.
- Finally, the script runs [MULTIQC](https://github.com/MultiQC/MultiQC) for generating general report and [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) for individual reports.
- All logs are saved and the reads are removed for cleaning space.

### [Salmon Indexing](/SCRIPTS/SALMON_INDEX.sh) **(SGE)**
- **THIS SCRIPT HAS TO BE EXECUTED FROM THE MAIN FOLDER.**
- This script uses Genome/Transcriptome (not provided) to create the Salmon Index for further steps.

### [Data Retrieval and Salmon Quantification](/SCRIPTS/SALMON_RETRIEVAL_QUANT.sh) **(SGE)**
- **THIS SCRIPT REQUIRES [SALMON INDEX](#salmon-indexing-sge)** before it can be executed.
- **THIS SCRIPT HAS TO BE EXECUTED FROM INSIDE "16_PRJ_ANALYSIS/PROJECTS" folder since it uses relative path.**
- The script reads all available folders with fixed structure [see below](#-project-structure), each folder represents one of the 16 projects previously selected.
- Each folder (for each of the 16 projects) have one file with Access Number information (SRR_Acc_List.txt), which is the main file for reads information.
- After data retrieval, the script will run [FastP](https://pmc.ncbi.nlm.nih.gov/articles/PMC6129281/) for cleaning and generation of quality reports.
- After cleaning, the script then run [SALMON](https://salmon.readthedocs.io/en/latest/) for generating quantification tables.
- Finally, the script runs [MULTIQC](https://github.com/MultiQC/MultiQC) for generating general report and [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) for individual reports.
- All logs are saved and the reads are removed for cleaning space.

### [Salmon All Genomes](/SCRIPTS/SALMON_ALLGENOMES.sh) **(SGE)**
- **THIS SCRIPT HAS TO BE EXECUTED FROM THE MAIN FOLDER.**
- **THIS SCRIPT REQUIRES [SALMON INDEX](#salmon-indexing-sge)** before it can be executed.
- The script runs Salmon Quantification for all desired genomes with a SINGLE PROJECT, and must be adapted to be run with each required project.

### [Generate Histogram for Genomes Comparison](/SCRIPTS/MISC_FULL_GENOMES_HISTOGRAM.r)
- R script for visualization of the genomes comparisons.
- It requires the data table [(EXAMPLE)](/EXAMPLE_DATA/RES_DEG_SUMMARY.csv).

### [Generate Diverging Bar Plots](/SCRIPTS/MISC_DIVERGING_BAR_PLOT.r)
- R script for generating diverging bar plots.
- This script is provided as reference only, the table used for this analysis is retained because it contains unpublished information, there is an [example of the table available](/EXAMPLE_DATA/NET_TABLE.csv) but the script is fully adaptable for any analysis of your own.

### [Generate Heatmap for genes involved in desired KEGG Pathways](/SCRIPTS/MISC_KEGG_EXP.r)
- R script for visualization of heatmaps of genes involved in desired KEGG pathway.
- This script uses the pathways [example table](/EXAMPLE_DATA/16_FREQKEGG.csv), however, the main table used for this analysis is retained because it contains unpublished information, there is an [example of the table available](/EXAMPLE_DATA/NET_TABLE.csv) but the script is fully adaptable for any analysis of your own.
- This script is clustered by the analysis, it is not continuous and contains different snippets for different purposes (as documentated).

### [Intersections analysis](/SCRIPTS/MISC_UPSET.py)
- Python script for complete analysis of intersections between the 16 projects.
- This script is provided as reference only, the table used for this analysis is retained because it contains unpublished information, there is an [example of the table available](/EXAMPLE_DATA/NET_TABLE.csv) but the script is fully adaptable for any analysis of your own.

### [Generate UPSET plot for intersection analysis](/SCRIPTS/MISC_UPSET_STATISTICS.r)
- **THIS SCRIPT REQUIRES FILES FROM THE [UPSET MAIN ANALYSIS](#intersections-analysis)**
- R script for statistical analysis of the intersections.
- The table used in this script [(Intersections 16 Projects)](/EXAMPLE_DATA/16_INTERSECTIONS.tsv) is generated prior to the script execution.
- The files for the subfolder "GENES_SHARED" is generated prior to the script execution.
- Thie file with example [IDS](/EXAMPLE_DATA/IDS.txt) is provided as example.
- This script is provided as reference only, the table used for this analysis is retained because it contains unpublished information, there is an [example of the table available](/EXAMPLE_DATA/NET_TABLE.csv) but the script is fully adaptable for any analysis of your own.

---

## 📂 Project Structure
```markdown
16_PRJ_ANALYSIS/
├── EXAMPLE_DATA/
│   ├── 16_FREQKEGG.csv
│   ├── 16_INTERSECTIONS.tsv
│   ├── IDS.txt
│   ├── NET_TABLE.csv
│   └── RES_DEG_SUMMARY.csv
├── LICENSE
├── PROJECTS/
│   ├── PRJNA182108/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA419791/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA427493/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA549834/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA590281/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA590595/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA598295/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA628529/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA684430/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA776107/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA854329/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA882367/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA885747/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA937025/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   ├── PRJNA975299/
│   │   ├── contrast.txt
│   │   ├── sampleinfo.txt
│   │   ├── SRR_Acc_Listp.txt
│   │   ├── SRR_Acc_Lists.txt
│   │   └── SRR_Acc_List.txt
│   └── PRJEB41560/
│       ├── contrast.txt
│       ├── sampleinfo.txt
│       ├── SRR_Acc_Listp.txt
│       ├── SRR_Acc_Lists.txt
│       └── SRR_Acc_List.txt
├── PROJECTS_LIST.txt
├── README.md
└── SCRIPTS/
    ├── MISC_DIVERGING_BAR_PLOT.r
    ├── MISC_FULL_GENOMES_HISTOGRAM.r
    ├── MISC_KEGG_EXP.r
    ├── MISC_UPSET.py
    ├── MISC_UPSET_STATISTICS.r
    ├── SALMON_ALLGENOMES.sh
    ├── SALMON_INDEX.sh
    ├── SALMON_RETRIEVAL_QUANT.sh
    ├── STAR_GENOMEGENERATE.sh
    └── STAR_RETRIEVAL_QUANT.sh

```

## Under the subfolder (PROJECTS) each of the 16 projects are listed with fixed structure for five files:
- The file "contrasts.txt" contains the contrast name retrieved from the Metadata from the SRA database (all represents drought contrasts but with different names for different projects).
- The file "samplefinfo.txt" contains all the Metadata retrieved from the SRA database.
- The files "SRR_Acc_list.txt", "SRR_Acc_Lists.txt" and "SRR_Acc_Listp.txt" represents all the reads for each project, split for single/paired ended reads since some projects mix both.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---
