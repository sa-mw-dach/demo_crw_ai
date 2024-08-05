library(shiny)

# Define server logic required to generate and plot a random distribution
server <- function(input, output, session) {

  output$distPlot <- renderPlot({

    # generate an rnorm distribution and plot it
    dist <- rnorm(input$obs)
    hist(dist)
  })

}

# Define UI for application that plots random distributions 
ui <- fluidPage(

  # Application title
  titlePanel("Hello OpenShift Shiny!"),

  # Sidebar with a slider input for number of observations
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", 
                  "Number of observations:", 
                  min = 1, 
                  max = 1000, 
                  value = 500)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

shinyApp(ui, server)
