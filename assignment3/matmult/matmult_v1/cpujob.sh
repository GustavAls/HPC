#!/bin/bash
#BSUB -q hpcintro
#BSUB -J CPUMatmult_v1
#BSUB -o CPU%J.out
#BSUB -e Error_%J.err
#BSUB -R "rusage[mem=2048MB]"
#BSUB -W 01:00
#BSUB -n 1


declare -A size_its
size_its=( [512]=1000 [1024]=100 [2048]=10 [4096]=1 )
METHOD = gpu1

for size in 512 1024 2048 4096 8192 #10240
    do
        MATMULT_COMPARE=0 ./matmult_f.nvcc $(METHOD) $size $size $size >> $OUTFILE
    done

