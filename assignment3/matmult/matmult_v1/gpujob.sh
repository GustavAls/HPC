#!/bin/bash
#BSUB -q hpcintrogpu
#BSUB -J GPUMatmult_v1
#BSUB -o GPU%J.out
#BSUB -e Error_%J.err
#BSUB -R "rusage[mem=2048MB]"
#BSUB -W 01:00
#BSUB -n 1
#BSUB -gpu "num=1:mode=exclusive_process"
module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1


declare -A size_its
size_its=([512]=100 [1024]=10 [2048]=1 [4096]=1)

OUTFILE="results_gpu1.txt"
rm -f $OUTFILE
EXECUTABLE=./matmult_f.nvcc

for size in 512 1024 2048 4096
    do
        MFLOPS_MAX_IT=${size_its[${size}]} MATMULT_COMPARE=0 $EXECUTABLE lib $size $size $size
    done