
setwd("~/Documents/workspace/sentiment/cao")
library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md.qr.com",user="root",password="")

data.csv<-read.csv("33_nk225.csv")
data.csv$diff_ratio_abs<-abs(data.csv$real_ratio-data.csv$predict_ratio)
data.csv$diff_ratio<-data.csv$real_ratio-data.csv$predict_ratio
hist(data.csv$diff_ratio)
data.csv$updown_ok<-array(0,dim=c(length(data.csv$diff_ratio)))
for(i in 1:length(data.csv$diff_ratio)){
  if(data.csv[i,]$diff_ratio*data.csv[i,]$predict_ratio>0){
    data.csv[i,]$updown_ok<-1
  }
}

sum(data.csv$updown_ok)/length(data.csv$updown_ok)
min(data.csv$diff_ratio_abs)
max(data.csv$diff_ratio_abs)
