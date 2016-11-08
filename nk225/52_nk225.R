library(RMySQL)
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Users/utsubo/Documents/workspace/deeplearning/nk225")

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")


#### １．線形モデル
# nk225
check_aic<-function(fmDate,toDate){
  print(paste("fmDate=",fmDate,",toDate=",toDate,sep=""))
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret<-data.ret[1:length(data.ret$nk225)-1,] # zurasu
  tmp<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.ret$nk225n<-tmp[-1]
  data.lm<-data.ret
  write.table(data.lm,"52_data.csv",sep=",",quote=F)

  data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
  summary(data.res)
  data.prm<-step(data.res)
  return(data.prm)
}
fmDate<-c("2005/1/1","2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1")
toDate<-c("2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1","2015/1/1")

file<-"52_aic.txt"
unlink(file)
for(i in 1:length(fmDate)){
  for(j in i:length(toDate)){
    data.prm<-check_aic(fmDate[i],toDate[j])
    write.table("-----------",file,col.names=F,append=T)
    write.table(fmDate[i],file,col.names=F,append=T)
    write.table(toDate[j],file,col.names=F,append=T)
    write.table(data.prm$coefficients,file,col.names=T,append=T)
  }
}

# １年
file<-"52_aic1.txt"
unlink(file)
for(i in 1:length(fmDate)){
  j<-i
    data.prm<-check_aic(fmDate[i],toDate[j])
    write.table("-----------",file,col.names=F,append=T)
    write.table(fmDate[i],file,col.names=F,append=T)
    write.table(toDate[j],file,col.names=F,append=T)
    write.table(data.prm$coefficients,file,col.names=T,append=T)
}
# ２年
file<-"52_aic2.txt"
unlink(file)
for(i in 1:length(fmDate)){
  j<-i+1
    data.prm<-check_aic(fmDate[i],toDate[j])
    write.table("-----------",file,col.names=F,append=T)
    write.table(fmDate[i],file,col.names=F,append=T)
    write.table(toDate[j],file,col.names=F,append=T)
    write.table(data.prm$coefficients,file,col.names=T,append=T)
}



##### 1-1検証
library(e1071)

calc_prm<-function(fmDate,toDate){
  print(paste("fmDate=",fmDate,",toDate=",toDate,sep=""))
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret$nk225n<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.lm<-data.ret
  
  data.res<-lm(nk225n ~   dj + dax ,data.lm)
  data.sum<-summary(data.res)
  return(data.sum)
}
calc_predict<-function(data.sum,toDate){
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",toDate,"' and i.date<=date_add('",toDate,"',interval 1 year)  order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)

  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret<-data.ret[1:length(data.ret$nk225)-1,] # zurasu
  tmp<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.ret$nk225n<-tmp[-1]
  
  
  data.predict<-c()
  data.real<-c()
  data.diff<-c()
  data.updn<-c() # updownが当たったかどうか
  for(i in 1:(length(data.ret$nk225)-1)){
    nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[i,]$dj+data.sum$coefficients[3,1]*data.ret[i,]$dax
    nk.real<-data.ret[i,]$nk225n
    data.predict<-append(data.predict,nk.predict)
    data.real<-append(data.real,nk.real)
    data.diff<-append(data.diff,nk.predict-nk.real)
    if(nk.real*nk.predict>=0){
      data.updn<-append(data.updn,1)
    }else{
      data.updn<-append(data.updn,0)
    }
  }
  return(data.frame(predict=data.predict,real=data.real,diff=data.diff,updn=data.updn))
}

fmDates<-c("2005/1/1","2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1")
toDates<-c("2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1","2015/1/1")

file<-"52_res1.txt"
unlink(file)
for(i in 1:length(fmDates)){
  #for(j in i:length(toDates)){
  j<-i  # １年計算
    data.sum<-calc_prm(fmDates[i],toDates[j])
    data.ret<-calc_predict(data.sum,toDates[j])
    write.table("-----------",file,col.names=F,append=T)
    write.table(fmDates[i],file,col.names=F,append=T)
    write.table(toDates[j],file,col.names=F,append=T)
    #write.table(data.ret,file,col.names=T,append=T)
    #hist(data.ret$diff)
    data.updn<-sum(data.ret$updn)/length(data.ret$updn)
    names(data.updn)<-c("updn")
    write.table(data.updn,file,col.names=T,append=T)
    data.tmp<-summary(data.ret$diff)
    data.conv<-as.vector(data.tmp)
    names(data.conv)<-names(data.tmp)
    write.table(data.conv,file,col.names=T,append=T)
    data.kurt<-kurtosis(data.ret$diff) # 尖度
    names(data.kurt)<-c("kurtosis")
    write.table(data.kurt,file,col.names=F,append=T)
  #}
}












