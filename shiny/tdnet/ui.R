library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  h4("TDnet,赤字；Positive,緑字：Negative"),
  dataTableOutput("newsBody") 
))

