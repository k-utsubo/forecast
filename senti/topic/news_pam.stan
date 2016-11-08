data {
   int<lower=1> K;                    # num topics
   int<lower=1> S;                    # num super topics
   int<lower=1> M;                    # num docs
   int<lower=1> V;                    # num words
   int<lower=1> N;                    # total word instances
   int<lower=1,upper=V> W[N];         # word n
   int<lower=1> Freq[N];              # frequency for word n
   int<lower=1,upper=N> Offset[M,2];  # range of word index per doc
   vector<lower=0>[S] Alpha_S;        # super topic prior
   vector<lower=0>[K] Alpha[S];       # topic prior
   vector<lower=0>[V] Beta;           # word prior
}
parameters {
   simplex[S] theta_S[M];    # super topic dist for doc m
   simplex[K] theta[M,S];    # topic dist for (doc m, super topic s)
   simplex[V] phi[K];        # word dist for topic k
}
model {
   # prior
   for (m in 1:M){
      theta_S[m] ~ dirichlet(Alpha_S);
      for (s in 1:S)
         theta[m,s] ~ dirichlet(Alpha[s]);
   }
   for (k in 1:K)
      phi[k] ~ dirichlet(Beta);

   # likelihood
   for (m in 1:M) {
      for (n in Offset[m,1]:Offset[m,2]) {
         real gamma_S[S];
         for (s in 1:S){
            real gamma[K];
            for (k in 1:K)
               gamma[k] <- log(theta[m,s,k]) + log(phi[k,W[n]]);
            gamma_S[s] <- log(theta_S[m,s]) + log_sum_exp(gamma);
         }
         increment_log_prob(Freq[n] * log_sum_exp(gamma_S));
      }
   }
}
