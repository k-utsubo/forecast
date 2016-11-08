library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")
query<-paste("select i.cprice as nk225,d.cl as dj,x.cl as dax,u.price as usdjpy,e.price as eurjpy,o.price as oil ,b.price as bond,g.price as gold from indexHistMonthly i,idcStockMonthly d,idcStockMonthly x,otherHistMonthly u,otherHistMonthly e,otherHistMonthly o,otherHistMonthly b,otherHistMonthly g where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=u.date and i.date=e.date and i.date=b.date and i.date=g.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and u.otherCode='FEXCH' and e.otherCode='EURO' and o.otherCode='OIL' and b.otherCode='LBOND' and g.otherCode='GOLD' and i.date<='2011-12-31' order by i.date asc",sep="")
data<-fetch(dbSendQuery(con,query),n=-1)
data.ret<-log(data[-1,])-log(data[1:length(data$nk225)-1,])
data.lm<-data.ret[1:length(data.ret$nk225)-1,]
data.lm$nk225n<-data.ret[-1,]$nk225 # tomorrow nk225
data.res<-lm(nk225n ~ nk225 + dj + dax + usdjpy + eurjpy + oil + bond + gold,data.lm)
summary(data.res)
data.prm<-step(data.res)
