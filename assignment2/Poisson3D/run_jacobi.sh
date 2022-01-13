#!/bin/bash
#BSUB -J Jacobi
#BUSB -q hpcintro
## set wall time hh:mm
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
## set number of cores
#BSUB -n 24
EXECUTABLE=poisson_j
DIRECTORY=experiments
# OUTFILE=$DIRECTORY/jacobi_1.txt
#BSUB -o $OUTFILE
module load studio
module load gcc

NS="8 16 32 64 128"
ITER=10000
THRESH=0.01
START_AT=1

N_THREADS="1 2 4 16 24"

# echo "CPU information"
# lscpu

for M in $N_THREADS
do
	rm -rf $DIRECTORY/jacobi_$M.txt
	for N in $NS
	do
		OMP_NUM_THREADS=$M $EXECUTABLE $N $ITER $THRESH $START_AT >> $DIRECTORY/jacobi_$M.txt
	done
done 
