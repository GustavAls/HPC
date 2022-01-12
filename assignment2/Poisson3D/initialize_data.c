#include "calculate_f.h"

void initialize_data(int N, double ***u, double ***u_old, double ***F, double start_T){
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
    // Inner
    for(int i=1;i<(N-1);i++){
        for(int j=1;j<(N-1);j++){
            for(int k=1;k<(N-1);k++){
                u_old[i][j][k] = start_T;
                u[i][j][k] = start_T;
                F[i][j][k] = calculate_f(N, i , j, k);
            }
        }
    }
}
