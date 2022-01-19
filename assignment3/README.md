Steps for setting up this assignemnt:

1) ssh to the LSF front-end node (login2.hpc.dtu.dk)
2) run hpcintrogpush (Or ThinLincc application)
3) module load cuda/11.5.1
4) module load gcc/10.3.0-binutils-2.36.1

Various device query for profiling:

1. ```nvidia-smi```: check GPU on your node and whether they are used.
2. ```/appl/cuda/11.5.1/samples/bin/x86_64/linux/release/deviceQuery```: see details of the GPU (has to be done a lot)
3. lscpu and free: check CPUs on your node and the size of the main memory
4. ```appl/cuda/11.5.1/samples/bin/x86_64/linux/release/bandwidthTest```: measure effective bandwith for transferring data CPU <-> GPU and GPU -> GPU. Use ```--memory=pageable``` and ```--memory=pinned``` to see the difference between having normal vs. pinned memory.
