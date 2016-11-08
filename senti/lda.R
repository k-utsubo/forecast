Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")

#http://rstudio-pubs-static.s3.amazonaws.com/16714_5b89bc4687994ff3b43c6e715ddadda1.html
library(lda)
library(reshape2)
library(ggplot2)


# http://rstudio-pubs-static.s3.amazonaws.com/16714_5b89bc4687994ff3b43c6e715ddadda1.html
# ベクトル型で以下のように格納できるデータならOK。csvファイルなら結合していけばOK。
sentence <- c("I am the very model of a modern major general", "I have a major headache")
# lexicalize関数で、LDAで分析するためのデータを生成。LIST型として展開される。
# LISTの要素は2つの成分。LIST型の$documentsと文字列ベクトルの$vovabに。
test <- lexicalize(sentence, lower = TRUE)
# testの中身を見ると、$documentはセンテンスの出現位置と回数、$vocabがユニークな単語
test
# リストはこんな感じでアクセスできます。
test$documents[[1]][2, 4]

#######################################################################
# coraデータの読み込み（2410の科学記事のデータセット。LISTで2410成分ある）
data(cora.documents)
head(cora.documents, n = 2)

# 科学記事で使われているユニーク単語(2910個)のベクトル
data(cora.vocab)
head(cora.vocab)

# 科学記事で使われているタイトル(2410個)のベクトル
data(cora.titles)
head(cora.titles)

# 分析データの作成（トリッキーな参照をしているので注意）
# 1列目がcora.documentsの第一成分で使われる単語のリスト、2列目がその出現回数
data_cora <- as.data.frame(cbind(cora.vocab[cora.documents[[1]][1, ] + 1], cora.documents[[1]][2,]))
# coreの1番目の記事はこれらの単語とその出現回数で構成されていることが分かる。
head(data_cora)

### LDA
# 推定するトピック数の設定
k <- 10

# ldaパッケージはギブスサンプラーでやるようです。
# ギブスサンプラーの中でも3つくらいmethodがあるようです。
result <- lda.collapsed.gibbs.sampler(cora.documents, 
                                      k,
                                      cora.vocab,
                                      25,  # 繰り返し数
                                      0.1, # ディリクレ過程のハイパーパラメータα
                                      0.1, # ディリクレ過程のハイパーパラメータη
                                      compute.log.likelihood=TRUE)

# サマリを見ると、10成分のリストで構成されている。
# assignments：文書Dと同じ長さのリスト。値は単語が割り当てられたトピックNoを示す。
# topic：k × vの行列。値はそのトピックに出現する単語数を表す。
# topic_sums：それぞれのトピックに割り当てられた単語の合計数
# document_sums：k × Dの行列。割り振られたトピックにおける一文章内の単語数を示す。
summary(result)

# 各クラスターでの上位キーワードを抽出する
# 例は各トピックにおける上位3位の単語の行列。
top.words <- top.topic.words(result$topics, 3, by.score=TRUE)
top.words

# 最初の3記事だけトピック割合を抽出してみる
N <- 3
topic.proportions <- t(result$document_sums) / colSums(result$document_sums)
topic.proportions <- topic.proportions[1:N, ]
topic.proportions[is.na(topic.proportions)] <-  1 / k

# 上位3番までのトップワードを用いて列名をつけて、意味付けを行う。
colnames(topic.proportions) <- apply(top.words, 2, paste, collapse=" ")
par(mar=c(5, 14, 2, 2))
barplot(topic.proportions, beside=TRUE, horiz=TRUE, las=1, xlab="proportion")


###
# ggplotで可視化するために、meltを駆使してデータを作成（トリッキーなので注意）
topic.proportions.df <- melt(cbind(data.frame(topic.proportions), document=factor(1:N)), variable.name="topic", id.vars = "document")

# ggplotで可視化
#http://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html
ggplot(topic.proportions.df, aes(x=variable, y=value, fill=document)) + geom_bar(stat="identity") + facet_wrap(~ document, ncol=N) + coord_flip()

# 予測はこんな感じ
predictions <- predictive.distribution(result$document_sums[,1:2], result$topics, 0.1, 0.1)
top.topic.words(t(predictions), 5)

#########################################
# 景気ウオッチャーで試す

library(RMeCab)
library(RMySQL)
con<-dbConnect(dbDriver("MySQL"),dbname="watcher",host="zaaa16d.qr.com",user="root")
dbGetQuery(con,"set names utf8")
data.tmp<-dbSendQuery(con,"select * from now_description")
data.now<-fetch(data.tmp,n=-1)

dbDisconnect(con)
