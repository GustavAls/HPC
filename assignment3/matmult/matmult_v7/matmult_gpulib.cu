#include <cuda_runtime.h>
#include "cublas_v2.h"
#include "stdio.h"

extern "C" {

    void matmult_gpulib(int m, int n, int k, double *A, double *B, double *C) {
        double *A_d, *B_d, *C_d;
        double alpha = 1.0;
        double beta = 0.0;

        //Cuda allocate memory on device for matrices
        cudaMalloc((void**)&A_d, m*k * sizeof(double));
        cudaMalloc((void**)&B_d, k*n * sizeof(double));
        cudaMalloc((void**)&C_d, m*n * sizeof(double));

        //Copy the input parameters unto the device memory
        cudaMemcpy(A_d, A, m*k * sizeof(double), cudaMemcpyHostToDevice);
        cudaMemcpy(B_d, B, k*n * sizeof(double), cudaMemcpyHostToDevice);

        //Initialize zeros in the output matrix
        cudaMemset(C_d, 0, m*n*sizeof(double));

        cublasHandle_t handle;
        cublasCreate(&handle);

        cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, m, n, k, &alpha, &A_d[0], k, &B_d[0], n, &beta, &C_d[0], n);

        cublasDestroy(handle);

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);

    }
}