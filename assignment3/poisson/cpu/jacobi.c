/* jacobi.c - Poisson problem in 3d
 * 
 */
#include <math.h>
#include <stdio.h>
#include <omp.h>

int
jacobi(double ***u_old,double ***u,double ***F, int N, int iterations) {
    int n;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double factor = 1.0 / 6.0;

    n = 0;
    while(n < iterations){
        #pragma omp parallel for
        for(int i = 1; i < (N - 1); i++){
            for(int j = 1; j < (N - 1); j++){
                for(int k = 1; k < (N - 1); k++){
                    u[i][j][k] = factor * (
                        u_old[i-1][j][k] + u_old[i+1][j][k] + 
                        u_old[i][j-1][k] + u_old[i][j+1][k] + 
                        u_old[i][j][k-1] + u_old[i][j][k+1] + 
                        delta2*F[i][j][k]);
                }
            }
        }
        #pragma omp parallel for
        for(int i = 1; i < (N-1); i++){
            for(int j = 1; j < (N - 1); j++){
                for(int k = 1; k < (N - 1); k++){
                    u_old[i][j][k] = u[i][j][k];
                }
            }
        }
        n++;
    }
    return(n);
}
