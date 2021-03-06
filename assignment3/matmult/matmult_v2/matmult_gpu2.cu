/*
Implementation using one thread pr. element in C
*/
__global__ void kernel2(int m, int n, int k, double *A, double *B, double *C) {
    double sum = 0.0;
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
    #include <omp.h>
    #include <stdio.h>
    void matmult_gpu2(int m, int n, int k, double *A, double *B, double *C) {
        double* A_d, * B_d, * C_d;
        //Cuda allocate memory on device for matrices
        cudaMalloc((void**)&A_d, m*k * sizeof(double));
        cudaMalloc((void**)&B_d, k*n * sizeof(double));
        cudaMalloc((void**)&C_d, m*n * sizeof(double));
        
        //Copy the input parameters unto the device memory
        double start = omp_get_wtime();
        cudaMemcpy(A_d, A, m*k * sizeof(double), cudaMemcpyHostToDevice);
        cudaMemcpy(B_d, B, k*n * sizeof(double), cudaMemcpyHostToDevice);
        double seconds = omp_get_wtime() - start;

        //Initialize zeros in the output matrix
        cudaMemset(C_d, 0, m*n*sizeof(double));

        int d1,d2;
        int block_size = 16;
                
        //Assigning a 2D thread grid in each block
        dim3 threadsPerBlock(block_size, block_size);

        //Defining the grid layout depending on the input dimensions
        d1 = (int) (m - 1) / block_size + 1;
        d2 = (int) (n - 1) / block_size + 1;

        //Defining grid size
        dim3 blocksPerGrid(d1, d2);
        // double start = omp_get_wtime();
        kernel2<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);

        cudaDeviceSynchronize();
        // double seconds = omp_get_wtime() - start;

        //Copying result to host
        double start2 = omp_get_wtime();
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);
        double seconds2 = omp_get_wtime() - start2;

        seconds = seconds + seconds2;
        // printf("Bandwidth (GB/s): %f", (m*k + n*k)*sizeof(double)/(seconds*1e11));
        printf("Time %f ", seconds);
        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
      }
  }