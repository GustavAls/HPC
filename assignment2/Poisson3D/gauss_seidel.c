/* gauss_seidel.c - Poisson problem in 3d
 *
 */
#include <math.h>
#include <stdio.h>

int
gauss_seidel(double*** u,double*** F,int N, int iter, double tolerance) {
    int n;
    double delta = 2.0/((double)N-1.0);
    double delta2 = delta*delta;
    double old_u;
    double d;
    d = tolerance + 1.0;
    n = 0;
    while(d > tolerance && n < iter){
        d=0;
        for(int i=1;i<(N-1);i++){
            for(int j=1;j<(N-1);j++){
                for(int k=1;k<(N-1);k++){
                    old_u = u[i][j][k];
                    u[i][j][k] = 1.0/6.0*(
                        u[i-1][j][k] + u[i+1][j][k] + 
                        u[i][j-1][k] + u[i][j+1][k] + 
                        u[i][j][k-1] + u[i][j][k+1] + 
                        delta2*F[i][j][k]
                    );
                    d += (u[i][j][k] - old_u)*(u[i][j][k] - old_u);
                }
            }
        }
        d = sqrt(d);
        n++;
    }
    return(n);
}

