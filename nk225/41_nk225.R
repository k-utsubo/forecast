# http://d.hatena.ne.jp/graySpace/20140430/1398864610
# ref. stock price forecast using baysian network
# ward method

setwd("~/Documents/workspace/deeplearning/nk225")
library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")
date.fm<-"2005-01-01"
date.to<-"2011-12-31"


## nk
data.nk<-fetch(dbSendQuery(con,paste("select * from indexHist where indexCode='101' and date>='",date.fm,"' and date<='",date.to,"' order by date",sep="")),n=-1)

data.nk.ret<-log(data.nk[-1,]$cprice/data.nk[1:length(data.nk$cprice)-1,]$cprice)
data.nk.ward<-hclust(dist(data.nk.ret),"ward.D2")
data.nk.cut<-cutree(data.nk.ward,6)

data.nk.clust<-data.frame(date=data.nk[-1,]$date,ret=data.nk.ret,ward=data.nk.cut)
data.nk.max<-c()
data.nk.min<-c()
for(i in 1:6){
  data.nk.tmp<-subset(data.nk.clust,ward==i)
  data.nk.sum<-summary(data.nk.tmp$ret)
  data.nk.min<-append(data.nk.min,data.nk.sum[1])
  data.nk.max<-append(data.nk.max,data.nk.sum[6])
}
data.nk.max<-sort(data.nk.max)
data.nk.min<-sort(data.nk.min)
names(data.nk.max)<-c()
names(data.nk.min)<-c()
write.table(data.nk.max, "41_nk225_nk.dat",quote=F, col.names=F,  row.names=F, append=F)




## dax
data.dax<-fetch(dbSendQuery(con,paste("select date, cl as cprice from idcStockDaily where indexCode='DAX' and date>='",date.fm,"' and date<='",date.to,"' order by date",sep="")),n=-1)

data.dax.ret<-log(data.dax[-1,]$cprice/data.dax[1:length(data.dax$cprice)-1,]$cprice)
data.dax.ward<-hclust(dist(data.dax.ret),"ward.D2")
data.dax.cut<-cutree(data.dax.ward,6)

data.dax.clust<-data.frame(date=data.dax[-1,]$date,ret=data.dax.ret,ward=data.dax.cut)
data.dax.max<-c()
data.dax.min<-c()
for(i in 1:6){
  data.dax.tmp<-subset(data.dax.clust,ward==i)
  data.dax.sum<-summary(data.dax.tmp$ret)
  data.dax.min<-append(data.dax.min,data.dax.sum[1])
  data.dax.max<-append(data.dax.max,data.dax.sum[6])
}
data.dax.min<-sort(data.dax.min)
data.dax.max<-sort(data.dax.max)
names(data.dax.min)<-c()
names(data.dax.max)<-c()
write.table(data.dax.max, "41_nk225_dax.dat",quote=F, col.names=F,  row.names=F, append=F)




## dj
data.dj<-fetch(dbSendQuery(con,paste("select date, cl as cprice from idcStockDaily where indexCode='I_DJI' and date>='",date.fm,"' and date<='",date.to,"' order by date",sep="")),n=-1)

data.dj.ret<-log(data.dj[-1,]$cprice/data.dj[1:length(data.dj$cprice)-1,]$cprice)
data.dj.ward<-hclust(dist(data.dj.ret),"ward.D2")
data.dj.cut<-cutree(data.dj.ward,6)

data.dj.clust<-data.frame(date=data.dj[-1,]$date,ret=data.dj.ret,ward=data.dj.cut)
data.dj.max<-c()
data.dj.min<-c()
for(i in 1:6){
  data.dj.tmp<-subset(data.dj.clust,ward==i)
  data.dj.sum<-summary(data.dj.tmp$ret)
  data.dj.min<-append(data.dj.min,data.dj.sum[1])
  data.dj.max<-append(data.dj.max,data.dj.sum[6])
}
data.dj.max<-sort(data.dj.max)
data.dj.min<-sort(data.dj.min)
names(data.dj.max)<-c()
names(data.dj.min)<-c()
write.table(data.dj.max, "41_nk225_dj.dat",quote=F, col.names=F, row.names=F, append=F)


