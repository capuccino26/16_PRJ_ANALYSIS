#!/bin/bash
#$ -V
#$ -cwd
#$ -pe smp 10

echo "Start:"
date
module load salmon/1.8.0
salmon index -t ./GENOMES/RAW/COMPGG.fas -i ./SALMON/COMPGG_index --gencode
module unload salmon/1.8.0
echo "Finish:"
date
