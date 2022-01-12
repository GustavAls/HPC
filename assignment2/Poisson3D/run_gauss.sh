#!/bin/bash
#BSUB -q hpcintro
 

EXECUTABLE=poisson_gs
DIRECTORY=experiments
OUTFILE=$DIRECTORY/gauss.txt
 
NS="4 8 16 32 64"
ITER=10000
THRESH=0.01
START_AT=1
 
COLLECT="-p on -h dch -h dcm -h l2h -h l2m"

rm -f $OUTFILE
 
# enable(1)/disable(0) result checking
export MATMULT_COMPARE=0
 
module load studio
 
# start the collect command with the above settings
for N in $NS
do
    $EXECUTABLE $N $ITER $THRESH $START_AT >> $OUTFILE # $DIRECTORY/$N.txt
    # collect -d $DIRECTORY -o $P$S.1.er $COLLECT $EXECUTABLE $P $S $S $S
    # er_print -func $DIRECTORY/$P$S.1.er > $DIRECTORY/$P$S.1.txt
done
                                                                                            
