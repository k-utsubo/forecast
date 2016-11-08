#http://statmodeling.hatenablog.com/entry/topic-model-1
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")

setwd("/Volumes/ubuntu/sentiment/senti")

######http://tjo.hatenablog.com/entry/2014/01/27/235048
library(rstan)

d <- read.table("conflict_sample.txt", header=T, quote="\"")
d$cv<-as.numeric(d$cv)-1
d.dat<-list(N=dim(d)[1],M=dim(d)[2]-1,X=d[,-8],y=d$cv)

d.fit<-stan(file='model/d.stan',data=d.dat,iter=1000,chains=4)
d.fit
##
d.ext<-extract(d.fit,permuted=T)
N.mcmc<-length(d.ext$beta0)

require(ggplot2)
require(reshape2)
require(plyr)



##https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started-(Japanese)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

####
schools_dat <- list(J = 8,
                    y = c(28,  8, -3,  7, -1,  1, 18, 12),
                    sigma = c(15, 10, 16, 11,  9, 11, 10, 18))

fit <- stan(file = 'model/8schools.stan', data = schools_dat,
            iter = 1000, chains = 4)

#
print(fit)
plot(fit)
pairs(fit, pars = c("mu", "tau", "lp__"))

la <- extract(fit, permuted = TRUE) # arraysのlistを返す
mu <- la$mu

### iterations, chains, parametersの3次元arrayを返す
a <- extract(fit, permuted = FALSE)

### stanfitオブジェクトにS3関数のas.array（やas.matrix）を使う
a2 <- as.array(fit)
m <- as.matrix(fit)



##### rats
require(RCurl)

y <- read.table('https://raw.github.com/wiki/stan-dev/rstan/rats.txt', header = TRUE)
x <- c(8, 15, 22, 29, 36)
xbar <- mean(x)
N <- nrow(y)
T <- ncol(y)
rats_fit <- stan(file = 'https://raw.githubusercontent.com/stan-dev/example-models/master/bugs_examples/vol1/rats/rats.stan')



######http://logics-of-blue.com/stan%E3%81%AB%E3%82%88%E3%82%8B%E3%83%99%E3%82%A4%E3%82%BA%E6%8E%A8%E5%AE%9A%E3%81%AE%E5%9F%BA%E7%A4%8E/
require(rstan)
# 計算の並列化
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

localLevelModel_1 <- "
data {
int n;
vector[n] Nile;
}
parameters {
real mu;                # 確定的レベル（データの平均値）
real<lower=0> sigmaV;   # 観測誤差の大きさ
}
model {
for(i in 1:n) {
Nile[i] ~ normal(mu, sqrt(sigmaV));
}
}
"
# Stanに渡すために整形
NileData <- list(Nile = as.numeric(Nile), n=length(Nile))

# 乱数の種
set.seed(1)

# 確定的モデル
NileModel_1 <- stan(
  model_code = localLevelModel_1,
  data=NileData,
  iter=1100,
  warmup=100,
  thin=1,
  chains=3
)
# 結果の確認
# 推定されたパラメタ
NileModel_1
print(NileModel_1)
plot(NileModel_1)
traceplot(NileModel_1)


set.seed(1)

# warmup期間が短すぎたようなので、増やす
NileModel_2 <- stan(
  model_code = localLevelModel_1,
  data=NileData,
  iter=200,
  warmup=10,
  #iter=1500,
  #warmup=500,
  thin=1,
  chains=3
)
# 計算の過程を図示
#plot(NileModel_2)
traceplot(NileModel_2)

plot(Nile)