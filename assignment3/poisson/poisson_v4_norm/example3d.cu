//
// File 'example3d.cu' illustrates how to use the functions in
// alloc3d.h, alloc3d_gpu.h, and transfer3d_gpu.h.
//

#include <stdio.h>
#include <omp.h>
#include "alloc3d.h"
#include "alloc3d_gpu.h"
#include "transfer3d_gpu.h"
#include "initialize_data.h"
#include "jacobi.h"

__inline__ __device__ double warpReduceSum(double value);
__inline__ __device__ double blockReduceSum(double value);

void interchange_memory(double ****a, double ****b)
{
    double ***temp = *a;
    *a = *b;
    *b = temp;
}

int main(int argc, char *argv[])
{
    // This code allocates a 3d array of size N^3 on the host, and two
    // 3d arrays of half size on devices 0 and 1, respectively. Then
    // the top part of the host array is transferred to device 0 and the
    // bottom part to device 1.

    // const int N = 16;            // Dimension N x N x N.
    int N = atoi(argv[1]);
    // const long nElms = N * N * N; // Number of elements.
    const int start_T = 20;
    const int iterations = 100;
    const double threshold = 0.01;

    double ***u_h = NULL;
    double ***uo_h = NULL;
    double ***f_h = NULL;
    double ***u_d = NULL;
    double ***uo_d = NULL;
    double ***f_d = NULL;
    double *norm_d, *norm_h;

    // Allocate 3d array in host memory.
    if ((u_h = d_malloc_3d(N, N, N)) == NULL)
    {
        perror("array u: allocation failed");
        exit(-1);
    }
    if ((uo_h = d_malloc_3d(N, N, N)) == NULL)
    {
        perror("array u: allocation failed");
        exit(-1);
    }
    if ((f_h = d_malloc_3d(N, N, N)) == NULL)
    {
        perror("array u: allocation failed");
        exit(-1);
    }
    cudaMallocHost((void **)&norm_h, sizeof(double));
    *norm_h = 10000.0;

    cudaSetDevice(0);

    // Allocate 3d array of half size in device 0 memory.
    if ((u_d = d_malloc_3d_gpu(N, N, N)) == NULL)
    {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ((uo_d = d_malloc_3d_gpu(N, N, N)) == NULL)
    {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    if ((f_d = d_malloc_3d_gpu(N, N, N)) == NULL)
    {
        perror("array u_d0: allocation on gpu failed");
        exit(-1);
    }
    cudaMalloc((void **)&norm_d, sizeof(double));

    // CPU initializes vectors.
    initialize_data(N, u_h, uo_h, f_h, start_T);

    // CPU -> GPU transfer.
    transfer_3d(u_d, u_h, N, N, N, cudaMemcpyHostToDevice);
    transfer_3d(uo_d, uo_h, N, N, N, cudaMemcpyHostToDevice);
    transfer_3d(f_d, f_h, N, N, N, cudaMemcpyHostToDevice);
    cudaMemcpy(norm_d, norm_h, sizeof(double), cudaMemcpyHostToDevice);

    // kernel settings
    dim3 blocksize(32, 1, 1);                                                                                   // 8*8*8 < 1024
    dim3 gridsize(ceil((double)N / blocksize.x), ceil((double)N / blocksize.y), ceil((double)N / blocksize.z)); // cast into double for decimal

    // CPU controlled loop Jacobi
    double delta = 2.0 / ((double)N - 1.0);
    double delta2 = delta * delta;
    double factor = 1.0 / 6.0;
    int n = 0;
    double ts = omp_get_wtime();
    while (n<iterations && * norm_h> threshold)
    {
        *norm_h = 0.0;

        cudaMemcpy(norm_d, norm_h, sizeof(double), cudaMemcpyHostToDevice);
        interchange_memory(&uo_d, &u_d);
        jacobi<<<gridsize, blocksize>>>(u_d, uo_d, norm_d, f_d, N, iterations, factor, delta2);
        cudaMemcpy(norm_h, norm_d, sizeof(double), cudaMemcpyDeviceToHost);
        cudaDeviceSynchronize(); // Synchronize globally between each step
        n++;
    }
    double te = omp_get_wtime() - ts;
    // GPU -> CPU transfer.
    transfer_3d(u_h, u_d, N, N, N, cudaMemcpyDeviceToHost);
    transfer_3d(uo_h, uo_d, N, N, N, cudaMemcpyDeviceToHost);
    transfer_3d(f_h, f_d, N, N, N, cudaMemcpyDeviceToHost);

    // Print times.
    printf("%d %f\n", N, te);

    // Clean up.
    free(u_h);
    free(uo_h);
    free(f_h);
    free_gpu(u_d);
    free_gpu(uo_d);
    free_gpu(f_d);

    // printf("Done\n");
}