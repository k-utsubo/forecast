# http://yamano357.hatenadiary.com/entry/2015/11/04/000332

Sys.setenv("http_proxy"="http://zaan15p.qr.com:8080")
Sys.setenv("https_proxy"="http://zaan15p.qr.com:8080")

#setwd("/Volumes/admin/keiki_watcher/word2vec")
library(devtools)
#devtools::install_github("bmschmidt/wordVectors")



library(wordVectors)
library(magrittr)
library(tsne)
# install.packages("tsne")
# install.packages("magrittr")
# install.packages("stringi")
library(magrittr)
# http://datasciesotist.hatenablog.jp/entry/2016/03/20/224222

wordVectors::train_word2vec(
  train_file = "../../data/data/news/w2vdoc.txt", output_file = "model.txt",
  vectors = 200, window = 10,
  threads = 3
)
word2vec_model <- read.vectors("model.txt",binary=TRUE)

#nearest_to(word2vec_model,word2vec_model[["地震"]])
