data {
	int<lower=0> N;
	int<lower=0> M;
	matrix[N, M] X;
	int<lower=0, upper=1> y[N];
}
parameters {
	real beta0;
	vector[M] beta;
}
model {
	for (i in 1:N)
	// X[i] は row_vector, beta は vector だが, dot_product が吸収してくれる
		y[i] ~ bernoulli(inv_logit(beta0+dot_product(X[i],beta)));

	// もちろん単回帰ないし次数が低い簡単なケースではベクトル表現を使わずに
	// y[i] ~ bernoulli(inv_logit(beta0+beta1*x[i]))
	// のようにベタ書きしても良い
}
