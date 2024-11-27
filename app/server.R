library(shiny)

server <- function(input, output, session) {
  
  selectize_input <- function(ID, choices, selected) {
    updateSelectizeInput(session, ID, 
                         choices = choices, 
                         server = TRUE, 
                         selected = selected)
  }
  
  selectize_input(ID = 'gene_name', choices = tidy_merged$gene,
                  selected = sort(tidy_merged$gene[1]))
  selectize_input(ID = 'onco_type', choices = sort(merged$OncotreePrimaryDisease), selected
                  = "Adrenocortical Carcinoma")
  selectize_input(ID = 'sex', choices = unique(tidy_merged$Sex), selected = "Female")
  selectize_input(ID = "race", choices = merged$PatientRace, selected = "caucasian")
  selectize_input(ID = "age_category", choices = merged$AgeCategory, selected = "Adult")
  
  
  filter_data <- function(data, input){
    
    filtered <- data %>% 
      filter(Sex %in% input$sex & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category & gene == input$gene_name) %>%
      head(input$cell_line_number)
    
    
    
    return(filtered)
    
  }
  
  generate_plot <- function(data, input){
    
    ggplot(data = data, 
                   aes(x = expression, 
                       y = StrippedCellLineName)) +
      geom_bar(stat = "identity", fill = 'blue') + 
      ylab("Tumor Cell Line") +
      xlab(paste0(input$gene_name, " Expression level(log2 TPM)")) +
      theme_minimal()
    
    
  }
  
  output$plotly <- renderPlotly({
    
    filtered <- filter_data(tidy_merged, input)
    
    plot <- generate_plot(filtered, input)
    return(plot)
    
    
  })
  
}