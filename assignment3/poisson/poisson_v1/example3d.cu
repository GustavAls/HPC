//
// File 'example3d.cu' illustrates how to use the functions in 
// alloc3d.h, alloc3d_gpu.h, and transfer3d_gpu.h.
//
#include <stdio.h>
#include "alloc3d.h"
#include "alloc3d_gpu.h"
#include "transfer3d_gpu.h"
#include "initialize_data.h"
#include "jacobi.h"

void interchange_memory(double ***a, double ***b){
    double*** temp = a;
    a = b;
    b = temp;
 }

int
main(int argc, char *argv[])
{
    // This code allocates a 3d array of size N^3 on the host, and two 
    // 3d arrays of half size on devices 0 and 1, respectively. Then
    // the top part of the host array is transferred to device 0 and the 
    // bottom part to device 1.

    const int N = 8;            // Dimension N x N x N.
    const long nElms = N * N * N; // Number of elements.
    const int start_T = 20;
    const int iterations = 10000;

    double 	***u_h = NULL;
    double 	***uo_h = NULL;
    double 	***f_h = NULL;
    double 	***u_d = NULL;
    double 	***uo_d = NULL;
    double 	***f_d = NULL;

    cudaSetDevice(0);

    // Allocate 3d array in host memory.
    if ( (u_h = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array u: allocation failed");
        exit(-1);
    }
    if ( (uo_h = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array u: allocation failed");
        exit(-1);
    }
    if ( (f_h = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array u: allocation failed");
        exit(-1);
    }

    // Allocate 3d array of half size in device 0 memory.
    if ( (u_d = d_malloc_3d_gpu(N, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ( (uo_d = d_malloc_3d_gpu(N, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ( (f_d = d_malloc_3d_gpu(N, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }

    initialize_data(N, u_h, uo_h, f_h, start_T);

    // Transfer top part to device 0.
    transfer_3d(u_d, u_h, N, N, N, cudaMemcpyHostToDevice);

    // ... compute ...
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double factor = 1.0 / 6.0;
    for(int n=0; n < iterations; n++){
        interchange_memory(uo_d, u_d);
        jacobi<<<1, 1>>>(u_d, uo_d, f_d, N, iterations, factor, delta2);
        cudaDeviceSynchronize();
    }

    // ... transfer back ...
    transfer_3d(u_h, u_d, N, N, N, cudaMemcpyDeviceToHost);

    // Clean up.
    free(u_h);
    free(uo_h);
    free(f_h);
    free_gpu(u_d);
    free_gpu(uo_d);
    free_gpu(f_d);

    printf("Done\n");
}