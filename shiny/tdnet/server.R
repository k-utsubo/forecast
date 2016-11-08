library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語

replacekw<-function(b,kw){
  for(i in 1:length(kw$id)){
    k<-kw[i,]
    if(k$score==0){next}
   if(nchar(k$word1)>0 && !grepl(k$word1,b)){next}
    if(nchar(k$word2)>0 && !grepl(k$word2,b)){next}
    if(nchar(k$word3)>0 && !grepl(k$word3,b)){next}
    if(nchar(k$word4)>0 && !grepl(k$word4,b)){next}
    if(nchar(k$word5)>0 && !grepl(k$word5,b)){next}
    if(nchar(k$word6)>0 && !grepl(k$word6,b)){next}
    if(nchar(k$word7)>0 && !grepl(k$word7,b)){next}
    if(nchar(k$word8)>0 && !grepl(k$word8,b)){next}
    if(nchar(k$word9)>0 && !grepl(k$word9,b)){next}

    color<-"green"
    if (k$score>0){color<-"red"}
    # kwがbに全て含まれている
    if(nchar(k$word1)>0){b<-gsub(k$word1,paste("<font color='",color,"'>",k$word1,"</font>",sep=""),b)}
    if(nchar(k$word2)>0){b<-gsub(k$word2,paste("<font color='",color,"'>",k$word2,"</font>",sep=""),b)}
    if(nchar(k$word3)>0){b<-gsub(k$word3,paste("<font color='",color,"'>",k$word3,"</font>",sep=""),b)}
    if(nchar(k$word4)>0){b<-gsub(k$word4,paste("<font color='",color,"'>",k$word4,"</font>",sep=""),b)}
    if(nchar(k$word5)>0){b<-gsub(k$word5,paste("<font color='",color,"'>",k$word5,"</font>",sep=""),b)}
    if(nchar(k$word6)>0){b<-gsub(k$word6,paste("<font color='",color,"'>",k$word6,"</font>",sep=""),b)}
    if(nchar(k$word7)>0){b<-gsub(k$word7,paste("<font color='",color,"'>",k$word7,"</font>",sep=""),b)}
    if(nchar(k$word8)>0){b<-gsub(k$word8,paste("<font color='",color,"'>",k$word8,"</font>",sep=""),b)}
    if(nchar(k$word9)>0){b<-gsub(k$word9,paste("<font color='",color,"'>",k$word9,"</font>",sep=""),b)}

  }
  return(b)
}

modifybody<-function(body,data.kw){
  if(length(data.kw$id)==0){
    return(body)
  }
  body.ary<-strsplit(body,"。")
  str<-""
  for(i in 1:length(body.ary[[1]])){
    b<-body.ary[[1]][i]
    b<-replacekw(b,data.kw)
    str<-paste(str,b,"。",sep="")
  }
  return(str)
}

getkeywords<-function(session){
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    sql<-paste("select * from fintech.tdnetKeyword where id='",query$id,"'",sep="")
    res<-dbSendQuery(con,sql)
    data.kw<-fetch(res,-1)
    dbDisconnect(con)
    return(data.kw)
}


getnews<-function(session){
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    sql<-paste("select last_modified,title,`text` from fintech.tdnet where id='",query$id,"'",sep="")
    res<-dbSendQuery(con,sql)
    data.df<-fetch(res,-1)
    dbDisconnect(con)
    return(data.df)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$newsBody <- renderDataTable({
    data.df<-getnews(session)
    data.kw<-getkeywords(session)
    b<-modifybody(data.df$text,data.kw)
    data.frame(body=c(b))
  }, escape = FALSE)
})

