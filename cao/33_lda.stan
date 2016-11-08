data {
   int<lower=2> K;                    # num topics
   int<lower=2> V;                    # num words
   int<lower=1> M;                    # num docs
   int<lower=1> N;                    # total word instances
   int<lower=1,upper=V> W[N];         # word n
   int<lower=1> Freq[N];              # frequency of word n
   int<lower=1,upper=N> Offset[M,2];  # range of word index per doc
   vector<lower=0>[K] Alpha;          # topic prior
   vector<lower=0>[V] Beta;           # word prior
}
parameters {
   simplex[K] theta[M];   # topic dist for doc m
   simplex[V] phi[K];     # word dist for topic k
}
model {
   # prior
   for (m in 1:M)
      theta[m] ~ dirichlet(Alpha);
   for (k in 1:K)
      phi[k] ~ dirichlet(Beta);

   # likelihood
   for (m in 1:M) {
      for (n in Offset[m,1]:Offset[m,2]) {
         real gamma[K];
         for (k in 1:K)
            gamma[k] <- log(theta[m,k]) + log(phi[k,W[n]]);
         increment_log_prob(Freq[n] * log_sum_exp(gamma));
      }
   }
}