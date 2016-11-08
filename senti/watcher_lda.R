#########################################
# 景気ウオッチャーで試す
library(lda)
library(reshape2)
library(ggplot2)

library(RMeCab)
library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="watcher",host="zaaa16d.qr.com",user="root")
dbGetQuery(con,"set names utf8")
data.tmp<-dbSendQuery(con,"select * from now_description")
data.now<-fetch(data.tmp,n=-1)




dbDisconnect(con)
