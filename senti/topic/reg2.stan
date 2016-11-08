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
  vector[N] yhat;
  alpha ~ normal(0,100);
  beta ~ normal(0,100);
  sigma ~ cauchy(0,5);
  for(n in 1:N){
    yhat[n] <-  (alpha + beta * x[n]);
  }
  y ~ normal(yhat,sigma);
}
