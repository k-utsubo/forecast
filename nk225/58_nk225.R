# ベイズ
# DJが上がったときに日経が上がる
#  なんかだめ
library(RMySQL)
Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
setwd("/Users/utsubo/Documents/workspace/deeplearning/nk225")

con<-dbConnect(dbDriver("MySQL"),dbname="live",host="zcod4md",user="root",password="")

fmDate<-"2006/1/1"
toDate<-"2016/10/12"
query<-paste("select date_format(i.date,'%Y-%m-%d') as date,oprice as nk225o,cprice as nk225c,cl as dj from indexHist i,idcStockDaily d where  i.date=d.date  and i.indexCode='101' and d.indexCode='I_DJI'  and i.date>='",fmDate,"' and i.date<='",toDate,"' order by i.date asc",sep="")
data<-fetch(dbSendQuery(con,query),n=-1)


data$date<-as.POSIXct(data$date)
data.diff<-data.frame(date=data$date[-1],nk225=log(data[-1,]$nk225o)-log(data[-length(data$nk225o),]$nk225c),dj=log(data[-1,]$dj)-log(data[-length(data$dj),]$dj))

#nkが上がる確率
p.nk<-length(subset(data.diff,nk225>0)$nk225)/length(data.diff$nk225)
#djが上がる確率
p.dj<-length(subset(data.diff,dj>0)$dj)/length(data.diff$dj)
#nkが上がったときにdjの上がる確率
data.nk<-subset(data.diff,nk225>0)
p.nk.dj<-length(subset(data.nk,dj>0)$dj)/length(data.nk$dj)

## djが上がったときにnkが上がる確率
p.dj.nk<-p.nk*p.nk.dj/p.dj
