#include <stdlib.h>
#include <stdio.h>

//Identical to week 1 version, however now using single pointer
extern "C" {
	#include <cblas.h>
	void matmult_lib(int m, int n, int k, double *A, double *B, double *C){
		double alpha = 1.0;
        double beta = 0.0;
		cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
              		m, n, k, alpha, A, k, B, n, beta, C, n);
    }
}