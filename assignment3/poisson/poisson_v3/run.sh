#!/bin/bash
#BSUB -J 2gpu
#BSUB -o 2gpu_%J.out
#BSUB -q hpcintrogpu
#BSUB -W 00:40
#BSUB -R "rusage[mem=5GB] span[hosts=1]"
#BSUB -n 4
#BSUB -gpu "num=2:mode=exclusive_process"
EXECUTABLE=example3d
DIRECTORY=experiments
OUTFILE=2gpu.txt

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

NS="64 128 256 512"

rm -rf $DIRECTORY/$OUTFILE

for N in $NS
do
	$EXECUTABLE $N >> $DIRECTORY/$OUTFILE
done
