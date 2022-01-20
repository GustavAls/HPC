#!/bin/bash
#BSUB -J cpu
#BSUB -q hpcintro
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
#BSUB -n 24
EXECUTABLE=poisson_j
DIRECTORY=experiments
OUTFILE=cpu.txt

module load gcc/10.3.0-binutils-2.36.1

NS="64 128 256 512"
ITER=100
THRESH=0.01
START_AT=20
N_THREADS="1 4 8 24"

rm -rf $DIRECTORY/$OUTFILE

for N in $NS
do
	for M in $NUM_THREADS
	do
		OMP_NUM_THREADS=$M $EXECUTABLE $N $ITER $THRESH $START_AT >> $DIRECTORY/$OUTFILE
	do
done
