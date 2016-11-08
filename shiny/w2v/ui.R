library(shiny)

# Define UI for application that plots random distributions 
shinyUI(bootstrapPage(
  
  # Application title
  headerPanel("word2vec by yahoo news"),
  textInput("word", "Input Word:",""),
  submitButton(text="検索",icon=NULL,width=NULL),
  
  h4("結果"),
  dataTableOutput("wordView")
))
