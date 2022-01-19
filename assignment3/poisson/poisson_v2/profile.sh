#!/bin/bash
#BSUB -J profile_1gpu
#BSUB -q hpcintrogpu
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
#BSUB -n 24
EXECUTABLE=example3d
DIRECTORY=experiments
OUTFILE=racial_profile.txt

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

# export MATMULT_COMPARE=1

NS="2 4 8 16 32 64 128 256"

rm -rf $DIRECTORY/$OUTFILE

for N in $NS
do
    echo $N
    nv-nsight-cu-cli ./$EXECUTABLE $N >> $OUTFILE
    nsys profile $EXECUTABLE $N >> $OUTFILE
done
