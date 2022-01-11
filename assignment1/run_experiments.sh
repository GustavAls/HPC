#!/bin/bash
#BSUB -q hpcintro

# define the driver name to use
# valid values: matmult_c.studio, matmult_f.studio, matmult_c.gcc or
# matmult_f.gcc
#
EXECUTABLE=matmult_c.gcc

# define the mkn values in the MKN variable
#
# SIZES="7 9 13 19 26 37 52 74 105 148 209 296 418 591 836 1182 1672 2365 3344"
SIZES="3344"

# define the permutation type in PERM
#
PERM="nkm"

DIRECTORY=experiments
COLLECT="-p on -h dch -h dcm -h l2h -h l2m"

# uncomment and set a reasonable BLKSIZE for the blk version
#
# BLKSIZE=1

# enable(1)/disable(0) result checking
export MATMULT_COMPARE=0

module load studio

# start the collect command with the above settings
for P in $PERM
do
    for S in $SIZES
    do
        collect -d $DIRECTORY -o $P$S.1.er $COLLECT $EXECUTABLE $P $S $S $S
        er_print -func $DIRECTORY/$P$S.1.er > $DIRECTORY/$P$S.1.txt
    done
done
