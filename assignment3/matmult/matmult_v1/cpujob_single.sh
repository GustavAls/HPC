#!/bin/bash
#BSUB -q hpcintrogpu
#BSUB -J CPUMatmult_v2
#BSUB -o CPU%J.out
#BSUB -e Error_%J.err
#BSUB -R "rusage[mem=2048MB]"
#BSUB -W 01:00
#BSUB -n 1
#BSUB -gpu "num=1:mode=exclusive_process"
module load gcc/10.3.0-binutils-2.36.1
module load cuda/11.5.1

declare -A size_its
size_its=( [512]=1 [1024]=1 [2048]=1 [4096]=1 )
OUTFILE="results_cpu.txt"
rm -f $OUTFILE

for size in 8192
    do
        MFLOPS_MAX_IT=${size_its[${size}]} MATMULT_COMPARE=0 ./matmult_f.nvcc lib $size $size $size >> $OUTFILE
    done

