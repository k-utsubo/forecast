# http://statmodeling.hatenablog.com/entry/topic-model-4
library(rstan)
library(hash)

#setwd("/Users/utsubo/Documents/workspace/deeplearning/cao")

#data.bow<-data.frame(doc=c(),word=c())
#data.list<-list.files("txt")
#data.list<-data.list[grep("bow",data.list)]
#for(f in data.list){
#  data.bow<-rbind(data.bow,read.table(paste("txt/",f,sep=""),sep="\t",header=F))
#}
#names(data.bow)<-c("Doc","Word","Freq")
#data.bow$Word<-as.character(data.bow$Word)
#data.bow$Doc<-as.character(data.bow$Doc)

# word ,string to id
#list.word<-as.character(unique(data.bow["Word"])$Word)
#hash.word<-hash()
#lapply(list.word,function(x){hash.word[x]<-length(hash.word)+1})
#id.word<-c()
#for(w in data.bow$Word){
#  id.word<-append(id.word,hash.word[[w]])
#}

# Doc , string to id
#list.doc<-as.character(unique(data.bow["Doc"])$Doc)
#hash.doc<-hash()
#lapply(list.doc,function(x){hash.doc[x]<-length(hash.doc)+1})
#id.doc<-c()
#for(w in data.bow$Doc){
#  id.doc<-append(id.doc,hash.doc[[w]])
#}

#data.word<-data.frame(Doc=id.doc,Word=id.word,Freq=data.bow$Freq)


## doc
doc.tmp<-read.table("txt/doc.txt",header=F,sep="\t")
list.doc<-as.character(doc.tmp$V2)
hash.doc<-hash()
lapply(list.doc,function(x){hash.doc[x]<-length(hash.doc)+1})

## word
word.tmp<-read.table("txt/word.txt",header=F,sep="\t")
list.word<-as.character(word.tmp$V2)
hash.word<-hash()
lapply(list.word,function(x){hash.word[x]<-length(hash.word)+1})

## bow
data.bow<-read.table("txt/bow.txt",header=F,sep="\t")
names(data.bow)<-c("Doc","Word","Freq")
data.bow$Doc<-as.integer(data.bow$Doc)
data.bow$Word<-as.integer(data.bow$Word)
data.bow$Freq<-as.integer(data.bow$Freq)

## idf
data.idf<-read.table("txt/idf.txt",header=F,sep="\t")
names(data.idf)<-c("Word","idf")



M<-length(unique(data.word$Doc))
V<-length(list.word)
N<-length(data.word$Word)
data.offset <- t(sapply(1:M, function(m){ range(which(m==data.word$Doc)) }))


data <- list(
  K=10,     # num of topics
  M=M,      # num of docs
  V=V,  # num of words
  N=N,  # num of word kind
  W=data.word$Word,
  Offset=data.offset,
  Freq=data.word$Freq,
  Alpha=rep(1, K),
  Beta=rep(0.5, V)
)

fit <- stan(
  file='33_lda.stan',
  data=data,
  iter=1000,
  chains=1,
  thin=1
)

save.image("33_lda.RData")

load("33_lda.RData")

## http://aaaazzzz036.hatenablog.com/entry/2013/11/06/225417
## graph
traceplot(fit)
# 事後分布
library (reshape)
library (ggplot2)
post   <- extract (fit, permuted = F)
m.post <- melt (post)
graph  <- ggplot (m.post, aes(x = value))
graph  <- graph + geom_density () + facet_grid(. ~ parameters, scales = "free") + theme_bw() #facet_wrapのほうがいいかも
plot (graph)



la <- rstan::extract(fit)