library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")
query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='2001-01-01' and i.date<='2011-12-31' order by i.date asc",sep="")
data<-fetch(dbSendQuery(con,query),n=-1)
data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)

par(new=F)
## 個別
plot(x=data.lm$nk225n,y=data.lm$dj)
plot(x=data.lm$nk225n,y=data.lm$dax)
plot(x=data.lm$nk225n,y=data.lm$usdjpy)
plot(x=data.lm$nk225n,y=data.lm$eurjpy)
plot(x=data.lm$nk225n,y=data.lm$gold)
#### 誤差確認
# model
data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + gold,data.lm)
data.sum<-summary(data.res)
### モデルと予測値の相関係数
#data.cor<-sqrt(data.sum$adj.r.squared)







## hist
hist(data.lm$nk225n)
hist(data.lm$usdjpy)
hist(data.lm$gold)
hist(data.lm$dj)

## 回帰からの予測
query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date>='2012-01-01' and i.date<='2015-12-31' order by i.date asc",sep="")
pred<-fetch(dbSendQuery(con,query),n=-1)
#  -0.0003096   -0.2621430    0.5394757    0.1586218    0.0871300    0.1448687    0.0668855  
pred.ret<-log(pred[-1,])-log(pred[1:length(pred$nk225)-1,])
pred.lm<-pred.ret[1:length(pred.ret$nk225)-1,]
pred.lm$nk225n<-pred.ret[-1,]$nk225 # tomorrow nk225
nk225.actual<-100
nk225.predict<-100

data.calc<-data.frame(predict_price=c(),actual_price=c(),predict_ratio=c(),actual_ratio=c())
for(i in 1:length(pred.lm$nk225)){
  p<-data.prm$coefficients
  d<-pred.lm[i,]
  n<-p[1]+d$nk225*p[2]+d$dj*p[3]+d$dax*p[4]+d$usdjpy*p[5]+d$eurjpy*p[6]+d$gold*p[7]
  nk225.actual<-nk225.actual*(1+d$nk225n)
  nk225.predict<-nk225.predict*(1+n)
  
  print(paste(i,",",nk225.predict,",",nk225.actual,",",n,",",d$nk225n,sep=""))
  data.calc<-rbind(data.calc,data.frame(predict_price=c(nk225.predict),actual_price=c(nk225.actual),predict_ratio=c(n),actual_ratio=c(d$nk225n)))
}
cor(data.calc$predict_ratio,data.calc$actual_ratio)



### summary
nk225.rnn<-read.csv("31_nk225.csv")
nk225.lm<-read.csv("31_nk225_lm.csv")

mean(abs(nk225.rnn$predict_ratio))
mean(abs(nk225.rnn$real_ratio))

mean(abs(nk225.lm$predict_ratio))
mean(abs(nk225.lm$real_ratio))


### cor予測と実測の
cor(nk225.rnn$predict_ratio,nk225.rnn$real_ratio)
cor(nk225.lm$predict_ratio,nk225.lm$real_ratio)
plot(nk225.rnn$predict_ratio,nk225.rnn$real_ratio)
plot(nk225.lm$predict_ratio,nk225.lm$real_ratio)


