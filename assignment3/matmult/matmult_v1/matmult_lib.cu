#include <stdlib.h>
#include <stdio.h>

//Identical to week 1 version, however now using single pointer
extern "C" {
	#include <cblas.h>
    #include <omp.h>
    #include <stdio.h>
	void matmult_lib(int m, int	 n, int k, double *A, double *B, double *C){
		double alpha = 1.0;
        double beta = 0.0;
		double start = omp_get_wtime();
		cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
              		m, n, k, alpha, A, k, B, n, beta, C, n);
		double seconds = omp_get_wtime() - start;
		printf("Run time (s): %f", seconds);
    }
}