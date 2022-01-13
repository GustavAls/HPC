/* gauss_seidel.h - Poisson problem
 *
 */
#ifndef _GAUSS_SEIDEL_H
#define _GAUSS_SEIDEL_H

// define your function prototype here
int gauss_seidel_omp(double ***u,double ***F, int N, int iterations, double tolerance, double start_T, double ***u_old);

#endif
