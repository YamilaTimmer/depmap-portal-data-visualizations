library(shiny)

server <- function(input, output, session) {
  
  selectize_input <- function(ID, choices, selected) {
    updateSelectizeInput(session, ID, 
                         choices = choices, 
                         server = TRUE, 
                         selected = selected)
  }
  
  selectize_input(ID = 'gene_name', choices = expr_test$gene,
                  selected = sort(expr_test$gene[1]))
  selectize_input(ID = 'sex', choices = unique(expr_test$Sex), selected = "Female")
  
  
  
  filter_data <- function(data, input){
    
    filtered <- data %>% 
      filter(Sex %in% input$sex & PatientRace %in% input$race &
               AgeCategory %in% input$age_category & gene == input$gene_name) %>%
      head(input$cell_line_number)
    
    return(filtered)
    
  }
  
  generate_plot <- function(data, input){
    
    plot <- ggplot(data = data, 
                   aes(x = expression, 
                       y = StrippedCellLineName)) +
      geom_bar(stat = "identity", fill = 'blue') + 
      ylab("Tumor Cell Line") +
      xlab(paste0(input$gene_name, " Expression level(log2 TPM)")) +
      theme_minimal()
    return(plot)
    
  }
  
  output$plotly <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    
    generate_plot(filtered, input)
    
    
    #filtered <- dplyr::arrange(filtered, expression)
    
    

  })
  
}