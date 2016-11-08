library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),host="zcod4md",user="root",password="",dbname="live")

query<-paste("select i.cprice as nk225,u.price as usdjpy,e.price as eurjpy,d.cl as dj,x.cl as dax,b.price as lbond ,g.price as gold ,o.price as oil from indexHist i,otherHist u,otherHist e,idcStockDaily d ,idcStockDaily x ,otherHist b,otherHist g,otherHist o where i.date=u.date and i.date=e.date and i.date=d.date and i.date=x.date and i.date=b.date and i.date=g.date and i.date=o.date and i.indexCode='101' and u.otherCode='FEXCH' and e.otherCode='EURO' and d.indexCode='I_DJI' and x.indexCode='DAX' and b.otherCode='LBOND' and g.otherCode='GOLD' and o.otherCode='OIL' and i.date>='2001-01-01' and i.date<='2011-12-31' order by i.date asc")
data<-fetch(dbSendQuery(con,query),n=-1)
nk225<-diff(data$nk225)/data[1:length(data$nk225)-1,]$nk225
usdjpy<-diff(data$usdjpy)/data[1:length(data$usdjpy)-1,]$usdjpy
eurjpy<-diff(data$eurjpy)/data[1:length(data$eurjpy)-1,]$eurjpy
dj<-diff(data$dj)/data[1:length(data$dj)-1,]$dj
dax<-diff(data$dax)/data[1:length(data$dax)-1,]$dax
lbond<-diff(data$lbond)/data[1:length(data$lbond)-1,]$lbond
gold<-diff(data$gold)/data[1:length(data$gold)-1,]$gold
oil<-diff(data$oil)/data[1:length(data$oil)-1,]$oil

data.ret<-data.frame(nk225=nk225,usdjpy=usdjpy,eurjpy=eurjpy,dj=dj,dax=dax,lbond=lbond,gold=gold,oil=oil)
# nk225 vs yesterday dj 
cor(data.ret$nk225[-1],data.ret$dj[1:length(data.ret$dj)-1])
# nk225 vs dj
cor(data.ret$nk225,data.ret$dj)

# nk225 vs yesterday usdjpy 
cor(data.ret$nk225[-1],data.ret$usdjpy[1:length(data.ret$usdjpy)-1])
# nk225 vs yesterday eurjpy 
cor(data.ret$nk225[-1],data.ret$eurjpy[1:length(data.ret$eurjpy)-1])
# nk225 vs yesterday dax
cor(data.ret$nk225[-1],data.ret$dax[1:length(data.ret$dax)-1])
# nk225 vs yesterday lbond
cor(data.ret$nk225[-1],data.ret$lbond[1:length(data.ret$lbond)-1])
# nk225 vs yesterday gold
cor(data.ret$nk225[-1],data.ret$gold[1:length(data.ret$gold)-1])
# nk225 vs yesterday oil
cor(data.ret$nk225[-1],data.ret$oil[1:length(data.ret$oil)-1])

# nk225 vs yesterday nk225
cor(data.ret$nk225[-1],data.ret$nk225[1:length(data.ret$nk225)-1])


# plot nk225 vs yesterday dj 
plot(data.ret$nk225[-1],data.ret$dj[1:length(data.ret$dj)-1])
# nk225 vs yesterday dax
plot(data.ret$nk225[-1],data.ret$dax[1:length(data.ret$dax)-1])


# nk225 vs yesterday nk225
plot(data.ret$nk225[-1],data.ret$nk225[1:length(data.ret$nk225)-1])
