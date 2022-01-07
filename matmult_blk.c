void matmult_blk(int M, int N, int K, double **A, double **B, double **C, int bs) {
	bs = fmax(1, fmin(bs, K));
	
	for (int i = 0; i < M; i++) {
		for (int j = 0; j < N; j++) {
    		C[i][j] = 0;
    	}
    }

    int min_m0, min_k0, min_n0;

	for (int m0 = 0; m0 < M; m0 += bs) {
		min_m0 = (M < m0 + bs) ? M : m0 + bs; 
		for (int k0 = 0; k0 < K; k0 += bs) {
			min_k0 = (M < k0 + bs) ? M : k0 + bs;
			for (int n0 = 0; n0 < N; n0 += bs) {
                min_n0 = (M < n0 + bs) ? M : n0 + bs; 
				for (int m = m0; m < min_m0; m++) {
					for (int k = k0; k < min_k0; k++) {
						for (int n = n0; n < min_n0; n++)
							C[m][n] += A[m][k] * B[k][n];
					}
				}
			}
		}
	}
}