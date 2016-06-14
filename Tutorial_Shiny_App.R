#
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

#   # Sidebar
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = "File Input", multiple = FALSE),
      helpText("Default max. file size is 5 MB"),
      tags$hr(),
      h5(helpText("Does your data have headers?")),
       checkboxInput(inputId = 'header', label = 'Header', value = FALSE),
      br(),

radioButtons(inputId = 'sep', label = 'Separator', choices = c(Comma=',',Semicolon=';',Tab='\t', Space=''), selected = ',')),

# Main panel - plots go here
    mainPanel(
          uiOutput("tb")
    )

  )
))



#SERVER

# Define server logic required to output table
server <- shinyServer(function(input, output) {
  #Converting the csv file to a dataframe
  
  data <- reactive({
    #Assigning the file input to file1 so we can get the datapath for read.table
    file1 <- input$file
    
    if (is.null(file1)) {
      # If user has not uploaded a file yet don't do anything
      return(NULL)
    }
    else
      
      (read.table(
        file1$datapath,
        header = input$header,
        sep = input$sep,
        stringsAsFactors = F
      ))
    
  })
  
  
  
  #This gives a summary of the file uploaded but NOT the data
  output$filedf <- renderTable({
    if (is.null(input$file)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    
    input$file
    
  })
  
  #This displays a table of the data held in the uploaded file
  output$dataTable <- renderTable({
    if (is.null(data())) {
      return(NULL)
    } #else
    
    data()
    
  })
  
  
  #This gives a summary of the data held in the uploaded file
  output$sum <- renderTable({
    if (is.null(data())) {
      return(NULL)
    } #else
    
    summary(data())
    
  })
  
  
  output$tb <- renderUI({
    if (is.null(data()))
      
      h5("FEED ME DATA")
    
    else
      
      tabsetPanel(
        tabPanel("Data", tableOutput("dataTable")),
        tabPanel("Data Summary", tableOutput("sum")),
        tabPanel("File Info", tableOutput("filedf"))
      )
    
  })
  
})


# Run the application
shinyApp(ui = ui, server = server)
