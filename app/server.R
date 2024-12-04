source("functions.R")
library(shiny)

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
  selectize_input(ID = 'onco_type', choices = sort(merged$OncotreePrimaryDisease), 
                  selected = "Acute Myeloid Leukemia")
  selectize_input(ID = 'sex', choices = unique(tidy_merged$Sex), 
                  selected = c("Female", "Male"))
  selectize_input(ID = "race", choices = merged$PatientRace, selected = 
                    c("caucasian", "asian", "black_or_african_american",
                      "african", "american_indian_or_native_american", 
                      "east_indian", "north_african"))
  selectize_input(ID = "age_category", choices = merged$AgeCategory, selected = 
                    c("Fetus", "Pediatric", "Adult"))
  selectize_input(ID = 'cell_line', choices = unique(tidy_merged$StrippedCellLineName),
                  selected = sort(tidy_merged$StrippedCellLineName[1]))
  
  
  filter_data <- function(data, input){
    
    filtered <- data %>% 
      filter(Sex %in% input$sex 
             & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category 
             & gene == input$gene_name 
             & OncotreePrimaryDisease %in% input$onco_type) %>% 
      dplyr::arrange(desc(expression))
    
    
      # Uses the input of the slider to decide how many cell lines will be displayed
    filtered <- head(filtered, input$cell_line_number)

    # If checkbox is checked, expression values of 0 will not be displayed
    if(input$checkbox == TRUE) 
    
    filtered <- filtered %>%
        filter(expression != 0)
    
    return(filtered)
    
  }
  
  
  output$plot_per_cell_line <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    filtered_per_cell_line <- filtered %>% filter(StrippedCellLineName == 
                                                    input$cell_line)
    
    plot_per_cell_line <- generate_plot_per_cell_line(filtered_per_cell_line)
    return(plot_per_cell_line)
    
    
  })
  

  output$table <- renderDataTable({
    filtered <- filter_data(tidy_merged, input)
    generate_table(filtered)
  })
  
  
  # Renders the plot using the previously made functions
  output$plot_per_gene <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    filtered_per_gene <- filtered %>% filter(gene == input$gene_name)
    
    plot_per_gene <- generate_plot(filtered_per_gene)
    return(plot_per_gene)
    
    
  })
  
}
