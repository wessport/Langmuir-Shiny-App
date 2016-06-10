#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# UI

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("My Shiny App"),
  
  headerPanel("File input test"),
  
  # Sidebar  
  sidebarLayout(sidebarPanel(
    fileInput( #fileInput() function is used to upload the file of interest
      "file",
      label = "File Input",
      multiple = FALSE,
      accept = NULL,
      width = NULL
    ),
    helpText("Default max. file size is 5 MB")
  ), 
  
  # Main panel - plots go here
  mainPanel(tableOutput("dataTable"))
  )
))

#SERVER

# Define server logic required to output table
server <- shinyServer(function(input, output) {
  
  
  #Converting the csv file to a dataframe 
  
  data <- reactive(function(){
    
    if (is.null(input$file)) {
      # If user has not uploaded a file yet don't do anything
      return(NULL)
    } #Otherwise...
  
    #Assigning the file input to file1 so we can get the datapath for read.table
    file1 <- input$file  
    
    read.table(file1$datapath, header= F, ",", stringsAsFactors = F)
    
  })
  
  
  
  
  output$fileTable <- reactiveTable(function() {
    if (is.null(input$file)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    input$file
    
  })
  
  
})


# Run the application 
shinyApp(ui = ui, server = server)
