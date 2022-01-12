
double calculate_f(int N, int i, int j, int k){
    double delta = 2.0/((double)N-1.0);
    double x = delta*i - 1.0;
    double y = delta*j - 1.0;
    double z = delta*k - 1.0;

    if( (-1.0 <= x && x <= -3.0/8.0) && (-1.0 <= y && y <= -1.0/2.0) && (-2.0/3.0 <= z && z <= 0.0) ){
        return(200.0);
    }
    else{
        return(0.0);
    }
}
