#!/bin/bash
#BSUB -J cpu
#BSUB -q hpcintro
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
#BSUB -n 24
EXECUTABLE=example3d
DIRECTORY=experiments
OUTFILE=gpu_1.txt

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

NS="2 4 8 16 32"

rm -rf $DIRECTORY/$OUTFILE

for N in $NS
do
	$EXECUTABLE $N >> $DIRECTORY/$OUTFILE
done
