library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  h3("寄り付き日経平均を予測する"),
   
  br(),
  h4("予想日経平均"),
  htmlOutput("predictPrice"),
  br(),
  h4("日経平均"),
  htmlOutput("realPrice")
))
