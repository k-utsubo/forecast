data{
  int N;
  int M;
  vector[N] y;
  matrix[N,M] x; // 説明変数
}
parameters{
  vector[M] beta;
  real<lower=0> sigma;
}
model{
  beta ~ normal(0,100);
  sigma ~ cauchy(0,5);
  y ~ normal(x*beta,sigma);
}
