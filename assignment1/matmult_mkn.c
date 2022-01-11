void matmult_mkn(int m, int n, int k, double **A, double **B, double **C){

    // Initialisation
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
    		C[i][j] = 0;
    	}
    }

	for (int i = 0; i < m; i++) {
		for (int j = 0; j < k; j++) {
			for (int h = 0; h < n; h++){
				C[i][h] += A[i][j]*B[j][h];
			}
		}
	}
}