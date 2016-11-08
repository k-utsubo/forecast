library(shiny)
library(quantmod)
library(RMySQL)
library(zoo)
library(digest)
# 日本語


createLink <- function(data.digest,data.file) {
#  if(data.file!=NULL){
    sprintf('<a href="http://td.kabumap.com/cgi-bin/tdNet/tdNetPdf.pl?%s,%s" target="_blank" class="btn btn-primary">Link</a>',data.file,data.digest)
#  }else{
#    printf("")
#  }
}
createTdnetLink<-function(data.file){
  sprintf('<a href="../tdnet/?id=%s" target="_blank" class="btn btn-primary">Link</a>',data.file)
}
createNewsLink<-function(url){
#  if(url!=NULL){
    url<-gsub("http://headlines.yahoo.co.jp/hl\\?a=","",url)
    url<-paste("../yahoo/?url=",url,sep="")
    sprintf('<a href="%s" target="_blank" class="btn btn-primary">Link</a>',url)
#  }else{
#    printf("")
#  }
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

#  stockCode<-query$stockCode
#  if(length(stockCode)<=3){
    stockCode<-"6758"
#  }
  output$stockCode <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    stockCode<-query$stockCode
    stockCode
  })
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot

  output$distPlot <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    #x    <- faithful[, 2]  # Old Faithful Geyser data
    #bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zaaa16d")
    res<-dbSendQuery(con,paste("select date as Date,oprice as Open,high as High,low as low,cprice Close,volume as Volume from ST_priceHistAdj where stockCode='",query$stockCode,"' and date>=date_add(now(),interval -90 day)",sep=""))
    data.df<-fetch(res,-1)
    data.zoo<-read.zoo(data.df)
    candleChart(data.zoo,theme="white",type="candles")
    dbDisconnect(con)
  })


  output$newsView <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="fintech",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select n.date,n.stockCode,n.title,n.href,s.score,s.score_cnt,s.score_std from fintech.yahooStockNews n left outer join fintech.yahooStockNewsSentiment s on n.href=s.href where n.stockCode='",query$stockCode,"' and  n.date>='2016-01-01' order by n.date desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(date=data.df$date,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)
    data.table$link<-createNewsLink(data.df$href)
    dbDisconnect(con)
    data.table 
  },escape=F,options = list(pageLength = 10))

  output$tdnetView <- renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    con<-dbConnect(dbDriver("MySQL"),dbname="live",user="root",password="",host="zaaa16d")
    res<-dbGetQuery(con, "set names utf8") 
    res<-dbSendQuery(con,paste("select t.file,t.disclosedDate,t.title,s.score,s.score_cnt,s.score_std  from live.TDnetPDF t left outer join fintech.tdnetSentiment s on s.id=t.disclosureNumber where  t.localCode='",query$stockCode,"0' and t.disclosedDate>= '2016-01-01' order by t.disclosedDate desc",sep=""))
    data.df<-fetch(res,-1)
    data.table<-data.frame(date=data.df$disclosedDate,title=data.df$title,score=data.df$score,score_cnt=data.df$score_cnt,reliability=data.df$score_std)

    data.file<-data.df$file
    #data.date<-format(as.Date(data.df$disclosedDate,"%Y-%m-%d %H:%M:%S"),"%d%m%Y")
    data.date<-format(Sys.Date(),"%d%m%Y")
    data.str<-paste(data.date,"atago902kabumap",data.df$file,sep="")
    data.digest<-as.character(lapply(data.str,function(x){return(digest(x,algo="sha1",serialize=F))}))
    
    data.table$link<-createTdnetLink(data.file)
    data.table$pdf<-createLink(data.digest,data.file)
    dbDisconnect(con)
    data.table
  }, escape = FALSE ,options = list(pageLength = 10))

})
