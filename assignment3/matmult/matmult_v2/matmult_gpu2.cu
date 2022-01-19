/*
Implementation using one thread pr. element in C
*/
#include <math.h>

__global__ void kernel2(int m, int n, int k, double *A, double *B, double *C) {
    double sum = 0;
    int i, j, q;

    //Computing the global coordinates of the thread
    i = blockIdx.x * blockDim.x + threadIdx.x;
    j = blockIdx.y * blockDim.y + threadIdx.y;
  
    //Checking for out of bounds
    if (i < m && j < n){
        //Multiplitying a row in A with a column in B, corresponding to one element in C
        for (q = 0; q < k; q++) {
            sum += A[i*k + q] * B[q*n + j];
        }
        C[i*n + j] = sum;
    }
}
  
  
extern "C" {
    void matmult_gpu2(int m, int n, int k, double *A, double *B, double *C) {
        double* A_d, * B_d, * C_d;
        int d1,d2;
        //Cuda allocate memory on device for matrices
        cudaMalloc((void**)&A_d, m*k * sizeof(double));
        cudaMalloc((void**)&B_d, k*n * sizeof(double));
        cudaMalloc((void**)&C_d, m*n * sizeof(double));

        //Copy the input parameters unto the device memory
        cudaMemcpy(A_d, A, m*k * sizeof(double), cudaMemcpyHostToDevice);
        cudaMemcpy(B_d, B, k*n * sizeof(double), cudaMemcpyHostToDevice);

        //Initialize zeros in the output matrix
        cudaMemset(C_d, 0, m*n*sizeof(double));
                
        //Assigning a 2D thread grid in each block
        dim3 threadsPerBlock(16,16,1);

        //Defining the grid layout depending on the input dimensions
        d1 = ceil((double) m / 16.0);
        d2 = ceil((double) n / 16.0);

        dim3 blocksPerGrid(d1, d2);

        kernel2<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        
        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
      }
  }