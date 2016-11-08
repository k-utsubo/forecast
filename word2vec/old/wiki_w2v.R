# http://yamano357.hatenadiary.com/entry/2015/11/04/000332
# plaza.rakuten.co.jp/mogumogu/diary/?ctgy=3




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
  train_file = "../../data/wikipedia/wiki_n_sjis.txt", output_file = "../../data/model_wiki_n.txt",
  vectors = 200, window = 10,
  threads =15 
)
#word2vec_model <- read.vectors("model_wiki",binary=TRUE)

#nearest_to(word2vec_model,word2vec_model[["地震"]])
