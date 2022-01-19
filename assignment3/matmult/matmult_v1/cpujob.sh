#!/bin/bash
#BSUB -q hpcintrogpu
#BSUB -J CPUMatmult_v1
#BSUB -o CPU%J.out
#BSUB -e Error_%J.err
#BSUB -R "rusage[mem=2048MB]"
#BSUB -W 01:00
#BSUB -n 1
#BSUB -R "select[model=XeonE5_2660v3]"

./matmult_gpu1

