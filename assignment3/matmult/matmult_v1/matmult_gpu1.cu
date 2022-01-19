/*
An implementation of a sequential model which uses only a single thread
*/

__global__ void kernel1(int m, int n, int k, double *A, double *B, double *C) {

    for (int i = 0; i < m; i++) {
        for (int h = 0; h < k; h++){
            for (int j = 0; j < n; j++) {
                C[i*n + j] += A[i*k + h] * B[h*n + j];
            }
        }
    }
}


extern "C" {
    void matmult_gpu1(int m, int n, int k, double *A, double *B, double *C) {
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

        //Run the kernel on the input parameters, using a single thread
        kernel1<<<1,1>>>(m, n, k, A_d, B_d, C_d);

        cudaDeviceSynchronize();

        //Copying result to host
        cudaMemcpy(C, C_d, m*n*sizeof(double), cudaMemcpyDeviceToHost);

        //Freeing memory allocated
        cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
    }
}