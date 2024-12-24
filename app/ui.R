library(shiny)
library(plotly)
library(DT)
library(shinyBS)
library(bsicons)
library(bslib)
library(shinyjs)

ui <- fluidPage(
  titlePanel("DepMap visualiser"), #title
  
  tabsetPanel(
    
    # tab n.1
    tabPanel("Visualize gene expression per gene",
             sidebarLayout(
               sidebarPanel(
                 useShinyjs(),
                 h4("Select parameters:"),
                 # input dropdown menu's for all list variables
                 selectizeInput('gene_name', label = "Select gene of interest", 
                                choices = NULL, multiple = TRUE),
                 bslib::input_dark_mode(id="theme"),
                 selectizeInput('cell_line_name', label = "Select cell line of interest", 
                                choices = NULL, multiple = TRUE),
                 actionButton("info_btn", label = "", icon = icon("question-circle")),
                 bsPopover(id = "info_btn", title = "Invoer uitleg", content = "Select gene(s) of which you want to visualise gene expression per cancer cell line"),
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
                 checkboxInput("checkbox", label = "Hide cell lines where gene expression = 0?", 
                               value = FALSE),
                 radioButtons("plot_type", label = "Select graph type",
                              choices = c("Barchart", "Boxplot", "Heatmap")),
                 conditionalPanel(
                   condition = "input.plot_type == 'Barchart'",
                   radioButtons("visualise_parameter", label = "Choose parameter to visualise",
                                choices = c("Sex", "Age Category", "Race"))
                 ),
                 submitButton(text = "Apply settings")
                 
               ),
               
               mainPanel(
                 
                 # Output for generated plot(s)
                 shinycssloaders::withSpinner( # loading screen
                   plotlyOutput("plot_per_gene", width = "auto", height = "auto", inline = TRUE)
                 ),
               )
             )
    ),
    
    # tab n.2
    tabPanel(
      "Table",
      fluidRow(
        column(width = 2,
               h4("Download data:"),
               downloadButton("download_csv", "Download .csv"),
               downloadButton("download_excel", "Download .xlsx")
        ),
        column(width = 10,
               DT::DTOutput("table"))
        
      )
    ),
    
    # tab n.3
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