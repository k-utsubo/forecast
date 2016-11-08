library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("Shikiho"),
  textInput("stockCode", "Input StockCode:",""),
  submitButton(text="検索",icon=NULL,width=NULL),
  htmlOutput("linksHtml"),
  
  h4("結果"),
  htmlOutput("stockHtml"),
  htmlOutput("profHtml"),
  htmlOutput("profImage")
))
