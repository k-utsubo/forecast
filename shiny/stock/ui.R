library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  #headerPanel("stockChart"),
  textOutput("stockCode"),
  
  # Sidebar with a slider input for number of observations
#  sidebarPanel(
#    numericInput("stockCode","StockCode",6758)
#  ),
  
  # Show a plot of the generated distribution
#  mainPanel(
    h4("chart"),
    plotOutput("distPlot", height=350),
    h4("ニュース"),
    dataTableOutput("newsView"),
    h4("Tdnet"),
    dataTableOutput("tdnetView")
#  )
))
