# パラメタの相関、前日から当日をどう予測するか

library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")

# nk225
query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHist i,idcStockDaily d,idcStockDaily x,otherHist u,otherHist e,otherHist o,otherHist b,otherHist g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date<='2011-12-31' order by i.date asc",sep="")
data<-fetch(dbSendQuery(con,query),n=-1)
data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)

# dax
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk
data.lm$daxn<-data.ret[-1,]$dax # tomorrow dax
data.res<-lm(daxn ~ nk225 + nk225n + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)

# dj
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk
data.lm$daxn<-data.ret[-1,]$dax # tomorrow dax
data.lm$djn<-data.ret[-1,]$dj # tomorrow dj
data.res<-lm(djn ~ nk225 + nk225n + dj + dax + daxn + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)

# usdjpy
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$usdjpyn<-data.ret[-1,]$usdjpy # tomorrow usdjpy
data.res<-lm(usdjpyn ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)


# eudjpy
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$eurjpyn<-data.ret[-1,]$eurjpy # tomorrow usdjpy
data.res<-lm(eurjpyn ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)


# gold
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$goldn<-data.ret[-1,]$gold # tomorrow gold
data.res<-lm(goldn ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)



###### 
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow 
data.res<-lm(nk225n ~ nk225 + dj + dax,data.lm)
summary(data.res)
data.prm<-step(data.res)


data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$djn<-data.ret[-1,]$dj # tomorrow 
data.lm$daxn<-data.ret[-1,]$dax # tomorrow 
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow 
data.res<-lm(djn ~ nk225n + dj + daxn,data.lm)
summary(data.res)
data.prm<-step(data.res)


data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$djn<-data.ret[-1,]$dj # tomorrow 
data.lm$daxn<-data.ret[-1,]$dax # tomorrow 
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow 
data.res<-lm(daxn ~ nk225n + dj + dax,data.lm)
summary(data.res)
data.prm<-step(data.res)


