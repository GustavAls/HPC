/* gauss_seidel.c - Poisson problem in 3d
 *
 */
#include <math.h>
#include <stdio.h>
#include <omp.h>

int
gauss_seidel_omp(double ***u,double ***F,int N, int iterations, double tolerance) {
    int n = 0;
    int i, j, k;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double div = 1.0/6.0;
    for (n = 0; n < iterations; n++){
        //Default schedule would be (static, N/P), with N work and P threads
        #pragma omp for default(none) private(n) \
            shared(delta2, u, N, tolerance, F, iterations, div) private(i,j,k) \
            ordered(2) schedule(static,1)
        for(i = 1; i < (N - 1); i++){
            for(j = 1; j < (N - 1); j++){
                #pragma omp ordered depend(sink:i-1,j) depend(sink:i,j-1)
                for(k = 1; k < (N - 1); k++){
                    u[i][j][k] = div * (
                        u[i-1][j][k] + u[i+1][j][k] + 
                        u[i][j-1][k] + u[i][j+1][k] + 
                        u[i][j][k-1] + u[i][j][k+1] + 
                        delta2 * F[i][j][k]
                    );
                    }
                #pragma omp ordered depend(source) /*Ending ordered*/
            }
        }/*End of for ordered*/
    }/*End of parallel*/
    return(n);
}