#include <stdio.h>
#include <string.h>
#include <time.h>
#include <gsl/gsl_cblas.h>

void matmult_lib(int m, int n, int k, doulbe **A, double **B, double **C)
{
    double alpha = 1.0;
    double beta = 0.0;
    cblas_dgemm (CblasRowMajor,
                    CblasNoTrans, CblasNoTrans, m, n, k,
                    alpha, A, k, B, n, beta, C, n);        
}

// gcc -Wall -I/home/simonl/gsl/include -c main_2.c; gcc -L/home/silas/gsl/lib main_2.o -lgsl -lgslcblas -lm -o main_2; ./main_2;