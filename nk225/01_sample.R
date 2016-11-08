setwd("~/Documents/workspace/deeplearning/nk225")
seiseki<-read.table("01_sample.csv",row.names=1,header=T,sep=",")
seiseki.d<-dist(seiseki)
seiseki.d

plot(hclust(dist(seiseki),"ward.D2"),hang=-1)



## stock price forecast using baysian network
library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")
data.nk225<-fetch(dbSendQuery(con,paste("select * from indexHist where indexCode='101' and date>='1985-02-22' and date<='2008-12-30'")),n=-1)
data.nk225.ret<-log(data.nk225[-1,]$cprice/data.nk225[1:length(data.nk225$cprice)-1,]$cprice)
data.nk225.ward<-hclust(dist(data.nk225.ret),"ward.D2")
data.nk225.cut<-cutree(data.nk225.ward,6)

data.nk225.clust<-data.frame(date=data.nk225[-1,]$date,ret=data.nk225.ret,ward=data.nk225.cut)
data.nk225.1<-subset(data.nk225.clust,ward==1)
data.nk225.2<-subset(data.nk225.clust,ward==2)
data.nk225.3<-subset(data.nk225.clust,ward==3)
data.nk225.4<-subset(data.nk225.clust,ward==4)
data.nk225.5<-subset(data.nk225.clust,ward==5)
data.nk225.6<-subset(data.nk225.clust,ward==6)
summary(data.nk225.1$ret)
summary(data.nk225.2$ret)
summary(data.nk225.3$ret)
summary(data.nk225.4$ret)
summary(data.nk225.5$ret)
summary(data.nk225.6$ret)


