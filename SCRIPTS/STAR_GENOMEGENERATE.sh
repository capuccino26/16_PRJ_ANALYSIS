#!/bin/bash
#$ -V
#$ -cwd
#$ -pe smp 25

echo "Start:"
date
module load STAR/2.7.10b
STAR --runThreadN 25 --runMode genomeGenerate --genomeDir ./GENOMES/COMPGG --genomeSAindexNbases 12 --limitGenomeGenerateRAM 500000000000 --genomeFastaFiles ./RAW/GENOMES/COMPGG/comps_plus_GGs.fas &> ./GENOME_GENERATE_COMPGG.txt
module unload STAR/2.7.10b
echo "Finish:"
date
