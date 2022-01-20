//
// File 'example3d.cu' illustrates how to use the functions in 
// alloc3d.h, alloc3d_gpu.h, and transfer3d_gpu.h.
//
#include <stdio.h>
#include <omp.h>
#include "alloc3d.h"
#include "alloc3d_gpu.h"
#include "transfer3d_gpu.h"

void interchange_memory(double ****a, double ****b){
    double*** temp = *a;
    *a = *b;
    *b = temp;
 }

 __global__ void jacobi_d0(double ***u_d0,double ***uo_d0, double***uo_d1,double ***f_d0, int N, int iterations, double factor, double delta2){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i > 0 && j > 0 && j < N-1 && k > 0 && k < N-1) { 
        if (i == (N / 2 - 1)) {
            u_d0[i][j][k] = factor * (
                uo_d0[i-1][j][k] + uo_d1[0][j][k] +  // At the boundary between the two devices, we need the next value from d1;
                uo_d0[i][j-1][k] + uo_d0[i][j+1][k] +  // this is why we need the unidirectional read from d1, via cudaDeviceEnablePeerAccess()
                uo_d0[i][j][k-1] + uo_d0[i][j][k+1] + 
                delta2*f_d0[i][j][k]);
        } else if (i < (N / 2 - 1)) {
            u_d0[i][j][k] = factor * (
                uo_d0[i-1][j][k] + uo_d0[i+1][j][k] + 
                uo_d0[i][j-1][k] + uo_d0[i][j+1][k] + 
                uo_d0[i][j][k-1] + uo_d0[i][j][k+1] + 
                delta2*f_d0[i][j][k]);
        }
    } 
}
 __global__ void jacobi_d1(double ***u_d1,double ***uo_d1, double***uo_d0,double ***f_d1, int N, int iterations, double factor, double delta2){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i < N/2-1 && j > 0 && j < N-1 && k > 0 && k < N-1) { 
        if (i == 0) {
            u_d1[i][j][k] = factor * (
                uo_d0[N/2-1][j][k] + uo_d1[i+1][j][k] +  // At the boundary between the two devices, we need the previous value from d0;
                uo_d1[i][j-1][k] + uo_d1[i][j+1][k] +  // this is why we need the unidirectional read from d0, via cudaDeviceEnablePeerAccess()
                uo_d1[i][j][k-1] + uo_d1[i][j][k+1] + 
                delta2*f_d1[i][j][k]);
        } else if (i > 0) {
            u_d1[i][j][k] = factor * (
                uo_d1[i-1][j][k] + uo_d1[i+1][j][k] + 
                uo_d1[i][j-1][k] + uo_d1[i][j+1][k] + 
                uo_d1[i][j][k-1] + uo_d1[i][j][k+1] + 
                delta2*f_d1[i][j][k]);
        }
    } 
}

int
main(int argc, char *argv[])
{
    // This code allocates a 3d array of size N^3 on the host, and two 
    // 3d arrays of half size on devices 0 and 1, respectively. Then
    // the top part of the host array is transferred to device 0 and the 
    // bottom part to device 1.

    // const int N = 200;            // Dimension N x N x N.
    int N = atoi(argv[1]);
    const long nElms = N * N * N; // Number of elements.
    const int start_T = 20;
    const int iterations = 100;

    double 	***u_h = NULL;
    double 	***u_d0 = NULL;
    double 	***u_d1 = NULL;
    double 	***uo_h = NULL;
    double 	***uo_d0 = NULL;
    double 	***uo_d1 = NULL;
    double 	***f_h = NULL;
    double 	***f_d0 = NULL;
    double 	***f_d1 = NULL;

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
    if ( (u_d0 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ( (uo_d0 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ( (f_d0 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }

    // Allocate 3d array of half size in device 1 memory.
    if ( (u_d1 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d1: allocation on gpu failed");
        exit(-1);
    }
    // Allocate 3d array of half size in device 1 memory.
    if ( (uo_d1 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d1: allocation on gpu failed");
        exit(-1);
    }
    // Allocate 3d array of half size in device 1 memory.
    if ( (f_d1 = d_malloc_3d_gpu(N / 2, N, N)) == NULL ) {
        perror("array u_d1: allocation on gpu failed");
        exit(-1);
    }

    // Transfer top part to device 0.
    cudaSetDevice(0);
    cudaDeviceEnablePeerAccess(1, 0);
    transfer_3d(u_d0, u_h, N / 2, N, N, cudaMemcpyHostToDevice);

    // Transfer bottom part to device 1.
    cudaSetDevice(1);
    cudaDeviceEnablePeerAccess(0, 0);
    transfer_3d(u_d1, u_h + nElms / 2, N / 2, N, N, cudaMemcpyHostToDevice);

    // kernel settings
    dim3 blocksize(8, 8, 8); // 8*8*8 < 1024
    dim3 gridsize( ceil((int) N/blocksize.x),ceil((int) N/blocksize.y),ceil((int) N/blocksize.z) );

    // ... compute ...
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double factor = 1.0 / 6.0;
    double ts = omp_get_wtime();
    for(int n=0; n < iterations; n++){
        interchange_memory(&uo_d0, &u_d0);
        interchange_memory(&uo_d1, &u_d1);

        cudaSetDevice(0);
        jacobi_d0<<<gridsize,blocksize>>>(u_d0, uo_d0, uo_d1, f_d0, N, iterations, factor, delta2);
        cudaSetDevice(1);
        jacobi_d1<<<gridsize,blocksize>>>(u_d1, uo_d1, uo_d0, f_d1, N, iterations, factor, delta2);

        cudaDeviceSynchronize();
        cudaSetDevice(0);
        cudaDeviceSynchronize();
    }
    double te = omp_get_wtime() - ts;

    // ... transfer back ...
    cudaSetDevice(0);
    cudaDeviceEnablePeerAccess(1, 0);
    transfer_3d(u_h, u_d0, N / 2, N, N, cudaMemcpyDeviceToHost);

    cudaSetDevice(1);
    cudaDeviceEnablePeerAccess(0, 0);
    transfer_3d(u_h + nElms / 2, u_d1, N / 2, N, N, cudaMemcpyDeviceToHost);

    // Print times.
    printf("%d %f\n", N, te);

    // Clean up.
    free(u_h);
    free_gpu(u_d0);
    free_gpu(u_d1);

    // printf("Done\n");
}
