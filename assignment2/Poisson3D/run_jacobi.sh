#!/bin/bash
#BSUB -J Jacobi
#BUSB -q hpcintro
## set wall time hh:mm
#BSUB -W 02:00
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
## set number of cores
#BSUB -n 24
EXECUTABLE=poisson_j
DIRECTORY=experiments
OUTFILE=$DIRECTORY/jacobi.txt
#BSUB -o $OUTFILE%J.out
module load studio
module load gcc

NS="4 8 16 32 64 128 256 512 1024"
ITER=10000
THRESH=0.01
START_AT=1

echo "CPU information"
lscpu
echo "GCC version"
gcc --version

rm -rf $OUTFILE

for N in $NS
do
	$EXECUTABLE $N $ITER $THRESH $START_AT >> $OUTFILE
done