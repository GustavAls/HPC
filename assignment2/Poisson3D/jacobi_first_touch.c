/* jacobi.c - Poisson problem in 3d
 * 
 */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

double
jacobi_first_touch(double ***u_old,double ***u,double ***F, int N, int iterations, double tolerance, double start_T) {
    
    
   
    int n;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double factor = 1.0 / 6.0;

    double dist, start, elapsed;
    dist = tolerance + 1.0;
    n = 0;
    #pragma omp parallel for private(n) default(shared)
    for(int i=1;i<(N-1);i++){
        for(int j=1;j<(N-1);j++){
            for(int k=1;k<(N-1);k++){
                u_old[i][j][k] = start_T;
                u[i][j][k] = start_T;
                F[i][j][k] = calculate_f(N, i, j, k);
            }
        }
    }

    for(int i=0;i<(N);i++){
        for(int k=0;k<(N);k++){
            u_old[i][0][k] = 0;
            u[i][0][k] = 0;

            u_old[i][N-1][k] = 20;
            u[i][N-1][k] = 20;
        }
        for(int j=0; j<N; j++){
            u_old[i][j][0] = 20;
            u[i][j][0] = 20;

            u_old[i][j][N-1] = 20;
            u[i][j][N-1] = 20;
        }
    }
    
    for(int j=0; j<N; j++){
        for(int k=0; k<N; k++){
            u_old[0][j][k] = 20;
            u[0][j][k] = 20;

            u_old[N-1][j][k] = 20;
            u[N-1][j][k] = 20;
        }
    }

    start = omp_get_wtime();
    while(dist > tolerance && n < iterations){
        dist = 0;
        #pragma omp parallel for private(n) default(shared) reduction(+: dist)
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
        }

        dist = sqrt(dist);
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
    elapsed = omp_get_wtime() - start;
    return(elapsed);
}
