#!/bin/bash
#BSUB -J Jacobi
#BUSB -q hpcintro
## set wall time hh:mm
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
## set number of cores
#BSUB -n 24
DIRECTORY=experiments
OUTFILE=$DIRECTORY/jacobi.txt
#BSUB -o $OUTFILE
module load studio

echo "CPU information"
lscpu

rm -rf $OUTFILE

for N in 16 32 64 128 256 512 1024
do
	./poisson_j $N 1000000 0.001 1 >> $OUTFILE
done