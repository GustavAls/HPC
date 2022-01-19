//
// File 'example3d.cu' illustrates how to use the functions in 
// alloc3d.h, alloc3d_gpu.h, and transfer3d_gpu.h.
//
#include <stdio.h>
#include "alloc3d.h"
#include "alloc3d_gpu.h"
#include "transfer3d_gpu.h"

int
main(int argc, char *argv[])
{
    // This code allocates a 3d array of size N^3 on the host, and two 
    // 3d arrays of half size on devices 0 and 1, respectively. Then
    // the top part of the host array is transferred to device 0 and the 
    // bottom part to device 1.

    const int N = 200;            // Dimension N x N x N.
    const long nElms = N * N * N; // Number of elements.

    double 	***u_h = NULL;
    double 	***u_d0 = NULL;
    double 	***u_d1 = NULL;

    // Allocate 3d array in host memory.
    if ( (u_h = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array u: allocation failed");
        exit(-1);
    }

    // Allocate 3d array of half size in device 0 memory.
    if ( (u_d0 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }

    // Allocate 3d array of half size in device 1 memory.
    if ( (u_d1 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d1: allocation on gpu failed");
        exit(-1);
    }

    // Transfer top part to device 0.
    transfer_3d_from_1d(u_d0, u_h[0][0], N / 2, N, N, cudaMemcpyHostToDevice);

    // Transfer bottom part to device 1.
    transfer_3d_from_1d(u_d1, u_h[0][0] + nElms / 2, N / 2, N, N, cudaMemcpyHostToDevice);

    // ... compute ...

    // ... transfer back ...

    // Clean up.
    free(u_h);
    free_gpu(u_d0);
    free_gpu(u_d1);

    printf("Done\n");
}
