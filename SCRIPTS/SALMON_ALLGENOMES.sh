#!/bin/bash
#$ -V
#$ -cwd
#$ -pe smp 20
echo "Download SRAs:"
date
mkdir -p ./PROJECTS/PRJNA882367/LOGS
ulimit -Sn 4000
echo "FASTP initiated:"
date
module load fastp/0.23.2
mkdir -p ./PROJECTS/PRJNA882367/REPORTS
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; fastp -i ./PROJECTS/PRJNA882367/READS/"${line}"_1.fastq -I ./PROJECTS/PRJNA882367/READS/"${line}"_2.fastq -o ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -O ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq -h ./PROJECTS/PRJNA882367/REPORTS/"${line}".html -j ./PROJECTS/PRJNA882367/REPORTS/"${line}".json &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_FASTPP.txt; done
module unload fastp/0.23.2
echo "FASTP done:"
date
echo "Salmon QUANT initiated:"
date
ulimit -Sn 4000
module load salmon/1.8.0
echo "Salmon QUANT COMPGG initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/COMPGG_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_COMPGG --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_COMPGG_SALMON.txt; done
echo "Salmon QUANT COMPGG done:"
date
echo "Salmon QUANT XTT22 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/XTT22_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_XTT22 --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_XTT22_SALMON.txt; done
echo "Salmon QUANT XTT22 done:"
date
echo "Salmon QUANT AP85 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/AP85_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_AP85 --threads 10 --seqBias --gcBias &> ./POJECTS/PRJNA882367/LOGS/"${line}"_AP85_SALMON.txt; done
echo "Salmon QUANT AP85 done:"
date
echo "Salmon QUANT LAPURPLE initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/LAPURPLE_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_LAPURPLE --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_LAPURPLE_SALMON.txt; done
echo "Salmon QUANT LAPURPLE done:"
date
echo "Salmon QUANT NPX initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/NPX_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_NPX --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_NPX_SALMON.txt; done
echo "Salmon QUANT NPX done:"
date
echo "Salmon QUANT R570 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/R570_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_R570 --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_R570_SALMON.txt; done
echo "Salmon QUANT R570 done:"
date
echo "Salmon QUANT YN2009 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/YN2009_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_YN2009 --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_YN2009_SALMON.txt; done
echo "Salmon QUANT YN2009 done:"
date
echo "Salmon QUANT YN83 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/YN83_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_YN83 --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_YN83_SALMON.txt; done
echo "Salmon QUANT YN83 done:"
date
echo "Salmon QUANT ZZ1 initiated:"
date
cat ./PROJECTS/PRJNA882367/SRR_Acc_List.txt | while read line; do echo "${line}"; salmon quant -i ./SALMON/ZZ1_index -l A -1 ./PROJECTS/PRJNA882367/READS/"${line}"_1_tr.fastq -2 ./PROJECTS/PRJNA882367/READS/"${line}"_2_tr.fastq --validateMappings -o ./PROJECTS/PRJNA882367/QUANT/"${line}"_ZZ1 --threads 10 --seqBias --gcBias &> ./PROJECTS/PRJNA882367/LOGS/"${line}"_ZZ1_SALMON.txt; done
echo "Salmon QUANT ZZ1 done:"
date
module unload salmon/1.8.0
echo "Salmon QUANT finished:"
date
echo "MULTIQC initiated:"
date
mkdir -p ./PROJECTS/PRJNA882367/MULTIQC_SALMON
module load MultiQC/1.8
multiqc ./PROJECTS/PRJNA882367/QUANT/ --outdir ./PROJECTS/PRJNA882367/MULTIQC_SALMON/
module unload MultiQC/1.8
echo "MULTIQC done:"
date
echo "FASTQC initiated:"
date
mkdir -p ./PROJECTS/PRJNA882367/fastqc
module load FastQC/0.11.8
fastqc -o ./PROJECTS/PRJNA882367/fastqc/ ./PROJECTS/PRJNA882367/READS/*.fq &> ./PROJECTS/PRJNA882367/LOGS/FASTQC.txt
module unload FastQC/0.11.8
echo "FASTQC done:"
date
