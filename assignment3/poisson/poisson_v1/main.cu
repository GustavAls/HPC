/* main.c - Poisson problem in 3D
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "alloc3d.h"
#include "print.h"
#include "initialize_data.h"

#ifdef _JACOBI
#include "jacobi.h"
#endif

#define N_DEFAULT 100

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
    double 	***u    = NULL;
    double 	***F    = NULL;
    double 	***u_old= NULL;


    /* get the paramters from the command line */
    N         = atoi(argv[1]);	// grid size
    iter_max  = atoi(argv[2]);  // max. no. of iterations
    start_T   = atof(argv[3]);  // start T for all inner grid points
    if (argc == 6) {
	    output_type = atoi(argv[5]);  // ouput type
    }

    // // allocate memory
    // if ( (u = d_malloc_3d(N, N, N)) == NULL ) {
    //     perror("array u: allocation failed");
    //     exit(-1);
    // }
    // if ( (u_old = d_malloc_3d(N, N, N)) == NULL ) {
    //     perror("array u: allocation failed");
    //     exit(-1);
    // }
    // if ( (F = d_malloc_3d(N, N, N)) == NULL ) {
    //     perror("array F: allocation failed");
    //     exit(-1);
    // }

    int N2 = N*N;
    double size = N*N*N*sizeof(double);

    // Gpu
    cudaSetDevice(0);
    double *d_dummy;
    cudaMalloc((void**)&d_dummy,0);

	double *d_u, *d_u_old, *d_F;

    // Allocate on device 
    cudaMalloc((void**)&d_u, size);
    cudaMalloc((void**)&d_u_old, size);
    cudaMalloc((void**)&d_F, size);

    // Pin in host
    cudaMallocHost((void**)&u, size);
    cudaMallocHost((void**)&u_old, size);
    cudaMallocHost((void**)&F, size);

    initialize_data(N, u, u_old, F, start_T);

    // Transfer CPU -> GPU
    transfer_3d_to_1d( d_F, F, N, N, N, cudaMemcpyHostToDevice );
	transfer_3d_to_1d( d_u, u, N, N, N, cudaMemcpyHostToDevice );
	transfer_3d_to_1d( d_u_old, u_old, N, N, N, cudaMemcpyHostToDevice );
    // cudaMemcpy( d_f, f, size, cudaMemcpyHostToDevice );
	// cudaMemcpy( d_u, u, size, cudaMemcpyHostToDevice );
	// cudaMemcpy( d_u_old, u_old, size, cudaMemcpyHostToDevice );

    double start, elapsed;
    int iter;

    
    #ifdef _JACOBI
    start = omp_get_wtime();
    // iter = jacobi(u_old, u, F, N, iter_max);
    elapsed = omp_get_wtime() - start;
    #endif

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
    free(F);
    free(u_old);

    return(0);
}
