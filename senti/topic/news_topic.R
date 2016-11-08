Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
############ yahoo news
library(RMeCab)
setwd("/Volumes/ubuntu/sentiment/senti/topic")

data.tfidf<-read.csv("../../../data/data/news/tfidf.txt",sep="\t",header=F)
hist(data.tfidf$V3)
summary(data.tfidf$V3)
#
sub.tfidf<-subset(data.tfidf,V3>=0.7)
data.keywords<-unique(sub.tfidf["V2"])

#### data http://statmodeling.hatenablog.com/entry/topic-model-1
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Volumes/ubuntu/sentiment/senti/topic")

library(gtools)
#install.packages("hash")
library(hash)



set.seed(123)
data.bow<-read.csv("../../../data/data/news/bow.txt",sep="\t",header=F)
names(data.bow)<-c("Doc","Word","Freq")
data.bow$Doc<-as.character(data.bow$Doc)
data.bow$Word<-as.character(data.bow$Word)


hash.docs<-hash()
data.docs<-unique(data.bow["Doc"])$Doc
lapply(data.docs,function(x){hash.docs[x]<-length(hash.docs)+1})

hash.words<-hash()
data.words<-unique(data.bow["Word"])$Word
lapply(data.words,function(x){hash.words[x]<-length(hash.words)+1})


K <- 10   # num of topics
M <- length(data.docs)  # num of documents
V <- length(data.words)  # num of words


df.words<-c()
df.docs<-c()
for(i in 1:length(data.bow$Doc)){
  df.words<-c(df.words,hash.words[[data.bow[i,]$Word]])
  df.docs<-c(df.docs,hash.docs[[data.bow[i,]$Doc]])
}
data.news<-data.frame(Doc=df.docs,Word=df.words,Freq=data.bow$Freq)

data.offset <- t(sapply(1:M, function(m){ range(which(m==data.news$Doc)) }))

### PAM
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
S <- 3

data <- list(
  K=K,
  S=S,
  M=M,
  V=V,
  N=length(data.news$Doc),
  W=data.news$Word,
  Freq=data.news$Freq,
  Offset=data.offset,
  Alpha_S=rep(1, S),
  Alpha=matrix(rep(1, S*K), S, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  file='news_pam.stan',
  data=data,
  iter=1000,
  chains=1,
  thin=1
)


### LDA
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

data <- list(
  K=K,
  M=M,
  V=V,
  N=length(data.news$Doc),
  W=data.news$Word,
  Freq=data.news$Freq,
  Offset=data.offset,
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

