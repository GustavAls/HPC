void matmult_nkm(int m, int n, int k, double **A, double **B, double **C){

    // Initialisation
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
    		C[i][j] = 0;
    	}
    }

	for (int i = 0; i < n; i++) {
		for (int j = 0; j < k; j++) {
			for (int h = 0; h < m; h++){
				C[h][i] += A[h][j]*B[j][i];
			}
		}
	}
}