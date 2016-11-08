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
  file='01_sample_nb.stan',
  data=data,
  iter=1000,
  chains=1
)



