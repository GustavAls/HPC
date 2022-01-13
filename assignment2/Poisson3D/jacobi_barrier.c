/* jacobi.c - Poisson problem in 3d
 * 
 */
#include <math.h>
#include <stdio.h>

int
jacobi_barrier(double ***u_old,double ***u,double ***F, int N, int iterations, double tolerance) {
    int n;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double factor = 1.0 / 6.0;

    double dist, temp_dist;
    dist = 0;
    temp_dist = tolerance + 1.0;
    n = 0;
    #pragma omp parallel shared(delta2, u_old, u, N, tolerance, F, iterations, factor)
    while(temp_dist > tolerance && n < iterations){
        
        #pragma omp for reduction(+: dist)
        for(int i = 1; i < (N - 1); i++){
            for(int j = 1; j < (N - 1); j++){
                for(int k = 1; k < (N - 1); k++){
                    u[i][j][k] = factor * (
                        u_old[i-1][j][k] + u_old[i+1][j][k] + 
                        u_old[i][j-1][k] + u_old[i][j+1][k] + 
                        u_old[i][j][k-1] + u_old[i][j][k+1] + 
                        delta2*F[i][j][k]);
                    dist += (u[i][j][k] - u_old[i][j][k]) * (u[i][j][k] - u_old[i][j][k]);
                }
            }
        } // implicit barrier

        #pragma omp for
        for(int i = 1; i < (N-1); i++){
            for(int j = 1; j < (N - 1); j++){
                for(int k = 1; k < (N - 1); k++){
                    u_old[i][j][k] = u[i][j][k];
                }
            }
        } // implicit barrier
        
        #pragma omp single
        {
            temp_dist = sqrt(dist);
            dist = 0;
            n++;
        } // implicit barrier
    }
    return(n);
}