### 検証２
#予想日からの直近１年の回帰から求める、
library(e1071)

date_list<-function(fmDate,toDate){
  query<-paste("select date_format(i.date,'%Y/%m/%d') as date from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  return(as.character(data$date))
}
calc_forecast<-function(date){
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>=date_add('",date,"',interval -1 year) and i.date<'",date,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret<-data.ret[1:length(data.ret$nk225)-1,] # zurasu
  tmp<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.ret$nk225n<-tmp[-1]
  data.lm<-data.ret
  
  data.res<-lm(nk225n ~  dj + dax ,data.lm)
  data.sum<-summary(data.res)


  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date<='",date,"' order by i.date desc limit 3",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[2,])-log(data[3,])
  tmp<-log(data[1,]$nk225o)-log(data[2,]$nk225)
  data.ret$nk225n<-tmp
  
  #http://statsbeginner.hatenablog.com/entry/2014/10/18/130504
  data.test<-data.frame(dj=data.ret[1,]$dj,dax=data.ret[1,]$dax)
  nk.tmp<-predict(object=data.res,newdata=data.test,interval="prediction",  level=0.95)
  
  
  #nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[1,]$dj+data.sum$coefficients[3,1]*data.ret[1,]$dax
  nk.predict<-nk.tmp[1,1]
  nk.price<-data[2,]$nk225*(1+nk.tmp[1,1])
  nk.priceupp<-data[2,]$nk225*(1+nk.tmp[1,3])
  nk.pricelow<-data[2,]$nk225*(1+nk.tmp[1,2])
  nk.real<-data.ret[1,]$nk225n
  
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

file<-"52_res2.txt"
unlink(file)
for(i in 1:length(date.list)){
  date<-date.list[i]
  tmp<-calc_forecast(date)
  tmp$date<-c(date)
  data.df<-rbind(data.df,tmp)
  write.table(tmp,file,col.names=F,append=T)
}
sum(data.df$updn)/length(data.df$updn)  # 正解率









### データを確認
check_aic("2005/1/1","2015/1/1")
data.nk<-read.table("52_data.csv",sep=",")
# 離散化　1 or -1
data.lm<-data.frame(nk225n=mapply(function(x) if(x>0)1 else -1,data.nk$nk225n))
data.lm$nk225<-mapply(function(x) if(x>0)1 else -1 ,data.nk$nk225)
data.lm$usdjpy<-mapply(function(x) if(x>0)1 else -1 ,data.nk$usdjpy)
data.lm$dj<-mapply(function(x) if(x>0)1 else -1 ,data.nk$dj)
data.lm$dax<-mapply(function(x) if(x>0)1 else -1 ,data.nk$dax)

# nk225で翌日初値騰落率予測の正解率
data.lm$nk225prob<-mapply(function(x,y) if(x==y)1 else 0,data.lm$nk225n,data.lm$nk225)
data.lm$djprob<-mapply(function(x,y) if(x==y)1 else 0,data.lm$nk225n,data.lm$dj)
data.lm$usdjpyprob<-mapply(function(x,y) if(x==y)1 else 0,data.lm$nk225n,data.lm$usdjpy)
data.lm$daxprob<-mapply(function(x,y) if(x==y)1 else 0,data.lm$nk225n,data.lm$dax)

# それぞれの指数が上がった下がった際の翌日の日経寄り付き
sum(data.lm$nk225prob)/length(data.lm$nk225prob) # nk225で翌日初値騰落率予測の正解率
sum(data.lm$djprob)/length(data.lm$djprob) # djで翌日初値騰落率予測の正解率
sum(data.lm$usdjpyprob)/length(data.lm$usdjpyprob) # usdjpyで翌日初値騰落率予測の正解率
sum(data.lm$daxprob)/length(data.lm$daxprob) # daxで翌日初値騰落率予測の正解率

plot(x=data.nk$dax,y=data.nk$nk225n,main="dax v.s. nk225 over night")
plot(x=data.nk$dj,y=data.nk$nk225n,main="dj v.s. nk225 over night")
plot(x=data.nk$nk225,y=data.nk$nk225n,main="nk225 v.s. nk225 over night")
plot(x=data.nk$usdjpy,y=data.nk$nk225n,main="usdjpy v.s. nk225 over night")
plot(x=data.nk$eurjpy,y=data.nk$nk225n,main="eurjpy v.s. nk225 over night")
plot(x=data.nk$gold,y=data.nk$nk225n,main="gold v.s. nk225 over night")
plot(x=data.nk$bond,y=data.nk$nk225n,main="bond v.s. nk225 over night")
plot(x=data.nk$oil,y=data.nk$nk225n,main="oil v.s. nk225 over night")








