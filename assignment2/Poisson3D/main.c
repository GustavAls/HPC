/* main.c - Poisson problem in 3D
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "alloc3d.h"
#include "print.h"

#ifdef _JACOBI
#include "jacobi.h"
#endif

#ifdef _GAUSS_SEIDEL
#include "gauss_seidel.h"
#endif

#define N_DEFAULT 100

double calculate_f(int N, int i, int j, int k){
    double delta = 2.0/((double)N-1.0);
    double x = delta*i - 1.0;
    double y = delta*j - 1.0;
    double z = delta*k - 1.0;

    if( -1.0<=x && x<=-3.0/8.0 ){
        if( -1.0<=y && y<=-1.0/2.0){
            if( -2.0/3.0<=z && z<=0.0){
                return(200.0);
            }
        }
    }
    else{
    return(0.0);
    }
}

int
main(int argc, char *argv[]) {

    int 	N = N_DEFAULT;
    int 	iter_max = 1000;
    double	tolerance;
    double	start_T;
    int		output_type = 0;
    char	*output_prefix = "poisson_res";
    char        *output_ext    = "";
    char	output_filename[FILENAME_MAX];
    double 	***u = NULL;
    double 	***F = NULL;


    /* get the paramters from the command line */
    N         = atoi(argv[1]);	// grid size
    iter_max  = atoi(argv[2]);  // max. no. of iterations
    tolerance = atof(argv[3]);  // tolerance
    start_T   = atof(argv[4]);  // start T for all inner grid points
    if (argc == 6) {
	    output_type = atoi(argv[5]);  // ouput type
    }

    // allocate memory
    if ( (u = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array u: allocation failed");
        exit(-1);
    }
    if ( (F = d_malloc_3d(N, N, N)) == NULL ) {
        perror("array F: allocation failed");
        exit(-1);
    }

    // This is hideous, maybe should put it in a separate file? Idk
    for(int i=0;i<(N);i++){
        for(int k=0;k<(N);k++){
            // u_old[i][0][k] = 0;
            u[i][0][k] = 0;

            // u_old[i][N-1][k] = 20;
            u[i][N-1][k] = 20;
        }
        for(int j=0; j<N; j++){
            // u_old[i][j][0] = 20;
            u[i][j][0] = 20;

            // u_old[i][j][N-1] = 20;
            u[i][j][N-1] = 20;
        }
    }
    for(int j=0; j<N; j++){
        for(int k=0; k<N; k++){
            // u_old[0][j][k] = 20;
            u[0][j][k] = 20;

            // u_old[N-1][j][k] = 20;
            u[N-1][j][k] = 20;
        }
    }
    //Interior points
    for(int i=1;i<(N-1);i++){
        for(int j=1;j<(N-1);j++){
            for(int k=1;k<(N-1);k++){
                // u_old[i][j][k] = start_T;
                u[i][j][k] = start_T;
                F[i][j][k] = calculate_f(i,j,k,N);
            }
        }
    }

    double start, elapsed;
    int iter;
    #ifdef _GAUSS_SEIDEL
    start = omp_get_wtime();
    iter = gauss_seidel(u, F, N, iter_max, tolerance);
    elapsed = omp_get_wtime() - start;
    #endif

    // FILE *file = fopen("result.txt", "w");
    // fprintf(file, "%f %d", elapsed, iter);
    printf("%d %f %d \n", N, elapsed, iter);

    // dump  results if wanted 
    switch(output_type) {
	case 0:
	    // no output at all
	    break;
	case 3:
	    output_ext = ".bin";
	    sprintf(output_filename, "%s_%d%s", output_prefix, N, output_ext);
	    fprintf(stderr, "Write binary dump to %s: ", output_filename);
	    print_binary(output_filename, N, u);
	    break;
	case 4:
	    output_ext = ".vtk";
	    sprintf(output_filename, "%s_%d%s", output_prefix, N, output_ext);
	    fprintf(stderr, "Write VTK file to %s: ", output_filename);
	    print_vtk(output_filename, N, u);
	    break;
	default:
	    fprintf(stderr, "Non-supported output type!\n");
	    break;
    }

    // de-allocate memory
    free(u);

    return(0);
}
