#!/bin/bash
#BSUB -q hpcintrogpu
#BSUB -J get_info
#BSUB -o get_info_%J.out
#BSUB -R "rusage[mem=2048MB]"
#BSUB -W 01:00
#BSUB -n 1
#BSUB -gpu "num=1:mode=exclusive_process"

module load cuda/11.5.1
module load gcc/10.3.0-binutils-2.36.1

nvidia-smi -q > "info.txt"
