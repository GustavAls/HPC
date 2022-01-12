#!/bin/bash
#BSUB -J Gauss
#BSUB -q hpcintro
## set wall time hh:mm
#BSUB -W 00:40
#BSUB -R "rusage[mem=2048MB] span[hosts=1]"
## set number of cores
#BSUB -n 24
EXECUTABLE=poisson_gs
DIRECTORY=experiments
OUTFILE=$DIRECTORY/gauss.txt
#BSUB -o $OUTFILE%J.out
module load studio
module load gcc

NS="4 8 16 32 64 128 256 512"
ITER=10000
THRESH=0.01
START_AT=1
 
COLLECT="-p on -h dch -h dcm -h l2h -h l2m"

rm -f $OUTFILE
 
echo "GCC version"
gcc --version

# enable(1)/disable(0) result checking
export MATMULT_COMPARE=0
 
 
# start the collect command with the above settings
for N in $NS
do
    $EXECUTABLE $N $ITER $THRESH $START_AT >> $OUTFILE # $DIRECTORY/$N.txt
    # collect -d $DIRECTORY -o $P$S.1.er $COLLECT $EXECUTABLE $P $S $S $S
    # er_print -func $DIRECTORY/$P$S.1.er > $DIRECTORY/$P$S.1.txt
done
                                                                                            
