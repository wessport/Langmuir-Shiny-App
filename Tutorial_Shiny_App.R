###############################################################    
#                                                             #
#                   LANGMUIR SHINY APP                        #
#                 Developed by Wes Porter                     #
#                                                             #
#            This app is intended to facilitate               #
#    the fitting of sorption data to the Langmuir equation.   #
#                                                             #
# Find out more about building applications with Shiny here:  #
#                                                             #
#                http://shiny.rstudio.com/                    #
#                                                             #
###############################################################


library(shiny)

# UI

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel(h1("Langmuir Shiny App", align = "center")),

  headerPanel(h3("Import Data")),

  # Sidebar
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = "File Input", multiple = FALSE),
      helpText("CSV files only. Default max.file size is 5 MB."),
      tags$hr(),
      h5(strong("Does your data have headers?")),
       checkboxInput(inputId = 'header', label = 'Header', value = FALSE),
      br(),

radioButtons(inputId = 'sep', label = 'Separator', choices = c(Comma=',',Semicolon=';',Tab='\t', Space=''), selected = ',')),

# Main panel - plots go here
    mainPanel(
       
      # This is a conditonal statment which only displays 
      # the landing page if a file has yet to be uploaded.
     conditionalPanel("output.fileNotUploaded == T", uiOutput("lp")),
      
     
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

      return(NULL)
    } 
    if (input$header == F){
    isolate({ 
      myData <- read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F) 
      

      colnames(myData) <- c("X","Y")
      
      })
    myData} else {read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F)}
  })
  
 
    
  
  
  
  # This checks to see if a file has been uploaded.
  # It's evaluating the statement: There is no uploaded data. 
  # If that's true, it returns the value T.  
  
  output$fileNotUploaded <- reactive({
    if (is.null(data())) {
      
      return(T)
    }
      
  })
  
  
  #This gives a summary of the file uploaded but NOT the data
  output$filedf <- renderTable({
    if (is.null(input$file)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
    
    input$file}
    
  })
  
  #This displays a table of the data held in the uploaded file
  output$dataTable <- renderTable({
    if (is.null(data())) {
      return(NULL)
    } else {
    
    data()}
    
  })
  
  
  #This gives a summary of the data held in the uploaded file
  output$sum <- renderTable({
    if (is.null(data())) {
      return(NULL)
    } else {
    
    summary(data())}
    
  })
  
 
  
  
# LANGMUIR

pQmax <- reactive ({pQmax <- max(data())})  

# Need to add a pK
  
# rise <- floor((length(data()$Y))*(1/2)) - data()[1,2]
# run <- floor((length(data()$X))*(1/2)) - data()[1,1]
#pK <- rise/run


lang <- reactive({lang <- nls(formula = Y ~ (Q*k*X)/(1+(k*X)),  data = data(), start = list(Q = pQmax(), k = 0.01), algorith = "port")})  

langReport <- reactive({langReport <- summary(lang())})
Qmax <- reactive({Qmax <- langReport()$coefficients [1,1]}) 
QmaxSE <- reactive({QmaxSE <-langReport()$coefficients [1,2]})
QmaxE1 <- reactive({Qmax() + QmaxSE()})
QmaxE2 <- reactive({Qmax() - QmaxSE()})

k <- reactive({langReport()$coefficients [2,1]})
kSE <- reactive({langReport()$coefficients [2,2]})


#Log Transforming Y



logData <- reactive({
  
  logData <- data()
  absY <- abs(data()$Y)
  logData$Y <- log(absY)
  
  })





   
# Langmuir Output   

output$Qmax <- renderText({
  print(paste(c("Maximum Sorption = ",Qmax()), collapse = ""))})
   
output$k <- renderText({print(paste(c("Binding Coefficient = ",k()), collapse = ""))})



# LOG Langmuir Output

output$graphLogLang <- renderPlot ({
  
  plot(logData())
  
})

    
# GRAPHS
  

# Basic plot of sorption data  
 output$graph <- renderPlot({
   
    plot(data(), 
         main = input$title,
         ylim = c(0,input$yAxis),
         xlab = input$xTitle,
         ylab = input$yTitle)
     

    lines(data()$X,predict(lang()),col='blue')
    
    
    abline(h=Qmax(), lty=1)
    abline(h=QmaxE1(), lty=2)
    abline(h=QmaxE2(), lty=2)

    
    
 })
  

# RESIDUALS
 
 rd <- reactive({rd <- as.numeric(resid(lang()))})
 

 sdrd <- reactive({sd(rd())})
 
 mrd <- reactive({as.numeric(median(rd()))})
 urd <- reactive({mrd()+sdrd()})
 lrd <- reactive({mrd()-sdrd()})
 
 
 # Residual Plot
 
 output$graphResid <- renderPlot({
   
  plot(rd(),
       main = "Residuals",
       xlab = "Observations",
       ylab = "Residuals")
   
   abline(h=mrd(), lty=1)
   abline(h=urd(), lty=2)
   abline(h=lrd(), lty=2)
   text(2,(mrd() + urd()/2), "Median")
   text(2,(urd() + urd()/2), "+ SD")
   text(2,(lrd() + mrd()/2), "- SD")

 })
   
   
   
 
 
  
# TAB PANEL
    
  output$tb <- renderUI({
    if (is.null(data())) {
      
      
    
   } else {
      
      tabsetPanel(
        tabPanel(inputId="tab1",  "Data", tableOutput("dataTable")),
        tabPanel(inputId="tab2", "Plot", 
                 textInput(inputId="title", label = "Write a Title", value = "Sorption Isotherm"), 
                 textInput(inputId="xTitle", label = "X-Axis Label", value = "Equilibrium Conc. mg/L"),
                 textInput(inputId="yTitle", label = "Y-Axis Label", value = "Sorbed mg/kg"),
                 plotOutput("graph"),
                 sliderInput("yAxis", "Adjust Y-Axis", 0, 10000, 4000),
                 textOutput("Qmax"), 
                 textOutput("k")),
        tabPanel(inputId="tab4", "Residuals", plotOutput("graphResid")),
        tabPanel(inputId="tab3", "Data Summary", tableOutput("sum")),
        tabPanel(inputId="tab5", "File Info", tableOutput("filedf"))
      )}
    
  })
  
  
  
# LANDING PAGE
  
  output$lp <- renderUI({
    if (is.null(data())) {
      
    mainPanel( 
      h3("Welcome!", style = "color:blue"),
      br(),
      p("This app is intended to facilitate the generation
          of sorption isotherms and to fit sorption data
          to the Langmuir equation. It can also be used to
          estimate parameter values such as maximum sorption
          and binding affinity."),
      br(),
      p("Begin by uploading a", strong("csv"), "file
          of your dataset to the left. If your dataset has headers
          be sure to check the header option. If uploading a csv
          file that is", strong("not"), "comma separated, ensure to check
          the appropriate delimiter option as well."),
      br(),
      p("To return to this page, simply reload your web browser.")
    )
      
     
      
    } else {
      
       
      
      }
    
  })
  

  
})


# Run the application
shinyApp(ui = ui, server = server)
