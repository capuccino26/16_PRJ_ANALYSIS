#!/bin/bash
#$ -V
#$ -cwd
#$ -pe smp 20
for dir in */ ; do
	echo "$dir"
	cd "$dir"
	echo "Download SRAs:"
	date
	mkdir -p ./LOGS
	ulimit -Sn 4000
	module load sratoolkit/3.0.0
	cat SRR_Acc_List.txt | while read line; do echo "${line}"; fasterq-dump "${line}" --outdir ./READS &> ./LOGS/"${line}"_SRA.txt; done
	module unload sratoolkit/3.0.0 
	echo "Finished Download SRAs"
	date
	echo "FASTP PAIRED initiated:"
	date
	module load fastp/0.23.2
	mkdir -p ./REPORTS
	cat SRR_Acc_Listp.txt | while read line; do echo "${line}"; fastp -i ./READS/"${line}"_1.fastq -I ./READS/"${line}"_2.fastq -o ./READS/"${line}"_1_tr.fastq -O ./READS/"${line}"_2_tr.fastq -h ./REPORTS/"${line}".html -j ./REPORTS/"${line}".json &> ./LOGS/"${line}"_COMPGG_FASTPP.txt; done
	module unload fastp/0.23.2
	echo "FASTP PAIRED done:"
	date
	echo "FASTP SINGLE initiated:"
	date
	module load fastp/0.23.2
	cat SRR_Acc_Lists.txt | while read line; do echo "${line}"; fastp -i ./READS/"${line}".fastq -o ./READS/"${line}"_tr.fastq -h ./REPORTS/"${line}".html -j ./REPORTS/"${line}".json &> ./LOGS/"${line}"_COMPGG_FASTPS.txt; done
	module unload fastp/0.23.2
	echo "FASTP SINGLE done:"
	date
	echo "Salmon QUANT PAIRED initiated:"
	date
	ulimit -Sn 4000
	module load salmon/1.8.0
	cat ./SRR_Acc_Listp.txt | while read line; do echo "${line}"; salmon quant -i ../SALMON/COMPGG_index -l A -1 ./READS/"${line}"_1_tr.fastq -2 ./READS/"${line}"_2_tr.fastq --validateMappings -o ./SALMON/"${line}"_COMPGG --threads 10 --seqBias --gcBias &> ./LOGS/"${line}"_COMPGG_SALMON.txt; done
	module unload salmon/1.8.0
	echo "Salmon QUANT PAIRED done:"
	date
	echo "Salmon QUANT SINGLE initiated:"
	date
	ulimit -Sn 4000
	module load salmon/1.8.0
	cat ./SRR_Acc_Lists.txt | while read line; do echo "${line}"; salmon quant -i ../SALMON/COMPGG_index -l A -r ./READS/"${line}"_tr.fastq --validateMappings -o ./SALMON/"${line}"_COMPGG --threads 10 --seqBias --gcBias &> ./LOGS/"${line}"_COMPGG_SALMON.txt; done
	module unload salmon/1.8.0
	echo "Salmon QUANT SINGLE done:"
	date
	echo "MULTIQC initiated:"
	date
	mkdir -p ./MULTIQC_SALMON
	module load MultiQC/1.8
	multiqc ./SALMON/ --outdir ./MULTIQC_SALMON/"$dir"
	module unload MultiQC/1.8
	echo "MULTIQC done:"
	date
	echo "FASTQC initiated:"
	date
	mkdir -p ./fastqc
	module load FastQC/0.11.8
	fastqc -o ./fastqc/ ./READS/*.fastq &> ./LOGS/FASTQC.txt
	module unload FastQC/0.11.8
	echo "FASTQC done:"
	date
	echo "SAVE LOGS AND CLEAN FILES"
	rm -r READS/
	echo "FINISHED $dir"
	cd ..
done
