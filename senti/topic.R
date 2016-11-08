#http://statmodeling.hatenablog.com/entry/topic-model-1
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")

setwd("/Volumes/ubuntu/sentiment/senti")

##https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started-(Japanese)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

library(gtools)

K <- 10   # num of topics
M <- 100  # num of documents
V <- 144  # num of words

set.seed(123)
alpha <- rep(0.8, K)
beta <- rep(0.2, V)
theta <- rdirichlet(M, alpha)
phi <- rdirichlet(K, beta)
z.for.doc <- apply(theta, 1, which.max)　# for Naive Bayes

num.word.v <- round(exp(rnorm(M, 3.0, 0.3)))　　　# data1: low number of words per doc
# num.word.v <- round(exp(rnorm(M, 5.0, 0.3)))  # data2: high number of words per doc


w.1 <- data.frame()  # data type 1: stan manual's w
w.2 <- data.frame()  # data type 2: counted w
for(m in 1:M){
  z <- sample(K, num.word.v[m], prob=theta[m,], replace=T)
  v <- sapply(z, function(k) sample(V, 1, prob=phi[k,]))
  w.1 <- rbind(w.1, data.frame(Doc=m, Word=v))
  w.2 <- rbind(w.2, data.frame(Doc=m, table(Word=v)))
}
w.2$Word <- as.integer(as.character(w.2$Word))
N.1 <- nrow(w.1)  # total word instances
N.2 <- nrow(w.2)  # total word instances
offset.1 <- t(sapply(1:M, function(m){ range(which(m==w.1$Doc)) }))
offset.2 <- t(sapply(1:M, function(m){ range(which(m==w.2$Doc)) }))


bow <- matrix(0, M, V)  # data type 3: bag-of-words
for(n in 1:N.2)
  bow[w.2$Doc[n], w.2$Word[n]] <- w.2$Freq[n]



###### NB
library(rstan)

data <- list(
  K=K,
  M=M,
  V=V,
  N=N.1,
  Z=z.for.doc,
  W=w.1$Word,
  Offset=offset.1,
  Alpha=rep(1, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  file='model/NB.stan',
  data=data,
  iter=1000,
  chains=1
)

###### UM
library(rstan)

data <- list(
  K=K,
  M=M,
  V=V,
  N=N.1,
  W=w.1$Word,
  Offset=offset.1,
  Alpha=rep(1, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  file='model/UM.stan',
  data=data,
  iter=1000,
  thin=1,
  chains=1
)


### LDA
library(rstan)

data <- list(
  K=K,
  M=M,
  V=V,
  N=N.2,
  W=w.2$Word,
  Freq=w.2$Freq,
  Offset=offset.2,
  Alpha=rep(1, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  file='model/LDA.Freq.stan',
  data=data,
  iter=1000,
  chains=1,
  thin=1
)


#### PAM
PAM_MODEL<-"
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
"
library(rstan)

S <- 3

data <- list(
  K=K,
  S=S,
  M=M,
  V=V,
  N=N.2,
  W=w.2$Word,
  Freq=w.2$Freq,
  Offset=offset.2,
  Alpha_S=rep(1, S),
  Alpha=matrix(rep(1, S*K), S, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  model_code = PAM_MODEL,
  data=data,
  iter=1000,
  chains=1,
  thin=1
)
fit
traceplot(fit)