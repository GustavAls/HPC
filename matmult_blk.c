void matmult_blk(int M, int N, int K, double **A, double **B, double **C, int bs) {
	bs = fmax(1, fmin(bs, K));
	
	for (int i = 0; i < M; i++) {
		for (int j = 0; j < N; j++) {
    		C[i][j] = 0;
    	}
  }

	for (int m0 = 0; m0 < M; m0 += bs) {
		for (int k0 = 0; k0 < K; k0 += bs) {
			for (int n0 = 0; n0 < N; n0 += bs) {
				for (int m = m0; m < fmin(m0 + bs, M); m++) {
					for (int k = k0; k < fmin(k0 + bs, K); k++) {
						for (int n = n0; n < fmin(n0 + bs, N); n++)
							C[m][n] += A[m][k] * B[k][n];
					}
				}
			}
		}
	}
}