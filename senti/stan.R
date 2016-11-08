#http://www.fisproject.jp/2015/04/rstan/
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
#Sys.setenv(MAKEFLAGS = "-j4")
#install.packages("rstan", dependencies = TRUE)

#http://rstudio-pubs-static.s3.amazonaws.com/107473_fb355271214d4ffb8679416490576ba4.html
#install.packages("ctv")  #install.packagesはパッケージをインストールする関数。
require(ctv)    #requireあるいはlibraryはパッケージを装備する関数。
#install.views("Psychometrics")  #ctvパッケージにある，関係パッケージをまとめて入れる関数
#install.views("Bayesian")  #Bayes関係のパッケージをじゃんじゃん入れてしまう！
#install.packages("shinystan",repos='http://cran.rstudio.com')
##

library(parallel)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
###### sample
require(rstan)
n <- 100
mu <- 50
sig <- 10
y <- rnorm(n,mu,sig)

hist(y)
##
stancode <- '
data{
int<lower=0> T;
real N[T]; // data
}

parameters {
real mu;
real<lower=0> s2;
}

model{
N~normal(mu,sqrt(s2));
s2~cauchy(0,5);
}
'
datastan <- list(N=y,T=n)
fit <- stan(model_code = stancode,data=datastan,iter=5000,chain=4)

traceplot(fit)

print(fit,digit=3)

###
N <- 1000
x <- rnorm(N, mean = 50, sd = 10)
y <- 10 + 0.8 * x + rnorm(N, mean =0, sd = 7)

plot(x,y)
abline(lm(y~x),col=2)
#
stancode <- '
  data{
int<lower=0> N;
real x[N];
real y[N];
}
parameters {
real alpha;
real beta;
real<lower=0> s;
}
model{
for(i in 1:N)
y[i] ~ normal(alpha + beta * x[i], s);
alpha ~ normal(0, 100);
beta ~ normal(0, 100);
s ~ cauchy(0,5);
}
'
datastan <- list(N=N, x=x, y=y)
fit <- stan(model_code=stancode, data=datastan, iter=1000, chain=4)

traceplot(fit)
print(fit, digit=2)


# https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
### eignth school
stancode <- '
data {
  int<lower=0> J; // number of schools
  real y[J]; // estimated treatment effects
  real<lower=0> sigma[J]; // s.e. of effect estimates
}
parameters {
  real mu;
  real<lower=0> tau;
  real eta[J];
}
transformed parameters {
  real theta[J];
  for (j in 1:J)
    theta[j] = mu + tau * eta[j];
}
model {
  target += normal_lpdf(eta | 0, 1);
  target += normal_lpdf(y | theta, sigma);
}
'
schools_dat <- list(J = 8,
                    y = c(28,  8, -3,  7, -1,  1, 18, 12),
                    sigma = c(15, 10, 16, 11,  9, 11, 10, 18))

fit <- stan(model_code=stancode, data = schools_dat,
            iter = 1000, chains = 4)

print(fit)
plot(fit)
pairs(fit, pars = c("mu", "tau", "lp__"))

la <- extract(fit, permuted = TRUE) # return a list of arrays
mu <- la$mu



### return an array of three dimensions: iterations, chains, parameters
a <- extract(fit, permuted = FALSE)

### use S3 functions as.array (or as.matrix) on stanfit objects
a2 <- as.array(fit)
m <- as.matrix(fit)


require(rstan)
#### http://www.slideshare.net/simizu706/ss-57721033
y<-rnorm(100,5,1)
stancode<-"
data{
  real y[100];
}
parameters{
  real mu;
  real<lower=0> sigma;
}
model{
  y ~ normal(mu,sigma);
}
"
fit <- stan(model_code=stancode,data=list(y=y))
traceplot(fit)
mu<-rstan::extract(fit)$mu
hist(mu)
stan_trace(fit,pars="mu")
stan_hist(fit,pars="mu")
stan_dens(fit,pars="mu",separate_chains=T)
stan_ac(fit,pars="mu",separate_chains=T)



#####
N <- 1000
x <- rnorm(N, mean=50, sd=10)
y <- 10 + 0.8 * x + rnorm(N, mean=0, sd=7)

stancode <- '
  data {
    int N;
    real x[N];
    real y[N];
  }

  parameters { // 推定するパラメータ
    real alpha; // 平均の第一項 (10)
    real beta; // 平均の第二項の定数 (0.8)
    real s; // 標準偏差 (7)
  }

  model{
    for(i in 1:N)
      y[i] ~ normal(alpha + beta * x[i], s); // yを正規分布で推定
    alpha ~ normal(0, 100); // alphaを正規分布で推定
    beta ~ normal(0, 100); // betaを正規分布で推定
    s ~ inv_gamma(0.001, 0.001); // sを逆ガンマ分布で推定
  }
'

datastan <- list(N=N, x=x, y=y) # x,y によるデータセット
fit <- stan(model_code=stancode, data=datastan, iter=1000, chain=4) # stanを呼ぶ
traceplot(fit, ask=T)
print(fit, digit=2)




########https://rpubs.com/uri-sy/iwanami_ds1
library(rstan)
library(ggmcmc)
#install.packages("broom")
library(broom)
setwd("/Volumes/ubuntu/sentiment/senti")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
download.file(url = "http://hosho.ees.hokudai.ac.jp/~kubo/stat/iwnmDS1/data/data.RData",
              destfile = paste(getwd(), "", "data.Rdata", sep = "/"))
load(file = "data.Rdata")
# データ構造の確認。
dplyr::glimpse(d)

d %>% glm(mean.Y ~ 1 + Age + Age:X, data = .) %>%
  broom::tidy() %>%
  knitr::kable(format = "markdown", digits = 4)



#############http://norimune.net/2794
library(rstan)
library(loo)
set.seed(123)
y<-rnorm(100,5,2)
hist(y)
model4<-stan_model("normal0.stan")
datastan<-list(y=y)
fit4<-sampling(model4,data=datastan)
fit4

WAIC<-function(fit){
  log_lik<- rstan::extract(fit)$log_lik
  lppd<-sum(log(colMeans(exp(log_lik))))
  p_waic<-sum(apply(log_lik,2,var))
  waic<-2*(-lppd+p_waic)
  return(list(waic=waic,lppd=lppd,p_waic=p_waic))
}
fit6<-stan("normal.stan",data=list(N=100,y=y))
WAIC(fit6)

library(MASS)
mu<-c(0,0)
Sigma<-matrix(c(1,0.7,0.7,1),2,2)
set.seed(123)
y<-mvrnorm(25,mu,Sigma)


#reg1.stan
x<-rnorm(100,0,1)
y<-2+5*x +rnorm(100,0,3)
summary(lm(y~x))
model11<-stan_model("reg1.stan")
data<-list(N=100,y=y,x=x)
fit11<-sampling(model11,data=data)
fit11

#reg2.stan
model12<-stan_model("reg2.stan")
fit12<-sampling(model12,data=list(N=100,x=x,y=y))
fit12

#reg3.stan
model13<-stan_model("reg3.stan")
fit13<-sampling(model13,data=list(N=100,x=x,y=y))
fit13

###
set.seed(123)
x1<-rnorm(100,0,1)
x2<-rnorm(100,0,1)
y<-2+5*x1+7*x2+rnorm(100,0,3)
summary(lm(y~x1+x2))
#
intercept<-rep(1,100)
x<-data.frame(intercept,x1,x2)
#
data<-list(N=100,M=3,y=y,x=x)
model14<-stan_model("reg4.stan")
fit14<-sampling(model14,data=data)
print(fit12,probs=c(0.025,0.5,0.975))





