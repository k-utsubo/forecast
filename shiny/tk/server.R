library(shiny)
library(wordVectors)
library(magrittr)
library(tsne)
library(RMySQL)
library(digest)
# 日本語

get_code_df<-function(str){
  con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
  res<-dbGetQuery(con, "set names utf8")
  res<-dbSendQuery(con,paste("select stockCode,shortName from live.stockMasterFull where stockCode='",str,"' or stockName like '%",str,"%' or shortName like '%",str,"%' or englishName like '%",str,"%'",sep=""))
  data.df<-fetch(res,-1)
  dbDisconnect(con)
  return(data.df)
}
get_code<-function(str){
  data.df<-get_code_df(str)
  if(length(data.df$stockCode)>0){
    return(data.df$stockCode[1])
  }else{
    return("")
  }
}

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$profImage<- renderText({
    cat(file=stderr(),paste(input$stockCode,"\n"))
    if(!is.null(input$stockCode) && nchar(input$stockCode)>0){
      stockCode<-get_code(input$stockCode)
      paste("<img src='/shiny/images/tk/",stockCode,".png' width=100% height=80%>",sep="")
    }
  })
#  output$linksHtml<-renderText({
#    s<-""
#    if(!is.null(input$stockCode) &&  nchar(input$stockCode)>0){
#      data.df<-get_code_df(input$stockCode)
#      if(length(data.df$stockCode)>1){
#        for(i in  1:length(data.df$stockCode)){
#          s<-paste(s,"<form method='post' action='.'><input type='hidden' value='",data.df$stockCode[i],"'><input type='submit' value='(",data.df$stockCode[i],")",data.df$shortName[i],"'></form>",sep="")
#        }
#      }
#    }
#    paste(s)
#  })

  output$stockHtml <- renderText({
    if(!is.null(input$stockCode) &&  nchar(input$stockCode)>0){
      stockCode<-get_code(input$stockCode)
      con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
      res<-dbGetQuery(con, "set names utf8")
      res<-dbSendQuery(con,paste("select stockName,englishName from live.stockMasterFull where stockCode='",stockCode,"'",sep=""))
      data.df<-fetch(res,-1)
      dbDisconnect(con)
      paste("<h3>(",stockCode,")",data.df[1,]$stockName,",",data.df[1,]$englishName,"</h3>",sep="")
    }
  })
  output$profHtml <- renderText({
    if(!is.null(input$stockCode) &&  nchar(input$stockCode)>0){
      stockCode<-get_code(input$stockCode)
      con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zcod4md")
      res<-dbGetQuery(con, "set names utf8")
      res<-dbSendQuery(con,paste("select p.tokusyoku,p.jigyou,h.honbun1,h.honbun2 from tkShimenProfile p inner join tkShimenHonbun h where p.date=h.date and p.stockCode=h.stockCode and h.date=(select max(date) from tkShimenProfile where stockCode='",stockCode,"') and h.stockCode='",stockCode,"'",sep=""))
      data.df<-fetch(res,-1)
      dbDisconnect(con)
      paste(data.df$tokusyoku,"<br>",data.df$jigyou,"<br>",data.df$honbun1,"<br>",data.df$honbun2,"<br>",sep="")
    }
  })
})
