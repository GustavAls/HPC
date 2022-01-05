#include <stdio.h>
#include <string.h>
#include <gsl/gsl_cblas.h>

void matmult_lib(int m, int n, int k, double **A, double **B, double **C)
{
    double alpha = 1.0;
    double beta = 0.0;
    cblas_dgemm (CblasRowMajor,
                    CblasNoTrans, CblasNoTrans, m, n, k,
                    alpha, A, k, B, n, beta, C, n);        
}