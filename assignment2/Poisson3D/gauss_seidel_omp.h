/* gauss_seidel.h - Poisson problem
 *
 */
#ifndef _GAUSS_SEIDEL_OMP_H
#define _GAUSS_SEIDEL_OMP_H

// define your function prototype here
int gauss_seidel(double ***u,double ***F, int N, int iterations, double tolerance);

#endif
