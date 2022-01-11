#include <stdio.h>
#include <string.h>
#include <cblas.h>

void matmult_lib(int m, int n, int k, double **A, double **B, double **C)
{
    // Because single pointers
    double *vecA = A[0];
    double *vecB = B[0];
    double *vecC = C[0];
    double alpha = 1.0;
    double beta = 0.0;
    cblas_dgemm (CblasRowMajor,
                    CblasNoTrans, CblasNoTrans, m, n, k,
                    alpha, vecA, k, vecB, n, beta, vecC, n);        
}