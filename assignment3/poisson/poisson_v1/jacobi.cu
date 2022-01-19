__global__ void jacobi(double ***u_old,double ***u,double ***F, int N, int iterations, double factor, double delta2){

    int i, j, k;

    for (i = 1; i < N-1; i++) {
        for (j = 1; j < N-1; j++) {
            for (k = 1; k < N-1; k++) {
                u[i][j][k] = factor * (
                    u_old[i-1][j][k] + u_old[i+1][j][k] + 
                    u_old[i][j-1][k] + u_old[i][j+1][k] + 
                    u_old[i][j][k-1] + u_old[i][j][k+1] + 
                    delta2*F[i][j][k]);
            }
        }
    }   
}
