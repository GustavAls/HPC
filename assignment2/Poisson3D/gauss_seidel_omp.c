/* gauss_seidel.c - Poisson problem in 3d
 *
 */
#include <math.h>
#include <stdio.h>
#include <omp.h>

int
gauss_seidel(double ***u,double ***F,int N, int iterations, double tolerance) {
    int n = 0;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double old_u;
    double dist;
    dist = tolerance + 1.0;
    #pragma omp parallel default(shared) private(n)
    {
    for (n = 0; n < iterations; n++){
        dist = 0;
        //Default schedule would be (static, N/P), with N work and P threads
        #pragma omp for reduction(+: dist) ordered(2) schedule(static, 1) 
        {
        for(int i = 1; i < (N - 1); i++){
            for(int j = 1; j < (N - 1); j++){
            #pragma omp ordered depend(sink:i-1, j) depend(sink:i, j-1)
                for(int k = 1; k < (N - 1); k++){
                    old_u = u[i][j][k];
                    u[i][j][k] = 1.0 / 6.0*(
                        u[i-1][j][k] + u[i+1][j][k] + 
                        u[i][j-1][k] + u[i][j+1][k] + 
                        u[i][j][k-1] + u[i][j][k+1] + 
                        delta2 * F[i][j][k]
                    );
                    dist += (u[i][j][k] - old_u)*(u[i][j][k] - old_u);
                }
            #pragma omp ordered depend(source) /*Ending ordered*/
            }
        }
        }/*End of for ordered*/
        dist = sqrt(dist);
        n++;
    }
    }/*End of parallel*/
    return(n);
}