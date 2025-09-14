# 16_PRJ_ANALYSIS

> Complete meta-analysis of NCBI SRA database for sugarcane under water deficit.

---

## 📘 Overview

**16_PRJ_ANALYSIS** is a repository for all scripts used for the Meta-Analysis of projects in the [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra) database for sugarcane under contrasting Water Regimes.

---

## 🛠️ Usage
- Most of the scripts require high computational resources and were writen to run jobs with [Son of Grid Engine (SGE)](https://wiki.archlinux.org/title/Son_of_Grid_Engine)
### Data Retrieval and Salmon Quantification (SCRIPTS/SALMON_RETRIEVAL_QUANT.sh) **SGE**
- **THIS SCRIPT REQUIRES SALMON INDEX** before it can be executed.
- **THIS SCRIPT HAS TO BE EXECUTED FROM INSIDE "16_PRJ_ANALYSIS/PROJECTS" folder since it uses relative path.**
- The script reads all available folders with fixed structure (see below), each folder represents one of the 16 projects previously selected.
- Each folder (for each of the 16 projects) have one file with Access Number information (SRR_Acc_List.txt), which is the main file for reads information.
- After data retrieval, the script will run [FastP](https://pmc.ncbi.nlm.nih.gov/articles/PMC6129281/) for cleaning and generation of quality reports.
- After cleaning, the script then run [SALMON](https://salmon.readthedocs.io/en/latest/) for generating quantification tables.
- Finally, the script runs [MULTIQC](https://github.com/MultiQC/MultiQC) for generating general report and [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) for individual reports.
- All logs are saved and the reads are removed for cleaning space.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📂 Project Structure
```markdown
16_PRJ_ANALYSIS/
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
└── README.md
```

- Under the subfolder (PROJECTS) each of the 16 projects are listed with fixed structure for five files:
-- The file "contrasts.txt" contains the contrast name retrieved from the Metadata from the SRA database (all represents drought contrasts but with different names for different projects).
-- The file "samplefinfo.txt" contains all the Metadata retrieved from the SRA database.
-- The files "SRR_Acc_list.txt", "SRR_Acc_Lists.txt" and "SRR_Acc_Listp.txt" represents all the reads for each project, split for single/paired ended reads since some projects mix both.
