library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("news"),
  dateInput("date", label = h3("Date input"), value = "2016-05-31"), 
  
  h4("ニュース"),
  dataTableOutput("newsView"),
  h4("Tdnet"),
  dataTableOutput("tdnetView")
))
