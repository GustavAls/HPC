/* jacobi.c - Poisson problem in 3d
 * 
 */
#include <math.h>
#include <stdio.h>

int
jacobi(double ***u_old,double ***u,double ***F, int N, int iterations, double threshold) {

    int n;
    int i, j, k;
    double dist;
    double frac = 1.0 / 6.0;
    double delta_squared = (2.0 / (N + 1)) * (2.0 / (N + 1));
    char name[12] = "jacobi";

    dist = 100000000000.0;
    n = 0;

    while(dist > threshold && n < iterations){
        dist=0;
        for(i = 1; i < (N - 1); i++){
            for(j = 1; j < (N - 1); j++){
                for(k = 1; k < (N - 1); k++){
                    u[i][j][k] = frac * (u_old[i-1][j][k] + u_old[i+1][j][k] + u_old[i][j-1][k] + u_old[i][j+1][k] 
                    + u_old[i][j][k-1] + u_old[i][j][k+1] + delta_squared * F[i][j][k]);
                    dist += (u[i][j][k] - u_old[i][j][k]) * (u[i][j][k] - u_old[i][j][k]);
                }
            }
        }

        dist = sqrt(dist);
        //Set the values computed for u, into u_old
        for(i = 1; i < (N-1); i++){
            for(j = 1; j < (N - 1); j++){
                for(k = 1; k < (N - 1); k++){
                    u_old[i][j][k] = u[i][j][k];
                }
            }
        }
        n++;
    }
    return(n);
}
