#!/bin/bash
#BSUB -J gpu_sequential
#BSUB -q hpcintrogpu
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
#BSUB -n 1
#BSUB -gpu "num=1:mode=exclusive_process"
EXECUTABLE=example3d
DIRECTORY=experiments
OUTFILE=gpu_sequential.txt

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

NS="2 4 8 16 32"

rm -rf $DIRECTORY/$OUTFILE

for N in $NS
do
	$EXECUTABLE $N >> $DIRECTORY/$OUTFILE
done
