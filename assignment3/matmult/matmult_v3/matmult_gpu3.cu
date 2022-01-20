/*
Implementation letting each thread compute exatcly two elements of C
*/

//Version 1: right neighbor
__global__ void kernel3_right(int m, int n, int k, double *A, double *B, double *C) {
    int i, j, q;
    double sum1 = 0.0,sum2 = 0.0;

    //Computing the global coordinates of the thread
    i = blockIdx.x * blockDim.x + threadIdx.x;
    j = 2 * (blockIdx.y * blockDim.y + threadIdx.y);
    
    if (i < m && j < n){
        for (q = 0; q < k; q++) {
            //Compute product for first column in B
            sum1 += A[i*k + q] * B[q*n + j];
            if (j+1 < n) 
                //Compute product for second column in B
                sum2 += A[i*k + q] * B[q*n + j+1];
        }

    C[i*n + j] = sum1;
    if (j+1 < n) 
        C[i*n + j + 1] = sum2;
    }
}


//Version 2: below neighbor
__global__ void kernel3_below(int m, int n, int k, double *A, double *B, double *C) {

    int i, j, q;
    double sum1 = 0.0,sum2 = 0.0;

    //Computing the global coordinates of the thread
    i = 2 * (blockIdx.x * blockDim.x + threadIdx.x);
    j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < m && j < n){
        for (q = 0; q < k; q++) {
            sum1 += A[i*k + q] * B[q*n + j];
            if (i+1 < m) 
                sum2 += A[(i+1)*k + q] * B[q*n + j];
        }
    
    C[i*n + j] = sum1;
    if (i+1 < m) 
        C[(i+1)*n + j] = sum2;
    }
}



extern "C" {
    void matmult_gpu3(int m, int n, int k, double *A, double *B, double *C) {
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
                
        //Assigning a 2D thread grid in each block
        dim3 threadsPerBlock(block_size, block_size);

        //Defining the grid layout depending on the input dimensions
        //For right
        // d1 = (int) (m - 1) / block_size + 1;
        // d2 = (int) (n / 2 - 1) / block_size + 1;
        
        //For below
        d1 = (int) (m / 2 - 1) / block_size + 1;
        d2 = (int) (n - 1) / block_size + 1;


        //Defining grid size
        dim3 blocksPerGrid(d1, d2);
        
        double start = omp_get_wtime();
        //kernel3_right<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        kernel3_below<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        double seconds = omp_get_wtime() - start;
		printf("Run time (s): %f", seconds);
        
        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
      }
  }