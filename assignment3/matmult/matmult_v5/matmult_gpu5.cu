/*
Implementation of matrix multiplication which utilizes shared memory
*/

__global__ void kernel5(int m, int n, int k, double *A, double *B, double *C) {
    
    //Utilizing dynamic shared memory allocation
    extern __shared__ double blocks[];

    __shared__ double* Asub;
    Asub =  &blocks[0];
    __shared__ double* Bsub;
    Bsub =  &blocks[blockDim.x*blockDim.y];

    int q, j;
    double sum;
    const int side = blockDim.x;

    int A_toprow = blockIdx.y*blockDim.y*k;
    int B_topcol = blockIdx.x*blockDim.x;

    for (q = 0; q < k; q += side) {

        int A_toprow_block = A_toprow + q;
        int B_topcol_block = B_topcol + q*n;

        Asub[threadIdx.y*side + threadIdx.x] = A[A_toprow_block + threadIdx.y*k + threadIdx.x];
        Bsub[threadIdx.y*side + threadIdx.x] = B[B_topcol_block + threadIdx.y*n + threadIdx.x];

        __syncthreads();

        sum = 0.0;
        for (j = 0; j < side; j++) {
            sum += Asub[threadIdx.y*side + j] * Bsub[side*j + threadIdx.x];
        }

        //Barrier to ensure not race conditions are present for accessing Asub and Bsub
        __syncthreads();

       C[blockIdx.y*blockDim.y*n + threadIdx.y*n + blockIdx.x*blockDim.x + threadIdx.x] += sum;

    }
}

extern "C" {
    void matmult_gpu5(int m, int n, int k, double *A, double *B, double *C) {
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
        d1 = (int) (m - 1) / block_size + 1;
        d2 = (int) (n - 1) / block_size + 1;

        //Defining grid size
        dim3 blocksPerGrid(d1, d2);

        kernel5<<<blocksPerGrid,threadsPerBlock, (2* threadsPerBlock.x * threadsPerBlock.y * sizeof(double))>>>(m, n, k, A_d, B_d, C_d);
        
        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
    }
}