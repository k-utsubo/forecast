library(RMySQL)
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Users/utsubo/Documents/workspace/deeplearning/nk225")

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")


#### １．線形モデル
# nk225
check_aic<-function(fmDate,toDate){
  print(paste("fmDate=",fmDate,",toDate=",toDate,sep=""))
  query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.lm<-data.ret[1:length(data.ret$nk225)-1,]
  data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
  data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
  summary(data.res)
  data.prm<-step(data.res)
  return(data.prm)
}
fmDate<-c("2005/1/1","2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1")
toDate<-c("2006/1/1","2007/1/1","2008/1/1","2009/1/1","2010/1/1","2011/1/1","2012/1/1","2013/1/1","2014/1/1","2015/1/1")

file<-"51_aic.txt"
for(i in 1:length(fmDate)){
  for(j in i:length(toDate)){
    data.prm<-check_aic(fmDate[i],toDate[j])
    write.table("-----------",file,col.names=F,append=T)
    write.table(fmDate[i],file,col.names=F,append=T)
    write.table(toDate[j],file,col.names=F,append=T)
    write.table(data.prm$coefficients,file,col.names=T,append=T)
  }
}




##### 1-1検証
library(e1071)

calc_prm<-function(fmDate,toDate){
  print(paste("fmDate=",fmDate,",toDate=",toDate,sep=""))
  query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.lm<-data.ret[1:length(data.ret$nk225)-1,]
  data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
  data.res<-lm(nk225n ~ nk225 + dj + dax  + eurjpy + usdjpy,data.lm)
  data.sum<-summary(data.res)
  return(data.sum)
}
calc_predict<-function(data.sum,toDate){
  query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='",toDate,"' and i.date<=date_add('",toDate,"',interval 1 year)  order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])

  data.predict<-c()
  data.real<-c()
  data.diff<-c()
  data.updn<-c() # updownが当たったかどうか
  for(i in 1:(length(data.ret$nk225)-1)){
    nk.predict<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[i,]$nk225+data.sum$coefficients[3,1]*data.ret[i,]$dj+data.sum$coefficients[4,1]*data.ret[i,]$dax+data.sum$coefficients[5,1]*data.ret[i,]$eurjpy+data.sum$coefficients[6,1]*data.ret[i,]$usdjpy
    nk.real<-data.ret[i+1,]$nk225
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

file<-"51_res.txt"
unlink(file)
for(i in 1:length(fmDates)){
  for(j in i:length(toDates)){
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
  }
}

