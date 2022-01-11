void matmult_mnk(int m, int n, int k, double **A, double **B, double **C){

    // Initialisation
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
    		C[i][j] = 0;
    	}
    }

	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
			for (int h = 0; h < k; h++){
				C[i][j] += A[i][h]*B[h][j];
			}
		}
	}
}