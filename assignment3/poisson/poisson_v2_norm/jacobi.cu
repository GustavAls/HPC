__global__ void jacobi(double ***u,double ***u_old, double *norm,double ***F, int N, int iterations, double factor, double delta2){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    double d;

    if (i > 0 && i < N-1 && j > 0 && j < N-1 && k > 0 && k < N-1) { 
        u[i][j][k] = factor * (
            u_old[i-1][j][k] + u_old[i+1][j][k] + 
            u_old[i][j-1][k] + u_old[i][j+1][k] + 
            u_old[i][j][k-1] + u_old[i][j][k+1] + 
            delta2*F[i][j][k]);
        d = (u[i][j][k] - u_old[i][j][k]) * (u[i][j][k] - u_old[i][j][k]);
        atomicAdd(norm, d);
    }
}
