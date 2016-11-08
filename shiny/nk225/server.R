library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語

get_date<-function(){
  con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zcod4md")
  query<-"select max(d.date) as dj,max(i.date) as nk225 from idcStockDaily d,indexHist i where i.date=d.date and i.indexCode='101' and d.indexCode='I_DJI'"
  data<-fetch(dbSendQuery(con,query),n=-1)
  res<-data$dj
  if (as.POSIXct(data$dj) > as.POSIXct(data$nk225)){
    res<-data$nk225
  }
  dbDisconnect(con)
  return(res)
}

calc_forecast<-function(date){
  con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zcod4md")
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>=date_add('",date,"',interval -1 year) and i.date<'",date,"' order by i.date asc",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
  data.ret<-data.ret[1:length(data.ret$nk225)-1,] # zurasu
  tmp<-log(data[-1,]$nk225o)-log(data[1:length(data$nk225)-1,]$nk225)
  data.ret$nk225n<-tmp[-1]
  data.lm<-data.ret

  data.res<-lm(nk225n ~  dj + dax ,data.lm)
  data.sum<-summary(data.res)
  # http://uncorrelated.hatenablog.com/entry/20130115/1358272065
#  a <- 0.05/2 # 両側検定
#  df <- data.sum$df[2] # 自由度
#  b <- coef(data.res)[3] # 3番目の係数
#  se <- coef(data.sum)[, 2][3] # 3番目の標準誤差
#  sprintf("%.3f(95%%信頼区間%.3f〜%.3f)", b, b-se*qt(a, df), b+se*qt(a, df))

  
  query<-paste("select i.cprice as nk225,i.oprice as nk225o,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date<='",date,"' order by i.date desc limit 3",sep="")
  data<-fetch(dbSendQuery(con,query),n=-1)
  data.ret<-log(data[1,])-log(data[2,])
  
 #http://statsbeginner.hatenablog.com/entry/2014/10/18/130504
  data.test<-data.frame(dj=data.ret[1,]$dj,dax=data.ret[1,]$dax)
  nk.predict<-predict(object=data.res,newdata=data.test,interval="prediction",  level=0.95)
  

  #nk.ratio<-data.sum$coefficients[1,1]+data.sum$coefficients[2,1]*data.ret[1,]$dj+data.sum$coefficients[3,1]*data.ret[1,]$dax
  nk.ratio<-nk.predict[1,1]
  nk.price<-data[1,]$nk225*(1+nk.predict[1,1])
  nk.priceupp<-data[1,]$nk225*(1+nk.predict[1,3])
  nk.pricelow<-data[1,]$nk225*(1+nk.predict[1,2])

  dbDisconnect(con)
  return(data.frame(ratio=nk.ratio,price=nk.price,priceupp=nk.priceupp,pricelow=nk.pricelow,prev=data[1,]$nk225))
}


shinyServer(function(input, output, session) {

  output$predictPrice <- renderText({
    date<-get_date()
    nk.df<-calc_forecast(date)
    updn<-"下がる"
    if (nk.df$ratio>=0){
      updn<-"上がる"
    }
    sprintf("昨日データ日付:%s<br>昨日日経平均:%s,<br>予測値:%s<br>95％信頼区間:%s  -  %s<br>日経平均は%s",date,nk.df$prev,nk.df$price,nk.df$pricelow,nk.df$priceupp,updn)
  })

  output$realPrice <- renderText({
    date<-get_date()
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zcod4md")
    res<-dbSendQuery(con,paste("select validDate ,oprice ,high,low ,price  from kmIndexTodayReal where indexCode='101' and validDate>'",date,"'",sep=""))
    data.df<-fetch(res,-1)
    dbDisconnect(con)
    if(length(data.df)>0){
    d<-data.df[1,]
    sprintf("日時:%s<br>始値:%s<br>高値:%s<br>安値:%s<br>現在値:%s",d$validDate,d$oprice,d$high,d$low,d$price)
    }
  })



})
