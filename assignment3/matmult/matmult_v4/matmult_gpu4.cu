/*
Implementation delegating x elements of C to each thread
*/

//Version with 4 elements pr thread
__global__ void kernel4_4(int m,int n, int k, double *A, double *B, double *C){
    int i, j, q;
    double sum1 = 0.0, sum2 = 0.0, sum3 = 0.0, sum4 = 0.0;
        
    //Computing the global coordinates of the thread
    i = 4 * (blockIdx.x * blockDim.x + threadIdx.x);
    j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < m && j < n)
    {
        for(q = 0; q < k; q++){
            sum1 += A[i*k + q] * B[q*n + j];
            if (i+1 < m) sum2 += A[(i+1)*k + q] * B[q*n + j];
            if (i+2 < m) sum3 += A[(i+2)*k + q] * B[q*n + j];
            if (i+3 < m) sum4 += A[(i+3)*k + q] * B[q*n + j];
        }
        C[i*n+j] = sum1;
        if (i+1 < m) C[(i+1)*n+j] = sum2;
        if (i+2 < m) C[(i+2)*n+j] = sum3;
        if (i+3 < m) C[(i+3)*n+j] = sum4;
    }
}

//Version with 6 elements pr thread
__global__ void kernel4_6(int m,int n, int k, double *A, double *B, double *C){
    int i, j, q;
    double sum1 = 0.0, sum2 = 0.0, sum3 = 0.0, sum4 = 0.0, sum5 = 0.0, sum6 = 0.0;
        
    //Computing the global coordinates of the thread
    i = 6 * (blockIdx.x * blockDim.x + threadIdx.x);
    j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < m && j < n)
    {
        for(q = 0; q < k; q++){
            sum1 += A[i*k + q] * B[q*n + j];
            if (i+1 < m) sum2 += A[(i+1)*k + q] * B[q*n + j];
            if (i+2 < m) sum3 += A[(i+2)*k + q] * B[q*n + j];
            if (i+3 < m) sum4 += A[(i+3)*k + q] * B[q*n + j];
            if (i+4 < m) sum5 += A[(i+4)*k + q] * B[q*n + j];
            if (i+5 < m) sum6 += A[(i+5)*k + q] * B[q*n + j];
        }
        C[i*n+j] = sum1;
        if (i+1 < m) C[(i+1)*n+j] = sum2;
        if (i+2 < m) C[(i+2)*n+j] = sum3;
        if (i+3 < m) C[(i+3)*n+j] = sum4;
        if (i+4 < m) C[(i+4)*n+j] = sum5;
        if (i+5 < m) C[(i+5)*n+j] = sum6;
    }
}

extern "C" {
    void matmult_gpu4(int m, int n, int k, double *A, double *B, double *C) {
        double* A_d, * B_d, * C_d;
        //Cuda allocate memory on device for matrices
        cudaMalloc((void**)&A_d, m*k * sizeof(double));
        cudaMalloc((void**)&B_d, k*n * sizeof(double));
        cudaMalloc((void**)&C_d, m*n * sizeof(double));

        //Copy the input parameters unto the device memory
        cudaMemcpy(A_d, A, m*k * sizeof(double), cudaMemcpyHostToDevice);
        cudaMemcpy(B_d, B, k*n * sizeof(double), cudaMemcpyHostToDevice);

        //Initialize zeros in the output matrix
        cudaMemset(C_d, 0, m*n*sizeof(double));

        int d1,d2;
        int block_size = 16;
        int num_elements = 4;
                
        //Assigning a 2D thread grid in each block
        dim3 threadsPerBlock(block_size, block_size);

        //Defining the grid layout depending on the input dimensions
 
        d1 = (int) (m / num_elements - 1) / block_size + 1;
        d2 = (int) (n - 1) / block_size + 1;

        //Defining grid size
        dim3 blocksPerGrid(d1, d2);

        kernel4_4<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        //kernel4_6<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        
        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
      }
  }