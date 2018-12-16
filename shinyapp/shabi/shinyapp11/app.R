#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
fed<-read.csv("data/fedf.csv")
fed$DATE<-as.Date(fed$DATE,format="%Y/%m/%d")
sp<-read.csv("data/spnew.csv")
sp$Date<-as.Date(sp$Date,format="%Y/%m/%d")
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # App title ----
  titlePanel("SP500 VS Federal Fund Rates"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      sliderInput("date_range", 
                  "Choose Date Range:", 
                  min = as.Date("1980-12-01"),
                  max = as.Date("2018-10-01"),
                  value = c(as.Date("1996-12-01"),as.Date("2013-12-01")),
                  timeFormat = "%m/%d/%Y", ticks = F, animate = T
      )
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "distPlot"),
      plotOutput(outputId = "distPlot2")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$distPlot <- renderPlot({
    x <- sp[sp$Date>=input$date_range[1]&sp$Date<=input$date_range[2],]
    plot(x,  col = "#75AADB",type = "l",
         xlab = "Date",
         ylab = "Trend index",
         main = "SP500 trend index")
    
  })
  
  output$distPlot2 <- renderPlot({
    x    <- fed[fed$DATE>=input$date_range[1]&fed$DATE<=input$date_range[2],]
    plot(x$DATE,x$FEDFUNDS,  col = "#75AADB",type = "l",
         xlab = "Date",
         ylab = "Fed fund rates %",
         main = "Federal Fund Rates")
    
    
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

