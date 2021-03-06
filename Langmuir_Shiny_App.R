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
                                 checkboxInput(inputId = 'logTrans', label = 'Log Transform Dependent Variable', value = FALSE),
                                 textOutput("Qmax"),
                                 textOutput("QmaxSE"),
                                 textOutput("k"),
                                 textOutput("kSE"),
                                 textOutput("E"),
                                 downloadButton("downloadPlot", "Download Plot as PNG")),
                        tabPanel(inputId="tab2", "Residuals of Fit", plotOutput("graphResid"),
                                 "NOTE: Do your residuals resemble a 'fan-shape' ?  i.e. is the vertical 
                                 distance between each data point and the median line increasing as 
                                 your observations increase? If so, you may want to consider a 
                                 log-transformation of your dependent varibles. 
                                 This can be done by returning to the 'plot tab' and selecting the  
                                 'log-transform' checkbox underneath your plot.", 
                                 downloadButton("downloadResidPlot", "Download Plot as PNG")),
                        
                        tabPanel(inputId="tab3",  "Data", tableOutput("dataTable")),
                        tabPanel(inputId="tab4", "Data Summary", tableOutput("sum")),
                        tabPanel(inputId="tab5", "File Info", tableOutput("filedf")),
                        tabPanel(inputId="tab6", "App Credits", 
                                 "This app is a direct result of the encouragement and support of my mentor, 
                                  Melanie Mayes. 
                                  The inspiration of this app can be attributed to the 2007 publication 
                                  'On the Use of Linearized Langmuir Equations' by Bolster & Hornberger. 
                                  The theory behind fitting a Langmuir model to sorption data, as well as 
                                  the statistics behind the Goodness-of-Fit Measurement, can be understood 
                                  in more detail in their writings."
               )
             )
           )
        )
      )
    )
  )



#SERVER

# Define server logic required to output table
server <- shinyServer(function(input, output, session) {
  
  # Example Data
  exampleData <- reactive({
      
      X <- c(1.80,1.80,1.80,3.18,3.18,5.01,5.01,6.68,6.68,9.55,9.55,50.20,50.20,97.50,97.50,153.00,153.00,204.00,204.00,309.00,309.00)
    
      Y <- c(-8.412862,-2.097072,2.097072,15.078833,14.131693,34.210901,32.465827,53.999099,54.224393,78.055991,78.148600,376.304746,362.922643,538.938132,529.046422,690.271349,688.964188,816.090450,768.636319,838.989736,866.996974)
    
      exampleData <- data.frame(X,Y)
    
  })

  
  
  #Converting the uploaded csv file to a dataframe
  data <- reactive({
    
    #Assigning the file input to file1 so we can get the datapath for read.table
  
    file1 <- input$file
    
    if (is.null(file1)) {
      
      if(is.null(input$example)){return(NULL)} else { if(input$example){myData<-exampleData()}}
    
      } else {
      
    if (input$header == F){
      isolate({ 
        myData <- read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F) 
        
        
        colnames(myData) <- c("X","Y")
        
      })
      myData} else {myData <- read.table(file1$datapath,header = input$header,sep = input$sep,stringsAsFactors = F)
        
                    colnames(myData) <- c("X","Y")
      
                    myData } }
    
  })
  
  
  
  #Log Transforming Y If Requested
  
  logData <- reactive({
    
    logData <- data()
    absY <- abs(data()$Y)
    logData$Y <- log(absY)
    logData
    
  })
  
  # Provisionary Data 
  pData <- reactive({
    if(input$logTrans == F){data()} else {logData()} 
  })
  
  
  
  
  
  # TAB PANEL OUTPUTS
  
  
  # Changes Isotherm graph labels and y-axis dependent on log transform request
  observe({
    val1 <- max(pData()$Y) + 2*sd(pData()$Y)
    if(input$logTrans == T){
    updateSliderInput(session, "yAxis", value = val1)} else {updateSliderInput(session, "yAxis", value = val1)}
    })
  
  observe({
    val2 <- "Sorbed log(mg/kg)"
    if(input$logTrans == T){
      updateTextInput(session, "yTitle", value = val2)} else {updateTextInput(session, "yTitle", value = "Sorbed mg/kg")}
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
      
      pData()}
    
  })
  
  
  #This gives a summary of the data held in the uploaded file
  output$sum <- renderTable({
    if (is.null(data())) {
      return(NULL)
    } else {
      
      summary(pData())}
    
  })
  

  
  # LANGMUIR
  
  pQmax <- reactive ({pQmax <- max(pData())})  
  
  # Predicted k
  
  pK <- reactive({
    
    a <- pData()$X / pData()$Y
    b <- (pData()$X)^2
    c <- pData()$X
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
    
    if(pK < 0.1) {pK <- 0.1}
    
    pK
    
  })

  
  lang <- reactive({lang <- nls(formula = Y ~ (Q*k*X)/(1+(k*X)), data = pData(), start = list(Q = pQmax(), k = pK()), algorith = "port")})  
  
  langReport <- reactive({langReport <- summary(lang())})
  Qmax <- reactive({Qmax <- langReport()$coefficients [1,1]
                    Qmax <- round(Qmax, digits = 4)}) 
  
  QmaxSE <- reactive({QmaxSE <-langReport()$coefficients [1,2]
                      QmaxSE <- round(QmaxSE, digits = 4)})
  QmaxE1 <- reactive({Qmax() + QmaxSE()})
  QmaxE2 <- reactive({Qmax() - QmaxSE()})
  
  k <- reactive({k <- langReport()$coefficients [2,1]
                 k <- round(k, digits = 4)})
  kSE <- reactive({kSE <- langReport()$coefficients [2,2]
                   kSE <- round(kSE, digits = 4)})
  
 
