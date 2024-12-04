library(shiny)

ui <- fluidPage(
  titlePanel("DepMap visualiser"), #title

tabsetPanel(
    tabPanel("Visualize gene expression per gene",
  sidebarLayout(
    sidebarPanel(
      
      # input dropdown menu's for all list variables
      selectizeInput('gene_name', label = "Select gene of interest", 
                     choices = NULL),
      selectizeInput("onco_type", label = "Select type of cancer", 
                     choices = NULL, multiple = TRUE),
      selectizeInput("sex", label = "Select sex", choices = NULL, 
                     multiple = TRUE),
      selectizeInput("race", label = "Select race", choices = NULL,
                     multiple = TRUE),
      selectizeInput("age_category", label = "Select age category", 
                     choices = NULL, multiple = TRUE),
      sliderInput("cell_line_number", "Number of cell lines displayed:",
                  min = 1, max = 100,
                  value = 15, step = 1),
      checkboxInput("checkbox", 
                    label = "Hide cell lines where gene expression = 0?", 
                    value = FALSE),
      submitButton(text = "Apply settings"),
      
    ),
    
    mainPanel(
      
      # outputs
      htmlOutput("title"),
      htmlOutput("text"),
      plotlyOutput("plot_per_gene"),
    )
  )
    ),
    tabPanel("Table",
             dataTableOutput("table")
             ),
    tabPanel("Visualize gene expression per cell line",
             sidebarLayout(
               sidebarPanel(
                 selectizeInput('cell_line', 
                                label = "Select cell line of interest", 
                                choices = NULL),
                 selectizeInput("onco_type", label = "Select type of cancer", 
                                choices = NULL, multiple = TRUE),
                 selectizeInput("sex", label = "Select sex", choices = NULL, 
                                multiple = TRUE),
                 selectizeInput("race", label = "Select race", choices = NULL,
                                multiple = TRUE),
                 selectizeInput("age_category", label = "Select age category", 
                                choices = NULL, multiple = TRUE),
                 sliderInput("cell_line_number", "Number of genes displayed:",
                             min = 1, max = 100,
                             value = 15, step = 1),
                 checkboxInput("checkbox", 
                               label = "Hide genes where expression = 0?", 
                               value =
                                 FALSE),
                 submitButton(text = "Apply settings"),
                 ),
             
             mainPanel(
             plotlyOutput("plot_per_cell_line"),
          )
      )
    )
  
  )
)