data{
  real y[100];
}
parameters{
  real mu;
  real<lower=0> sigma;
}
model{
  mu ~ normal(0,100);
  sigma ~ cauchy(0,5);
  for(n in 1:100){
    y[n] ~ normal(mu,sigma);
  }
}
