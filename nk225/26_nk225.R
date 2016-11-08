
setwd("~/Documents/workspace/sentiment/cao")
data<-read.csv("26_nk225.csv")

data$diff.ratio<-data$predict.ratio-data$real.ratio
hist(data$diff.ratio)
summary(data$diff.ratio)