#!/bin/bash
#$ -V
#$ -cwd
#$ -pe smp 20
for dir in */ ; do
	echo "$dir"
	cd "$dir"
	echo "Download SRAs:"
	date
	ulimit -Sn 4000
	module load sratoolkit/3.0.0
	cat SRR_Acc_List.txt | while read line; do echo "${line}"; fasterq-dump "${line}" --outdir ./READS; done &> logdump.txt
	module unload sratoolkit/3.0.0 
	echo "Finished Download SRAs"
	date
	echo "FASTP PAIRED initiated:"
	date
	module load fastp/0.23.2
	cat SRR_Acc_Listp.txt | while read line; do echo "${line}"; fastp -i ./READS/"${line}"_1.fastq -I ./READS/"${line}"_2.fastq -o ./READS/"${line}"_1_tr.fastq -O ./READS/"${line}"_2_tr.fastq -h ./REPORTS/"${line}".html -j ./REPORTS/"${line}".json; done &> "${line}"_COMPGG_fastpp.txt
	module unload fastp/0.23.2
	echo "FASTP PAIRED done:"
	date
	echo "FASTP SINGLE initiated:"
	date
	module load fastp/0.23.2
	cat SRR_Acc_Lists.txt | while read line; do echo "${line}"; fastp -i ./READS/"${line}".fastq -o ./READS/"${line}"_tr.fastq -h ./REPORTS/"${line}".html -j ./REPORTS/"${line}".json
	module unload fastp/0.23.2; done &> "${line}"_COMPGG_fastps.txt
	echo "FASTP SINGLE done:"
	date
	echo "Mapping SINGLE initiated:"
	date
	module load STAR/2.7.10b
	cat ./SRR_Acc_Lists.txt | while read line; do echo "${line}"; STAR --runThreadN 20 --genomeDir ../GENOMES/COMPGG --genomeLoad LoadAndKeep --readFilesIn ./READS/"${line}".fastq --outFilterIntronMotifs RemoveNoncanonical --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --limitBAMsortRAM 10000000000 --outFileNamePrefix ./OUTPUT/"${line}"_COMPGG; done &> "${line}"_COMPGG_shell.txt
	module unload STAR/2.7.10b
	echo "Mapping SINGLE done:"
	date
	echo "Mapping PAIRED initiated:"
	date
	module load STAR/2.7.10b
	cat ./SRR_Acc_Listp.txt | while read line; do echo "${line}"; STAR --runThreadN 20 --genomeDir ../GENOMES/COMPGG --genomeLoad LoadAndKeep --readFilesIn ./READS/"${line}"_1_tr.fastq ./READS/"${line}"_2_tr.fastq --outFilterIntronMotifs RemoveNoncanonical --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --limitBAMsortRAM 10000000000 --outFileNamePrefix ./OUTPUT/"${line}"_COMPGG; done &> "${line}"_COMPGG_shell.txt
	module unload STAR/2.7.10b
	echo "Mapping PAIRED done:"
	date
	echo "Coverage initiated:"
	date
	module load Samtools/1.15.1
	ls ./READS | while read line; do echo "${line}"; mkdir ./TABLES/ -p; samtools coverage ./OUTPUT/"${line}"_COMPGG_Aligned.sortedByCoord.out.bam -o ./TABLES/"${line}"_COMPGG.csv; done &> "${line}"_COMPGG_coverage.txt
	module unload Samtools/1.15.1
	echo "Coverage done:"
	date
	echo "SAVE LOGS AND CLEAN FILES"
	mkdir -p ../LOGS
	cp /OUTPUT/"${line}"_COMPGG_Log* ../LOGS/
	rm -r /OUTPUT
	rm -r /READS
	echo "FINISHED $dir"
	cd ..
done
