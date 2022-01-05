#include <stdio.h>
#include <string.h>
#include <time.h>
#include <gsl/gsl_cblas.h>

void printm(int m, int n, double *array)
{
    for (int i=0; i < m; ++i)
    for (int j=0; j < n; ++j) {
      printf("%g  ", array[j+i*n]);
      if (j == n - 1) {
        printf("\n");
      }
    }
    printf("\n");
}

// FROM https://www.gnu.org/software/gsl/doc/html/cblas.html#examples

int main (void)
{
    const int m = 3;
    const int k = 5;
    const int n = 2;

//   double A[] = { 0.11, 0.12, 0.13,
//                 0.21, 0.22, 0.23 };
    double A[m*k];
    for (int r=0; r<m; r++)
    {
        for (int s=0; s<k; s++)
        {
            A[s+(r*k)] = 10.0*(r+1) + (s+1);
        }
    }

    // double B[] = { 1011, 1012,
    //             1021, 1022,
    //             1031, 1032 };
    double B[k*n];
    for (int r=0; r<k; r++)
    {
        for (int s=0; s<n; s++)
        {
            B[s+(r*n)] = 20.0*(r+1) + (s+1);
        }
    }

    // printm(m,k,A);
    // printm(k,n,B);

    double C[m*n];
    memset(C, 0, m*n*sizeof(double)); // Set C to zeros

    int i = 100;
    double time = 0;
   
    for (int t=0; t<i; t++)
    {
        memset(C, 0, m*n*sizeof(double)); // Set C to zeros

        double t1 = clock();
        cblas_dgemm (CblasRowMajor,
                    CblasNoTrans, CblasNoTrans, m, n, k,
                    1.0, A, k, B, n, 0.0, C, n);        
        double elapsed = clock() - t1;
        time += elapsed;
    }
    time = time / i;
    
    printm(m, n, C);
    printf("Elapsed time = %f\n", time);

    return 0;
}

// gcc -Wall -I/home/simonl/gsl/include -c main_2.c; gcc -L/home/silas/gsl/lib main_2.o -lgsl -lgslcblas -lm -o main_2; ./main_2;