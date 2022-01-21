__inline__ __device__ double warpReduceSum(double value)
{
  for (int i = 16; i > 0; i /= 2)  {
     value += __shfl_down_sync(-1, value, i);
      }
   return value;
  }
  
__inline__ __device__ double
blockReduceSum(double value) {
  __shared__ double smem[32];
  int indexThread = threadIdx.x + threadIdx.y * blockDim.x+ threadIdx.z * blockDim.y* blockDim.x;


  if (indexThread < warpSize) {
    smem[indexThread]=0;
  }
  __syncthreads();

  value =  warpReduceSum(value);

  if   (indexThread % warpSize == 0)
    {
    smem[indexThread / warpSize]=value;
    }
  __syncthreads();
  if (indexThread < warpSize) {
    value=smem[indexThread];
  }
return warpReduceSum(value);}

__global__ void jacobi(double ***u,double ***u_old, double *norm,double ***F, int N, int iterations, double factor, double delta2){

    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    double d = 0;

    if (i > 0 && i < N-1 && j > 0 && j < N-1 && k > 0 && k < N-1) { 
        u[i][j][k] = factor * (
            u_old[i-1][j][k] + u_old[i+1][j][k] + 
            u_old[i][j-1][k] + u_old[i][j+1][k] + 
            u_old[i][j][k-1] + u_old[i][j][k+1] + 
            delta2*F[i][j][k]);
        d = (u[i][j][k] - u_old[i][j][k]) * (u[i][j][k] - u_old[i][j][k]);
    }
    blockReduceSum(d);
    if (threadIdx.x == 0 && threadIdx.y == 0 && threadIdx.z == 0 )
    {
      atomicAdd(norm, d);
    }
}
