data{
  int N;
  vector[N] y;
  vector[N] x;
}
parameters{
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model{
  vector[N] e;
  alpha ~ normal(0,100);
  beta ~ normal(0,100);
  sigma ~ cauchy(0,5);
  for(n in 1:N){
    e[n] <- y[n] - (alpha + beta * x[n]);
  }
  e ~ normal(0,sigma);
}
