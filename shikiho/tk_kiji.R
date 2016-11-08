Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(RMySQL)

con<-dbConnect(dbDriver("MySQL"),host="zaaa16d.qr.com",user="root",password="",dbname="fintech")

tmp<-dbSendQuery(con,"select * from tk_kiji_tfidf")
data.tfidf<-fetch(tmp,n=-1)
hist(log10(data.tfidf$tfidf))
summary(data.tfidf$tfidf)

tmp<-dbSendQuery(con,"select * from tk_kiji_bow")
data.bow<-fetch(tmp,n=-1)
hist(log10(data.bow$count))
summary(data.bow$count)

tmp<-dbSendQuery(con,"select count(distinct(doc)) from tk_kiji_bow")
data.docs<-fetch(tmp,n=-1)

tmp<-dbSendQuery(con,"select * from tk_kiji_idf")
data.idf<-fetch(tmp,n=-1)
hist(log10(data.idf$idf))
summary(data.idf$idf)



