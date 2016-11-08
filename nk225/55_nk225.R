# 51 と 52から翌日日経平均の始値と終値を予測。
library(RMeCab)
library(RMySQL)
library(e1071)
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Users/utsubo/Documents/workspace/deeplearning/nk225")

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")




### 始値予測
date_list<-function(fmDate,toDate){
  query<-paste("select date_format(i.date,'%Y/%m/%d') as date from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date  and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX'  and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  return(as.character(data$date))
}
calc_forecast_open<-function(date){
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date>=date_add('",date,"',interval -1 year) and i.date<'",date,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret<-data.ret[1:length(data.ret$nk225)-1,] # zurasu
  tmp<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.ret$nk225n<-tmp[-1]
  data.lm<-data.ret
  
  
  data.res<-lm(nk225n ~  dj + dax ,data.lm)
  data.sum<-summary(data.res)
  
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date<='",date,"' order by i.date desc limit 3",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[2,])-log(data[3,])
  data.seikai<-log(data[1,]$nk225o)-log(data[2,]$nk225)

  #http://statsbeginner.hatenablog.com/entry/2014/10/18/130504
  data.test<-data.frame(dj=data.ret[1,]$dj,dax=data.ret[1,]$dax)
  nk.tmp<-predict(object=data.res,newdata=data.test,interval="prediction",  level=0.95)
  
  
  #nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[1,]$dj+data.sum$coefficients[3,1]*data.ret[1,]$dax
  nk.predict<-nk.tmp[1,1] # 前日終値から当日始値の騰落率予測
  nk.price<-data[2,]$nk225*(1+nk.tmp[1,1])
  nk.priceupp<-data[2,]$nk225*(1+nk.tmp[1,3])
  nk.pricelow<-data[2,]$nk225*(1+nk.tmp[1,2])
  nk.real<-data.seikai  # 実際の前日終値から当日始値の騰落率
  
  data.predict<-c()
  data.price<-c()
  data.priceupp<-c()
  data.pricelow<-c()
  data.pricenext<-c() # seikai
  data.real<-c()
  data.diff<-c()
  data.updn<-c() # updownが当たったかどうか
  
  data.price<-append(data.price,nk.price)
  data.priceupp<-append(data.priceupp,nk.priceupp)
  data.pricelow<-append(data.pricelow,nk.pricelow)
  data.pricenext<-append(data.pricenext,data[1,]$nk225o) # seikai
  data.predict<-append(data.predict,nk.predict)
  data.real<-append(data.real,nk.real)
  data.diff<-append(data.diff,nk.predict-nk.real)
  if(nk.real*nk.predict>=0){
    data.updn<-append(data.updn,1)
  }else{
    data.updn<-append(data.updn,0)
  }
  return(data.frame(predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext))
}

data.predict<-c()
data.real<-c()
data.price<-c()
data.priceupp<-c()
data.pricelow<-c()
data.pricenext<-c() # seikai
data.diff<-c()
data.updn<-c() # updownが当たったかどうか
data.date<-c()
data.df=data.frame(data=data.date,predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext)

date.list<-date_list("2006/1/1","2016/10/12")

file<-"55_open.txt"
unlink(file)
for(i in 1:length(date.list)){
  date<-date.list[i]
  tmp<-calc_forecast_open(date)
  tmp$date<-c(date)
  data.df<-rbind(data.df,tmp)
  write.table(tmp,file,col.names=F,append=T)
}
sum(data.df$updn)/length(data.df$updn)  # 正解率





### 終値予測 その1
calc_forecast_close<-function(date){
  
  query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date  and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date>=date_add('",date,"',interval -1 year) and i.date<'",date,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.lm<-data.ret[1:length(data.ret$nk225)-1,]
  data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
  data.res<-lm(nk225n ~  dj + dax  ,data.lm)
  data.sum<-summary(data.res)
  
  query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax from indexHist i ,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date<='",date,"'  order by i.date desc limit 2",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[1:length(data$nk225)-1,])-log(data[-1,])
  
  
  #http://statsbeginner.hatenablog.com/entry/2014/10/18/130504
  data.test<-data.frame(dj=data.ret[1,]$dj,dax=data.ret[1,]$dax)
  nk.tmp<-predict(object=data.res,newdata=data.test,interval="prediction",  level=0.95)
  
  #nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[1,]$dj+data.sum$coefficients[3,1]*data.ret[1,]$dax
  nk.predict<-nk.tmp[1,1]
  nk.price<-data[2,]$nk225*(1+nk.tmp[1,1])
  nk.priceupp<-data[2,]$nk225*(1+nk.tmp[1,3])
  nk.pricelow<-data[2,]$nk225*(1+nk.tmp[1,2])
  nk.real<-data.ret[1,]$nk225  # seikai
  
  data.predict<-c()
  data.price<-c()
  data.priceupp<-c()
  data.pricelow<-c()
  data.pricenext<-c() # seikai
  data.real<-c()
  data.diff<-c()
  data.updn<-c() # updownが当たったかどうか
  
  data.price<-append(data.price,nk.price)
  data.priceupp<-append(data.priceupp,nk.priceupp)
  data.pricelow<-append(data.pricelow,nk.pricelow)
  data.pricenext<-append(data.pricenext,data[1,]$nk225) # seikai
  data.predict<-append(data.predict,nk.predict)
  data.real<-append(data.real,nk.real)
  data.diff<-append(data.diff,nk.predict-nk.real)
  if(nk.real*nk.predict>=0){
    data.updn<-append(data.updn,1)
  }else{
    data.updn<-append(data.updn,0)
  }
  return(data.frame(predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext))
}

data.predict<-c()
data.real<-c()
data.price<-c()
data.priceupp<-c()
data.pricelow<-c()
data.pricenext<-c() # seikai
data.diff<-c()
data.updn<-c() # updownが当たったかどうか
data.date<-c()
data.df=data.frame(data=data.date,predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext)

date.list<-date_list("2006/1/1","2016/10/12")

file<-"55_close.txt"
unlink(file)
for(i in 1:length(date.list)){
  date<-date.list[i]
  tmp<-calc_forecast_close(date)
  tmp$date<-c(date)
  data.df<-rbind(data.df,tmp)
  write.table(tmp,file,col.names=F,append=T)
}
sum(data.df$updn)/length(data.df$updn)  # 正解率



  
  


### 終値予測 その２、オーバーナイトリターンを入れてみた
calc_forecast_close2<-function(date){

  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date  and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date>=date_add('",date,"',interval -1 year) and i.date<'",date,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ov<-log(data[1:length(data$nk225)-1,]$nk225o)-log(data[-1,]$nk225) # over night return
  data.lm<-data.ret[1:length(data.ret$nk225)-1,]
  data.lm$nk225ov<-data.ov[1:length(data.ov)-1]
  data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
  data.res<-lm(nk225n ~  dj + dax + nk225ov ,data.lm)
  data.sum<-summary(data.res)

  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax from indexHist i,idcStockDaily d,idcStockDaily x where i.date=x.date and  i.date=d.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and i.date<='",date,"'  order by i.date desc limit 2",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[1:length(data$nk225)-1,])-log(data[-1,])
  data.ret$nk225ov<-log(data[1:length(data$nk225)-1,]$nk225o)-log(data[-1,]$nk225) # over night return
  

  #http://statsbeginner.hatenablog.com/entry/2014/10/18/130504
  data.test<-data.frame(dj=data.ret[1,]$dj,dax=data.ret[1,]$dax,nk225ov=data.ret[1,]$nk225ov)
  nk.tmp<-predict(object=data.res,newdata=data.test,interval="prediction",  level=0.95)
  
  
  #nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[1,]$dj+data.sum$coefficients[3,1]*data.ret[1,]$dax
  nk.predict<-nk.tmp[1,1]
  nk.price<-data[2,]$nk225*(1+nk.tmp[1,1])
  nk.priceupp<-data[2,]$nk225*(1+nk.tmp[1,3])
  nk.pricelow<-data[2,]$nk225*(1+nk.tmp[1,2])
  nk.real<-data.ret[1,]$nk225  # seikai
  
  data.predict<-c()
  data.price<-c()
  data.priceupp<-c()
  data.pricelow<-c()
  data.pricenext<-c() # seikai
  data.real<-c()
  data.diff<-c()
  data.updn<-c() # updownが当たったかどうか
  
  data.price<-append(data.price,nk.price)
  data.priceupp<-append(data.priceupp,nk.priceupp)
  data.pricelow<-append(data.pricelow,nk.pricelow)
  data.pricenext<-append(data.pricenext,data[1,]$nk225) # seikai
  data.predict<-append(data.predict,nk.predict)
  data.real<-append(data.real,nk.real)
  data.diff<-append(data.diff,nk.predict-nk.real)
  if(nk.real*nk.predict>=0){
    data.updn<-append(data.updn,1)
  }else{
    data.updn<-append(data.updn,0)
  }
  return(data.frame(predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext))
}

data.predict<-c()
data.real<-c()
data.price<-c()
data.priceupp<-c()
data.pricelow<-c()
data.pricenext<-c() # seikai
data.diff<-c()
data.updn<-c() # updownが当たったかどうか
data.date<-c()
data.df=data.frame(data=data.date,predict=data.predict,real=data.real,diff=data.diff,updn=data.updn,price=data.price,priceupp=data.priceupp,pricelow=data.pricelow,pricenext=data.pricenext)

date.list<-date_list("2006/1/1","2016/10/12")

file<-"55_close2.txt"
unlink(file)
for(i in 1:length(date.list)){
  date<-date.list[i]
  tmp<-calc_forecast_close2(date)
  tmp$date<-c(date)
  data.df<-rbind(data.df,tmp)
  write.table(tmp,file,col.names=F,append=T)
}
sum(data.df$updn)/length(data.df$updn)  # 正解率





### シミュレーション
#  始値予測との実際の始値のギャップから終値の予測
# 売買シュミレーションしてみる

data.open<-read.table("55_open.txt")
data.open<-data.open[,colnames(data.open)!="V1"]
names(data.open)<-c("yosoku","seikai","diff","updn","price","priceupp","pricelow","priceseikai","date")

# 正解時の誤差
hist(subset(data.open,updn==1)$diff)
hist(subset(data.open,updn==0)$diff) # ハズレ時のほうが分布が広くなる

data.close<-read.table("55_close2.txt")
data.close<-data.close[,colnames(data.close)!="V1"]
names(data.close)<-c("yosoku","seikai","diff","updn","price","priceupp","pricelow","priceseikai","date")


data.join<-merge(data.open,data.close,by="date")
data.ok<-subset(data.join,updn.x==1)
# 始値が当たったときの終値の正解率
sum(data.ok$updn.y)/length(data.ok$date)

data.ok.up<-subset(data.ok,diff.x>0) # predict open price is upper
data.ok.lo<-subset(data.ok,diff.x<=0) # predict open price is lower
#data.ok.up.up<-subset(data.ok.up,diff.y>0) # predict close price is upper
#data.ok.up.lo<-subset(data.ok.up,diff.y<=0) # predict close price is lower
#data.ok.lo.up<-subset(data.ok.lo,diff.y>0) # predict close price is upper
#data.ok.lo.lo<-subset(data.ok.lo,diff.y<=0) # predict close price is lower

# 陰線、陽線
data.ok.up.in<-subset(data.ok.up,priceseikai.y-priceseikai.x<0) # insen   sell
data.ok.up.yo<-subset(data.ok.up,priceseikai.y-priceseikai.x>=0) # yosen  sell
data.ok.lo.in<-subset(data.ok.lo,priceseikai.y-priceseikai.x<0) # insen    buy
data.ok.lo.yo<-subset(data.ok.lo,priceseikai.y-priceseikai.x>=0) # yosen   buy

# 単純に足してみる
sum((data.ok.up$priceseikai.x-data.ok.up$priceseikai.y)/data.ok.up$priceseikai.x)+sum((data.ok.lo$priceseikai.y-data.ok.lo$priceseikai.x)/data.ok.lo$priceseikai.x)

# 可視化
data.ok.up$simu<-(data.ok.up$priceseikai.x-data.ok.up$priceseikai.y)/data.ok.up$priceseikai.x
data.ok.lo$simu<-(data.ok.lo$priceseikai.y-data.ok.lo$priceseikai.x)/data.ok.lo$priceseikai.x
data.ok.simu<-rbind(data.ok.up,data.ok.lo)
data.ok.simu<-data.ok.simu[order(data.ok.simu$date),]
data.ok.simu$simu.cumsum<-cumsum(data.ok.simu$simu)

data.ok.simu$date<-as.POSIXct(data.ok.simu$date)
data.join$date<-as.POSIXct(data.join$date)

data.plot<-data.ok.simu[seq(0,length(data.ok.simu$date),1),]
data.nk<-data.join[seq(0,length(data.join$date),1),]
par(new=F)
plot(data.plot$date,data.plot$simu.cumsum+1,type="l",col="black",ylim=c(0,4),xlim=c(as.POSIXct("2006-01-05"),as.POSIXct("2016-10-12")),xlab="",ylab="")
par(new=T)
plot(data.nk$date,data.nk$priceseikai.y/data.nk[1,]$priceseikai.y,col="red",type="l",ylim=c(0,4),xlim=c(as.POSIXct("2006-01-05"),as.POSIXct("2016-10-12")),xlab="date",ylab="ratio")
legend("topleft",legend=c("simu","nk225"),col=c("black","red"),lty=c(1,1))








### シミュレーション　ETFを使う
#  始値予測との実際の始値のギャップから終値の予測
# 売買シュミレーションしてみる

data.open<-read.table("55_open.txt")
data.open<-data.open[,colnames(data.open)!="V1"]
names(data.open)<-c("yosoku","seikai","diff","updn","price","priceupp","pricelow","priceseikai","date")

## ETC 1321
data.etf<-fetch(dbSendQuery(con,"select date_format(date,'%Y/%m/%d') as date ,oprice,high,low,cprice  from ST_priceHistAdj where stockCode='1321' order by date"),n=-1)
data.join<-merge(data.open,data.etf,by="date")



data.ok<-subset(data.join,updn==1)

data.ok.up<-subset(data.ok,diff>0) # predict open price is upper
data.ok.lo<-subset(data.ok,diff<=0) # predict open price is lower


# 陰線、陽線
# 始値の予測が当たったとき、予測値が高いときはSELL,予測値が低いときはBUYの戦略  
data.ok.up.in<-subset(data.ok.up,cprice-oprice<0) # insen   sell
data.ok.up.yo<-subset(data.ok.up,cprice-oprice>=0) # yosen  sell
data.ok.lo.in<-subset(data.ok.lo,cprice-oprice<0) # insen    buy
data.ok.lo.yo<-subset(data.ok.lo,cprice-oprice>=0) # yosen   buy
length(data.ok.up.in$date)
length(data.ok.up.yo$date)
length(data.ok.lo.in$date)
length(data.ok.lo.yo$date)

# 単純に足してみる
sum((data.ok.up$oprice-data.ok.up$cprice)/data.ok.up$oprice)+sum((data.ok.lo$cprice-data.ok.lo$oprice)/data.ok.lo$oprice)

# 可視化
data.ok.up$simu<-(data.ok.up$oprice-data.ok.up$cprice)/data.ok.up$oprice
data.ok.lo$simu<-(data.ok.lo$cprice-data.ok.lo$oprice)/data.ok.lo$oprice
data.ok.simu<-rbind(data.ok.up,data.ok.lo)
data.ok.simu<-data.ok.simu[order(data.ok.simu$date),]
data.ok.simu$simu.cumsum<-cumsum(data.ok.simu$simu)

data.ok.simu$date<-as.POSIXct(data.ok.simu$date)
data.join$date<-as.POSIXct(data.join$date)

data.plot<-data.ok.simu[seq(0,length(data.ok.simu$date),1),]
data.nk<-data.join[seq(0,length(data.join$date),1),]
par(new=F)
plot(data.plot$date,data.plot$simu.cumsum+1,type="l",col="black",ylim=c(0,4),xlim=c(as.POSIXct("2006-01-05"),as.POSIXct("2016-10-12")),xlab="",ylab="")
par(new=T)
plot(data.nk$date,data.nk$cprice/data.nk[1,]$cprice,col="red",type="l",ylim=c(0,4),xlim=c(as.POSIXct("2006-01-05"),as.POSIXct("2016-10-12")),xlab="date",ylab="ratio")
legend("topleft",legend=c("simu","1321"),col=c("black","red"),lty=c(1,1))
