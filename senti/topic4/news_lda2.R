Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(gtools)
#install.packages("hash")
library(hash)
#setwd("/Volumes/admin/sentiment/senti/topic2")

set.seed(123)
data.bow<-read.csv("../../../data/data/news/bow2.txt",sep="\t",header=F)
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

####
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
  file='news_lda.stan',
  data=data,
  iter=1000,
  chains=1,
  thin=1
)
