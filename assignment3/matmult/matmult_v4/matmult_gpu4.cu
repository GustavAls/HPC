#define STRIDE 4
extern "C"{
    __global__ void kernel4(double *A, double *B, double *C,int k,int m,int n){
        int i, j, q, l;
        double sum;
            
        //Computing the global coordinates of the thread
        int i = (blockIdx.y * blockDim.y + threadIdx.y) * STRIDE;
        int j = blockIdx.x * blockDim.x + threadIdx.x;

        if (i < m && j < n)
        {
            for(q = 0; q < k; q++){
                sum = 0.0;
                for(l = 0; l < STRIDE; l++){
                    if (i + l < m)
                        sum += A[(i+l)*k + q] * B[q*n + j];
                }
                C[(i+l)*n+j] = sum;
            }
        }
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
        d1 = (int) (m - 1) / block_size + 1;
        d2 = (int) (n / STRIDE - 1) / block_size + 1;

        //Defining grid size
        dim3 blocksPerGrid(d1, d2);

        kernel3_below<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        //kernel3_right<<<blocksPerGrid,threadsPerBlock>>>(m, n, k, A_d, B_d, C_d);
        
        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
      }
  }