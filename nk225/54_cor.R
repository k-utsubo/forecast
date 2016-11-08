library(RMySQL)
library(tseries)
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Users/utsubo/Documents/workspace/deeplearning/nk225")

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zaaa16d",user="root",password="")



# 日付一覧取得
date.list<-fetch(dbSendQuery(con,"select distinct(date_format(n.date,'%Y-%m-%d')) as date from real.kmPriceHist5min0Long n,live.idcFx5min i where n.date=i.date and i.pair='USDJPY' and n.market='0002' and n.stockCode='OSE54'"),n=-1)



# まずはデータ時系列の評価
data.all<-data.frame(oprice=c(),bid_op=c())
for(date in date.list$date){
  res<-dbSendQuery(con,paste("select n.oprice,i.bid_op from real.kmPriceHist5min0Long n,live.idcFx5min i where n.date=i.date and i.pair='USDJPY' and n.market='0002' and n.stockCode='OSE54' and n.date>='",date," 00:00:00' and n.date<='",date," 23:59:59'",sep=""))
  data<-fetch(res,n=-1)
  data.all<-rbind(data.all,data)
}
adf.test(data.all$oprice)
adf.test(data.all$bid_op)



# ５分毎のリターンを日経平均とUSDJPYで求めて相関を見る
data.retall<-data.frame(oprice=c(),bid_op=c())
for(date in date.list$date){
  res<-dbSendQuery(con,paste("select n.oprice,i.bid_op from real.kmPriceHist5min0Long n,live.idcFx5min i where n.date=i.date and i.pair='USDJPY' and n.market='0002' and n.stockCode='OSE54' and n.date>='",date," 00:00:00' and n.date<='",date," 23:59:59'",sep=""))
  data<-fetch(res,n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$oprice)-1,])
  data.retall<-rbind(data.retall,data.ret)
}  
adf.test(data.retall$oprice)
adf.test(data.retall$bid_op)
data.res<-lm(oprice ~ bid_op,data.retall)
summary(data.res)
plot(data.retall$bid_op,data.retall$oprice,main="USDJPY vs NK225 log return")




# 為替を先行とする
data.retall<-data.frame(oprice=c(),bid_op=c())
for(date in date.list$date){
  res<-dbSendQuery(con,paste("select n.oprice,i.bid_op from real.kmPriceHist5min0Long n,live.idcFx5min i where n.date=date_add(i.date,interval 5 minute) and i.pair='USDJPY' and n.market='0002' and n.stockCode='OSE54' and n.date>='",date," 00:00:00' and n.date<='",date," 23:59:59'",sep=""))
  data<-fetch(res,n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$oprice)-1,])
  data.retall<-rbind(data.retall,data.ret)
}  
data.res<-lm(oprice ~ bid_op,data.retall)
summary(data.res)
plot(data.retall$bid_op,data.retall$oprice,main="USDJPY vs NK225 log return")


# 日経平均を先行とする
data.retall<-data.frame(oprice=c(),bid_op=c())
for(date in date.list$date){
  res<-dbSendQuery(con,paste("select n.oprice,i.bid_op from real.kmPriceHist5min0Long n,live.idcFx5min i where i.date=date_add(n.date,interval 5 minute) and i.pair='USDJPY' and n.market='0002' and n.stockCode='OSE54' and n.date>='",date," 00:00:00' and n.date<='",date," 23:59:59'",sep=""))
  data<-fetch(res,n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$oprice)-1,])
  data.retall<-rbind(data.retall,data.ret)
}  
data.res<-lm(oprice ~ bid_op,data.retall)
summary(data.res)
plot(data.retall$bid_op,data.retall$oprice,main="USDJPY vs NK225 log return")