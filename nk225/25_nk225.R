
setwd("~/Documents/workspace/sentiment/cao")
data<-read.csv("25_nk225.csv")

data$diff.ratio<-data$predict.ret-data$real.ret
plot(x=data$X,y=data$predict.price,type="l")
par(new=T)
plot(x=data$X,y=data$real.price,type="l",col="2")


hist(data$diff.ratio)
summary(data$diff.ratio)