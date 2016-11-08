data {
   int<lower=1> K;                    # num topics
   int<lower=1> M;                    # num docs
   int<lower=1> V;                    # num words
   int<lower=1> N;                    # total word instances
   int<lower=1,upper=V> W[N];         # word n
   int<lower=1,upper=N> Offset[M,2];  # range of word index per doc
   # hyperparameter
   vector<lower=0>[K] Alpha;     # topic prior
   vector<lower=0>[V] Beta;      # word prior
}
parameters {
   simplex[K] theta;      # topic prevalence
   simplex[V] phi[K];     # word dist for topic k
}
model {
   # prior
   theta ~ dirichlet(Alpha);
   for (k in 1:K)
      phi[k] ~ dirichlet(Beta);

   # likelihood
   for (m in 1:M){
      real gamma[K];
      for (k in 1:K){
         gamma[k] <- log(theta[k]);
         for (n in Offset[m,1]:Offset[m,2])
            gamma[k] <- gamma[k] + log(phi[k,W[n]]);
      }
      increment_log_prob(log_sum_exp(gamma));
   }
}