# Goodness of Fit Statistic ( E )
  
  E <- reactive({
    
    f <- (pData()$Y - mean(pData()$Y))^2
    sf <- sum(f)
    f <- sf
    
    
    g <- (pData()$Y - predict(lang()))^2
    sg <- sum(g)
    g <- sg
    
    E <- (1 - (g/f))
    
    E <- round(E, digits = 4)
    
    E
    
  })
  

  
  # Langmuir Output   
  
  output$Qmax <- renderText({
    Qmax <- if (input$logTrans == F){Qmax()} else {exp(Qmax())}
    Qmax <- round(Qmax, digits = 4)
    print(paste(c("Maximum Sorption = ", Qmax, collapse = "")))})
  
  output$QmaxSE <- renderText({print(paste(c("Maximum Sorption Standard Error = ",QmaxSE()), collapse = ""))})

  output$k <- renderText({print(paste(c("Binding Coefficient = ",k()), collapse = ""))})
 
  output$kSE <- renderText({print(paste(c("Binding Coefficient Standard Error = ",kSE()), collapse = ""))})

  output$E <- renderText({print(paste(c("Goodness of Fit = ",E()), collapse = ""))})
  

  
  
  # GRAPHS
  
  # Basic plot of sorption data  
  
  plotIsotherm <- function(){
    
    if (is.null(data())) {
      return(NULL)
    } else {
      
      plot(pData(), 
           main = input$title,
           ylim = c(0,input$yAxis),
           xlab = input$xTitle,
           ylab = input$yTitle)
      
      
      lines(pData()$X,predict(lang()),col='blue')
      
      
      abline(h=Qmax(), lty=1)
      abline(h=QmaxE1(), lty=2)
      abline(h=QmaxE2(), lty=2)
      
      
    }
  }
  
  output$graph <- renderPlot ({
    
    print(plotIsotherm())
    
  })
  
  # Downloading Isotherm Plot
  
  output$downloadPlot <- downloadHandler(
    filename = paste(input$title, " ", date(),".png", sep =""),
    content = function(file) {
      png(file, width = 4, height = 4, units = 'in', res = 300)
      plotIsotherm()
      dev.off()
    })    
 
  
  
   
  # RESIDUALS
  
  rd <- reactive({rd <- as.numeric(resid(lang()))})
  
  
  sdrd <- reactive({sd(rd())})
  
  mrd <- reactive({as.numeric(median(rd()))})
  urd <- reactive({mrd()+sdrd()})
  lrd <- reactive({mrd()-sdrd()})

  
  # Residual Plot
  
  plotResid <- function(){
    
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
    
  }
  
  output$graphResid <- renderPlot({print(plotResid())})
  
  
  # Downloading Residuals Plot
  
  output$downloadResidPlot <- downloadHandler(
    filename = paste("Plot of Residuals", " ", date(),".png", sep =""),
    content = function(file) {
      png(file, width = 4, height = 4, units = 'in', res = 300)
      plotResid()
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
