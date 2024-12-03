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
                    c("caucasian", "asian", "black_or_african_american", "african", 
                      "american_indian_or_native_american", "east_indian", "north_african"))
  selectize_input(ID = "age_category", choices = merged$AgeCategory, selected = 
                    c("Fetus", "Pediatric", "Adult"))
  
  
  
  filter_data <- function(data, input){
    
    filtered <- data %>% 
      filter(Sex %in% input$sex & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category & gene == input$gene_name 
             & OncotreePrimaryDisease %in% input$onco_type)  %>%   
      dplyr::arrange(desc(expression))
    
    
      # Uses the input of the slider to decide how many cell lines will be displayed
      filtered <- head(filtered, input$cell_line_number)

    # If checkbox is checked, expression values of 0 will not be displayed
    if(input$checkbox == TRUE) 
    
    filtered <- filtered %>%
        filter(expression != 0)
    
    return(filtered)
    
  }
  
  generate_plot <- function(data, input){
    
    ggplot(data = data, 
           aes(x = expression, 
               y = reorder(StrippedCellLineName, expression))) +
      geom_bar(stat = "identity", fill = 'blue') + 
      ylab("Tumor Cell Line") +
      xlab(paste0(input$gene_name, " Expression level(log2 TPM)")) +
      theme_minimal()
    
    
  }
  
  # Renders the plot using the previously made functions
  output$plotly <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    
    plot <- generate_plot(filtered, input)
    return(plot)
    
    
  })
  
}
