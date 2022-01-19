__global__ void jacobi(double ***u_old,double ***u,double ***F, int N, int iterations, double factor, double delta2){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    u[i][j][k] = factor * (
        u_old[i-1][j][k] + u_old[i+1][j][k] + 
        u_old[i][j-1][k] + u_old[i][j+1][k] + 
        u_old[i][j][k-1] + u_old[i][j][k+1] + 
        delta2*F[i][j][k]);
}
