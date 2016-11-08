library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createLink <- function(data.digest,data.file) {
  sprintf('<a href="http://td.kabumap.com/cgi-bin/tdNet/tdNetPdf.pl?%s,%s" target="_blank" class="btn btn-primary">Link</a>',data.file,data.digest)
}
createTdnetLink<-function(data.file){
  sprintf('<a href="../tdnet/?id=%s" target="_blank" class="btn btn-primary">Link</a>',data.file)
}
createNewsLink<-function(url){
  url<-gsub("http://headlines.yahoo.co.jp/hl\\?a=","",url)
  url<-paste("../yahoo/?url=",url,sep="")

  sprintf('<a href="%s" target="_blank" class="btn btn-primary">Link</a>',url)
}
createStockLink<-function(stockCode){
  sprintf('<a href="../stock/?stockCode=%s" target="_blank" class="btn btn-primary">Stock</a>',stockCode)
}

getmaxdate<-function(){
  con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
  res<-dbGetQuery(con, "set names utf8") 
  res<-dbSendQuery(con,'select date_format(max(date),"%Y-%m-%d") as date from yahooStockNewsSentiment') 
  data.df<-fetch(res,-1)
  dbDisconnect(con)
  return(data.df[1,])
}

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  output$newsView <- renderDataTable({
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select n.date,n.stockCode,n.title,n.href,s.score,s.score_cnt,s.score_std from yahooStockNews n left outer join yahooStockNewsSentiment s on n.href=s.href where n.date>='",input$date," 00:00:00' and n.date<='",input$date," 23:59:59' order by n.date desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(date=data.df$date,code=data.df$stockCode,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)
    data.table$link<-createNewsLink(data.df$href)
    data.table$stock<-createStockLink(data.df$stockCode)
    dbDisconnect(con)
    return(data.table)
  },escape=F,options = list(pageLength = 10))

  output$tdnetView <- renderDataTable({
    con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8")
    res<-dbSendQuery(con,paste("select t.disclosureNumber,t.file,t.disclosedDate,t.title,s.score,s.score_cnt,s.score_std,t.localCode  from live.TDnetPDF t left outer join fintech.tdnetSentiment s on s.id=t.disclosureNumber where  t.disclosedDate>= '",input$date," 00:00:00' and t.disclosedDate<='",input$date," 23:59:59' order by t.disclosedDate desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(date=data.df$disclosedDate,code=data.df$localCode,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)

    data.file<-data.df$file
    data.date<-format(Sys.Date(),"%d%m%Y")
    data.str<-paste(data.date,"atago902kabumap",data.df$file,sep="")
    data.digest<-as.character(lapply(data.str,function(x){return(digest(x,algo="sha1",serialize=F))}))

    #data.table$link<-createLink(data.digest,data.file)
    data.table$link<-createTdnetLink(data.df$disclosureNumber)
    data.table$stock<-createStockLink(gsub("0$","",data.df$localCode))
    dbDisconnect(con)
    return(data.table)
  }, escape = FALSE,options = list(pageLength = 10))

})
