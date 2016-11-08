Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
library(RMySQL)

con<-dbConnect(dbDriver("MySQL"),dbname="fintech", user="root", password="", 
               host="zaaa16d.qr.com", port=3306)
res<-dbSendQuery(con,"select * from yahooStockNewsSentiment")
data.news<-fetch(res,-1)
length(data.news$date)
head(data.news)

par(mfrow=c(1,1)) 
# スコア、０を除く
hist(subset(data.news,score!=0)$score,main="sentiment score, w/o score=0")
summary(subset(data.news,score!=0)$score)

# 0は信頼度を出せない
hist(subset(data.news,score_std>0)$score_std,main="standard deviation of sentiment score , w/o score=0")
summary(subset(data.news,score_std>0)$score_std)

hist(subset(data.news,score!=0)$score_cnt)
summary(subset(data.news,score!=0)$score_cnt)





###
# スコアとリターンの関
data.score<-subset(data.news,score!=0)
plot(data.score$score,data.score$price_return,main="score v.s. return")
data.lm<-lm(price_return ~ score ,data=data.score)
summary(data.lm)

# リターンを将来５日まで,平均とるか
res<-dbSendQuery(con,"select * from yahooStockNewsPrice")
data.price<-fetch(res,-1)
data.ret1<-log(data.price$price1/data.price$priceb)-log(data.price$topix1/data.price$topixb)
data.ret2<-log(data.price$price2/data.price$priceb)-log(data.price$topix2/data.price$topixb)
data.ret3<-log(data.price$price3/data.price$priceb)-log(data.price$topix3/data.price$topixb)
data.ret4<-log(data.price$price4/data.price$priceb)-log(data.price$topix4/data.price$topixb)
data.ret5<-log(data.price$price5/data.price$priceb)-log(data.price$topix5/data.price$topixb)
data.ret<-data.frame(href=data.price$href,price_ret1=data.ret1,price_ret2=data.ret2,price_ret3=data.ret3,
                     price_ret4=data.ret4,price_ret5=data.ret5)
data.merge<-merge(data.news,data.ret,by="href")
data.merge<-subset(data.merge,score!=0)
plot(data.merge$score,data.merge$price_ret2,main="score v.s. 2 days after return")
plot(data.merge$score,data.merge$price_ret3,main="score v.s. 3 days after return")
plot(data.merge$score,data.merge$price_ret4,main="score v.s. 4 days after return")
plot(data.merge$score,data.merge$price_ret5,main="score v.s. 5 days after return")







#YahooNews信頼度の高いものだけ 0<score_std<0.2
#data.score<-subset(subset(subset(data.news, score!=0 ),score_std>0),score_std<0.1)
#plot(data.score$score,data.score$price_return,main="score v.s. return")
#data.lm<-lm(price_return ~ score ,data=data.score)
#summary(data.lm)




###### TDNET文書を検証
res<-dbSendQuery(con,"select * from tdnetSentiment")
data.tdnet<-fetch(res,-1)
length(data.tdnet$date)
head(data.tdnet)
par(mfrow=c(1,1)) 

# スコア、０を除く
hist(subset(data.tdnet,score!=0)$score,main="tdnet, sentiment score, w/o score=0")
summary(subset(data.tdnet,score!=0)$score)

# 0は信頼度を出せない
hist(subset(data.tdnet,score_std>0)$score_std,main="tdnet,standard deviation of sentiment score , w/o score=0")
summary(subset(data.tdnet,score_std>0)$score_std)

# スコアとリターンの関
data.score<-subset(data.tdnet,score!=0)
plot(data.score$score,data.score$price_return,main="score v.s. return")
data.lm<-lm(price_return ~ score ,data=data.score)
summary(data.lm)



dbDisconnect(con)
