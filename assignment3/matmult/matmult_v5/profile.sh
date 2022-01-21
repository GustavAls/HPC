#!/bin/bash
#BSUB -J 1gpu_p
#BSUB -o 1gpu_p_%J.out
#BSUB -q hpcintrogpu
#BSUB -W 00:40
#BSUB -R "rusage[mem=5GB] span[hosts=1]"
#BSUB -n 1
#BSUB -gpu "num=1:mode=exclusive_process"
EXECUTABLE=example3d
DIRECTORY=experiments
OUTFILE=profile.txt

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

declare -A size_its
size_its=( [8096]=1 )
OUTFILE="profile_gpu5.txt"
rm -f $OUTFILE

rm -rf $DIRECTORY/$OUTFILE

for size in 8192 #10240
do
    echo $N >> $DIRECTORY/$OUTFILE
    nv-nsight-cu-cli ./matmult_f.nvcc lib $size $size $size >> $OUTFILE
    nsys profile $EXECUTABLE $N >> $DIRECTORY/$OUTFILE
done

