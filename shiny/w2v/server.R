library(shiny)
library(wordVectors)
library(magrittr)
library(tsne)
library(RMySQL)
library(digest)
# 日本語

# word2vec,calculated by r


# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  word2vec_model <- read.vectors("model_all.txt",binary=TRUE)
  output$wordView <- renderDataTable({
    #query <- parseQueryString(session$clientData$url_search)
    word<-input$word
    data.table<-data.frame(word=c(""),score=c(""))

    words<-strsplit(word," ")[[1]]
    # http://www.okadajp.org/RWiki/?R%20%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE
    words.ng<-subset(words,grepl("^-",words))
    words.ng<-gsub("^-","",words.ng)
    words.ok<-subset(words,grepl("^[^-]",words))

    # http://datasciesotist.hatenablog.jp/entry/2016/03/20/224222
    #if(word!=NULL && word!=""){
      tkd<-word2vec_model[[words.ok]] %>% reject(word2vec_model[[words.ng]])
      #res<-nearest_to(word2vec_model,word2vec_model[[word]])
      res<- word2vec_model %>% nearest_to(tkd)
      data.table<-data.frame(word=names(res),score=res)
    #}
    return(data.table)
      

  },escape=F,options = list(pageLength = 10))


})
