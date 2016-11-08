data {
  int<lower=0> J;         // 学校の数
  real y[J];              // 推定されている教育の効果
  real<lower=0> sigma[J]; // 教育の効果の標準誤差
}

parameters {
  real mu;
  real<lower=0> tau;
  real eta[J];
}

transformed parameters {
  real theta[J];
  for (j in 1:J)
    theta[j] <- mu + tau * eta[j];
}

model {
  eta ~ normal(0, 1);
  y ~ normal(theta, sigma);
}
