library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  h4("ニュース,赤字；Positive,緑字：Negative"),
#  textOutput("newsDate"),
#  textOutput("newsTitle"),
   dataTableOutput("newsBody") 
#  textOutput("newsBody")
#  plotOutput("Plot")
))

# http://deta.hateblo.jp/entry/2014/04/16/075403
#shinyUI(bootstrapPage(
#
#  h3("Parsed query string"),
#  verbatimTextOutput("queryText"),
#
#  h3("Plot"),
#  plotOutput("Plot")
#
#))
