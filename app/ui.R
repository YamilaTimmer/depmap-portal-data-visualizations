library(shiny)

ui <- fluidPage(
  titlePanel("DepMap visualiser"), #title
  sidebarLayout(
    sidebarPanel(
      
      # input dropdown menu's for all list variables
      selectizeInput('gene_name', label = "Select gene of interest", choices = "A1BG"),
      selectizeInput("sex", label = "Select sex", choices = "Female", multiple = TRUE),
      sliderInput("cell_line_number", "Number of cell lines displayed:",
                  min = 1, max = 100,
                  value = 1, step = 1),
      submitButton(text = "Apply settings"),
      
    ),
    
    mainPanel(
      
      # outputs
      htmlOutput("title"),
      htmlOutput("text"),
      plotlyOutput("plotly"),
      
    )
  )
)