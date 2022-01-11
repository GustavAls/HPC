void matmult_nmk(int m, int n, int k, double **A, double **B, double **C){

    // Initialisation
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
    		C[i][j] = 0;
    	}
    }

	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			for (int h = 0; h < k; h++){
				C[j][i] += A[j][h]*B[h][i];
			}
		}
	}
}