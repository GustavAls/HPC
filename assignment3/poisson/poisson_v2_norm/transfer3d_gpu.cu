#include <cuda_runtime_api.h>
#include <helper_cuda.h>

void
transfer_3d(double ***dst, double ***src, int m, int n, int k, int flag)
{
    long nPtr = m + m * n;
    long nBlk = k * n * m;

    // we only transfer the value block
    checkCudaErrors( cudaMemcpy((double *) dst + nPtr,
                                (double *) src + nPtr,
                                nBlk * sizeof(double),
                                (cudaMemcpyKind) flag) );
}

void
transfer_3d_to_1d(double *dst, double ***src, int m, int n, int k, int flag)
{
    long nPtr = m + m * n;
    long nBlk = k * n * m;

    // we only transfer the value block
    checkCudaErrors( cudaMemcpy((double *) dst,
                                (double *) src + nPtr,
                                nBlk * sizeof(double),
                                (cudaMemcpyKind) flag) );
}

void
transfer_3d_from_1d(double ***dst, double *src, int m, int n, int k, int flag)
{
    long nPtr = m + m * n;
    long nBlk = k * n * m;

    // we only transfer the value block
    checkCudaErrors( cudaMemcpy((double *) dst + nPtr,
                                (double *) src,
                                nBlk * sizeof(double),
                                (cudaMemcpyKind) flag) );
}
