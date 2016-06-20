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
library(shinythemes)

# UI

# Define UI for application 
ui <- shinyUI(fluidPage( theme = shinytheme("united"),
                         
 # Application title
   titlePanel(h1("Langmuir Shiny App", align = "center")),
                         
    headerPanel(h3("Import Data")),
                         
 # Sidebar
 sidebarLayout(
   sidebarPanel(
     fileInput("file", label = "File Input", multiple = FALSE),
     helpText("CSV files only. Default max.file size is 5 MB."),
     tags$hr(),
     h5(("Does your data have headers?")),
     checkboxInput(inputId = 'header', label = 'Header', value = FALSE),
     br(),
     
     radioButtons(inputId = 'sep', label = 'Separator', choices = c(Comma=',',Semicolon=';',Tab='\t', Space=''), selected = ',')),
   
   # Main panel - plots go here
   mainPanel(
     
     # This is a conditonal statment which only displays 
     # the landing page if a file has yet to be uploaded.
     conditionalPanel("output.fileUploaded", 
                      
                      h3("Welcome!", style = "color:blue"),
                      br(),
                      p("This app is intended to facilitate the generation
                         of sorption isotherms and to fit sorption data
                         to the Langmuir equation. It can also be used to
                         estimate parameter values such as maximum sorption
                         and binding affinity."),
                      br(),
                      h4("Instructions:", style = "color:#e95420"),
                      p("Begin by uploading a", strong("csv"), "file
                         of your dataset to the left. If your dataset has headers
                         be sure to check the header option. If uploading a csv
                         file that is", strong("not"), "comma separated, ensure to check
                         the appropriate delimiter option as well."),
                      br(),
                      p("Click the button below to try out an example!"),
                      br(),
                      actionButton("example", "Example Sorption Data"),
                      verbatimTextOutput("test"),
                      br(),
                      br(),
                      p("To return to this page, simply reload your web browser.")),
     
     conditionalPanel("output.dataReady", 
                      tabsetPanel(
                        tabPanel(inputId="tab1", "Plot", 
                                 textInput(inputId="title", label = "Write a Title", value = "Sorption Isotherm"), 
                                 textInput(inputId="xTitle", label = "X-Axis Label", value = "Equilibrium Conc. mg/L"),
                                 textInput(inputId="yTitle", label = "Y-Axis Label", value = "Sorbed mg/kg"),
                                 plotOutput("graph"),
                                 sliderInput("yAxis", "Adjust Y-Axis", 0, 10000, 4000),
                                 checkboxInput(inputId = 'logTrans', label = 'Log Transform Y-Axis', value = FALSE),
                                 textOutput("Qmax"), 
                                 textOutput("k"),
                                 textOutput("E"),
                                 downloadButton("downloadPlot", "Download Plot as PNG")),
                        tabPanel(inputId="tab2", "Residuals of Fit", plotOutput("graphResid")),
                        tabPanel(inputId="tab3",  "Data", tableOutput("dataTable")),
                        tabPanel(inputId="tab4", "Data Summary", tableOutput("sum")),
                        tabPanel(inputId="tab5", "File Info", tableOutput("filedf"))
                        
                                )
                      )
        )
      )
     )
  )



#SERVER

# Define server logic required to output table
server <- shinyServer(function(input, output) {
  
  # Example Data
  exampleData <- reactive({
      
      X <- c(1.80,1.80,1.80,3.18,3.18,5.01,5.01,6.68,6.68,9.55,9.55,50.20,50.20,97.50,97.50,153.00,153.00,204.00,204.00,309.00,309.00)
    
      Y <- c(-8.412862,-2.097072,2.097072,15.078833,14.131693,34.210901,32.465827,53.999099,54.224393,78.055991,78.148600,376.304746,362.922643,538.938132,529.046422,690.271349,688.964188,816.090450,768.636319,838.989736,866.996974)
    
      exampleData <- data.frame(X,Y)
    
  })

  test1 <- reactive({1})
  
  test2 <- eventReactive(input$example, {1})
  
  test3 <- reactive({test1()+test2()})
  
  output$test <- reactive({test3()})
  
  #Converting the uploaded csv file to a dataframe
  data <- reactive({
    
    #Assigning the file input to file1 so we can get the datapath for read.table
  
    file1<- if( 1 == 1){input$file}
    
    if (is.null(file1)) {
      
      return(NULL)
    
      } else {
      
      #file1<- if(exampleCalled !=1) {input$file} else{1}
        
      if(file1 == 1) {myData <- exampleData()} else {
      
      
      
    if (input$header == F){
      isolate({ 
        myData <- read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F) 
        
        
        colnames(myData) <- c("X","Y")
        
      })
      myData} else {myData <- read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F)
        
                    colnames(myData) <- c("X","Y")
      
                    myData }  } }
    
    
  })
  
  
  
  
  
  
  # This checks to see if a file has been uploaded.
  # It's evaluating the statement: There is no uploaded data. 
  # If that's true, it returns the value T.  
  
  output$fileUploaded <- reactive({
    return(is.null(data()))
    
  })
  
  
  outputOptions(output, 'fileUploaded', suspendWhenHidden=FALSE)
  
  #Displays plot once data has been uploaded
  output$dataReady <- reactive({
    return(data())
    
  })
  
  
  outputOptions(output, 'dataReady', suspendWhenHidden=FALSE)
  
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
  
  # Predicted k
  
  pK <- reactive({
    
    a <- data()$X / data()$Y
    b <- (data()$X)^2
    c <- data()$X
    d <- a*c
    e <- length(d)
    
    sa <- sum(a)
    sb <- sum(b)
    sc <- sum(c)
    sd <- sum(d)
    
    a <- sa
    b <- sb
    c <- sc
    d <- sd
    
    pK <- 1 / ((((a*b)-(c*d))/((e*b)-((c)^2)))*pQmax())
    
    if(pK < 0) {pK <- 0.01}
    
    pK
    
  })
  
  
  lang <- reactive({lang <- nls(formula = Y ~ (Q*k*X)/(1+(k*X)),  data = data(), start = list(Q = pQmax(), k = 0.01), algorith = "port")})  
  
  langReport <- reactive({langReport <- summary(lang())})
  Qmax <- reactive({Qmax <- langReport()$coefficients [1,1]
  Qmax <- round(Qmax, digits = 4)
  }) 
  QmaxSE <- reactive({QmaxSE <-langReport()$coefficients [1,2]})
  QmaxE1 <- reactive({Qmax() + QmaxSE()})
  QmaxE2 <- reactive({Qmax() - QmaxSE()})
  
  k <- reactive({k <- langReport()$coefficients [2,1]
  k <- round(k, digits = 4)})
  kSE <- reactive({langReport()$coefficients [2,2]})
  
  # Goodness of Fit Statistic ( E )
  
  E <- reactive({
    
    f <- (data()$Y - mean(data()$Y))^2
    sf <- sum(f)
    f <- sf
    
    
    g <- (data()$Y - predict(lang()))^2
    sg <- sum(g)
    g <- sg
    
    E <- (1 - (g/f))
    
    E <- round(E, digits = 4)
    
    E
    
  })
  
  
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
  
  output$E <- renderText({print(paste(c("Goodness of Fit = ",E()), collapse = ""))})
  
  
  
  # LOG Langmuir Output
  
  output$graphLogLang <- renderPlot ({
    
    plot(logData())
    
  })
  
  
  # GRAPHS
  
  
  # Basic plot of sorption data  
  
  plotIsotherm <- function(){
    
    if (is.null(data())) {
      return(NULL)
    } else {
      
      plot(data(), 
           main = input$title,
           ylim = c(0,input$yAxis),
           xlab = input$xTitle,
           ylab = input$yTitle)
      
      
      lines(data()$X,predict(lang()),col='blue')
      
      
      abline(h=Qmax(), lty=1)
      abline(h=QmaxE1(), lty=2)
      abline(h=QmaxE2(), lty=2)
      
      
    }
  }
  
  output$graph <- renderPlot ({
    
    print(plotIsotherm())
    
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
  
  # Downloading Isotherm Plot
  
  output$downloadPlot <- downloadHandler(
    filename = paste(input$title, " ", date(),".png", sep =""),
    content = function(file) {
      png(file)
      plotIsotherm()
      dev.off()
    })    
  
  
  
  
  # TAB PANEL
  
  output$tb <- renderUI({
    if (is.null(data())) {
      
      
      
    } else {
      
      tabsetPanel(
        tabPanel(inputId="tab1", "Plot", 
                 textInput(inputId="title", label = "Write a Title", value = "Sorption Isotherm"), 
                 textInput(inputId="xTitle", label = "X-Axis Label", value = "Equilibrium Conc. mg/L"),
                 textInput(inputId="yTitle", label = "Y-Axis Label", value = "Sorbed mg/kg"),
                 plotOutput("graph"),
                 sliderInput("yAxis", "Adjust Y-Axis", 0, 10000, 4000),
                 checkboxInput(inputId = 'logTrans', label = 'Log Transform Y-Axis', value = FALSE),
                 textOutput("Qmax"), 
                 textOutput("k"),
                 textOutput("E"),
                 downloadButton("downloadPlot", "Download Plot as PNG")),
        tabPanel(inputId="tab2", "Residuals of Fit", plotOutput("graphResid")),
        tabPanel(inputId="tab3",  "Data", tableOutput("dataTable")),
        tabPanel(inputId="tab4", "Data Summary", tableOutput("sum")),
        tabPanel(inputId="tab5", "File Info", tableOutput("filedf"))
      )}
    
  })
  
  
  
  
  
  
})


# Run the application
shinyApp(ui = ui, server = server)
