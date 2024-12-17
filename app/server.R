source("functions.R")
library(shiny)
library(plotly)
library(writexl)

server <- function(input, output, session) {
  
  selectize_input <- function(ID, choices, selected) {
    updateSelectizeInput(session, ID, 
                         choices = choices, 
                         server = TRUE, 
                         selected = selected)
  }
  
  # Updates all dropdown inputs using server-side selectize
  selectize_input(ID = 'gene_name', choices = tidy_merged$gene,
                  selected = sort(tidy_merged$gene[1]))
  selectize_input(ID = 'onco_type', choices = sort(tidy_merged$OncotreePrimaryDisease), 
                  selected = "Acute Myeloid Leukemia")
  selectize_input(ID = 'sex', choices = unique(tidy_merged$Sex), 
                  selected = c("Female", "Male"))
  selectize_input(ID = "race", choices = tidy_merged$PatientRace, selected = 
                    c("caucasian", "asian", "black_or_african_american",
                      "african", "american_indian_or_native_american", 
                      "east_indian", "north_african"))
  selectize_input(ID = "age_category", choices = tidy_merged$AgeCategory, selected = 
                    c("Fetus", "Pediatric", "Adult"))
  selectize_input(ID = 'cell_line', choices = unique(tidy_merged$StrippedCellLineName),
                  selected = sort(tidy_merged$StrippedCellLineName[1]))
  
  # Filters data based on user input
  filter_data <- function(input){
    
    filtered <- tidy_merged %>% 
      filter(Sex %in% input$sex 
             & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category 
             & gene %in% input$gene_name 
             & OncotreePrimaryDisease %in% input$onco_type)
    
    
    # Uses the input of the slider to decide how many cell lines will be displayed
    filtered <- head(filtered, input$cell_line_number)

    # If checkbox is checked, expression values of 0 will not be displayed
    if(input$checkbox == TRUE) 
    
    filtered <- filtered %>%
        filter(expression != 0)
    
    return(filtered)
    
  }
  
  # Renders barchart that shows gene expression per cell line (tab 1)
  output$plot_per_cell_line <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    filtered_per_cell_line <- filtered %>% filter(StrippedCellLineName == 
                                                    input$cell_line)
    
    plot_per_cell_line <- generate_plot_per_cell_line(filtered_per_cell_line)
    return(plot_per_cell_line)
    
    
  })
  
  # Renders table with filtered data (tab 2)
  output$table <- renderDT({
    filtered <- filter_data(input)
    generate_table(filtered)
  })
  
  # Renders barchart that shows gene expression of one gene across multiple cell lines (tab 3)
  output$plot_per_gene <- renderPlotly({
    
    filtered <- filter_data(input)
    filter_gene <- filtered %>% filter(gene %in% input$gene_name)

    plot_per_gene <- generate_plot(filtered)
    return(plot_per_gene)
    
    
  })
  
  # Allows for downloading data as .csv file
  output$download_csv <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep = "") # Naming file
    },
    contentType = "text/csv",
    content = function(file) {
      filtered <- filter_data(input)
      # FALSE for row.names so no 'empty' column will be made with indexes
      write.csv(filtered, file, row.names = FALSE)
    }
  )
  
  # Allows for downloading data as .xlsx file
  output$download_excel <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".xlsx", sep = "") # Naming file
    },
    content = function(file) {
      # Obtain filtered data and write it to path
      filtered <- filter_data(input)
      write_xlsx(filtered, path = file)
    }
  )
  
}
