Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(RSQLite)

setwd("/Volumes/ubuntu/sentiment/dict")
con<-dbConnect(dbDriver("SQLite"),"dict.db")


# 足切りライン
res<-dbSendQuery(con,"select count(*) from dict")
data.dict<-fetch(res,-1)
data.dict

par(mfrow=c(2,2)) 

res<-dbSendQuery(con,"select * from dict where cnt>1")
data.dict<-fetch(res,-1)
length(data.dict$cnt)
hist(log10(data.dict$cnt),main="cnt>1")
hist(data.dict$score,main="cnt>1")
summary(data.dict$cnt)

# 3rd Qu.で切る
res<-dbSendQuery(con,"select * from dict where cnt>5")
data.dict<-fetch(res,-1)
length(data.dict$cnt)
hist(log10(data.dict$cnt),main="cnt>5")
hist(data.dict$score,main="cnt>5")
summary(data.dict$cnt)


dbDisconnect(con)


#### dict2
con<-dbConnect(dbDriver("SQLite"),"dict2.db")

# 足切りライン
res<-dbSendQuery(con,"select count(*) from dict")
data.dict<-fetch(res,-1)
data.dict

par(mfrow=c(2,2)) 

res<-dbSendQuery(con,"select * from dict where cnt>1")
data.dict<-fetch(res,-1)
length(data.dict$cnt)
hist(log10(data.dict$cnt),main="cnt>1")
hist(data.dict$score,main="cnt>1")
summary(data.dict$cnt)

# 3rd Qu.で切る
res<-dbSendQuery(con,"select * from dict where cnt>5")
data.dict<-fetch(res,-1)
length(data.dict$cnt)
hist(log10(data.dict$cnt),main="cnt>5")
hist(data.dict$score,main="cnt>5")
summary(data.dict$cnt)

dbDisconnect(con)
