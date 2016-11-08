data{
  int N;
  real y[N];
}
parameters{
  real mu;
  real<lower=0> sigma;
}
model{
  mu ~ normal(0,100);
  sigma ~ cauchy(0,5);
  y ~ normal(mu,sigma);
}
generated quantities{
  real log_lik[N];
  for(n in 1:N){
    log_lik[n]<-normal_log(y[n],mu,sigma);
  }
}

