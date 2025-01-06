source("functions.R")
library(shiny)
library(plotly)
library(writexl)
library(shinycssloaders) #loadingscreen
library(RColorBrewer)
library(shinyjs)

server <- function(input, output, session) {
  
  selectize_input <- function(ID, choices, selected) {
    updateSelectizeInput(session, ID, 
                         choices = choices, 
                         server = TRUE, 
                         selected = selected)
  }
  
  # Updates all dropdown inputs using server-side selectize
  selectize_input(ID = 'gene_name', choices = tidy_expression$gene,
                  selected = sort(tidy_expression$gene[1]))
  selectize_input(ID = 'onco_type', choices = sort(model$OncotreePrimaryDisease), 
                  selected = "Acute Myeloid Leukemia")
  selectize_input(ID = 'sex', choices = unique(model$Sex), 
                  selected = c("Female", "Male"))
  selectize_input(ID = "race", choices = model$PatientRace, selected = 
                    c("caucasian", "asian", "black_or_african_american",
                      "african", "american_indian_or_native_american", 
                      "east_indian", "north_african"))
  selectize_input(ID = "age_category", choices = model$AgeCategory, selected = 
                    c("Fetus", "Pediatric", "Adult"))
  selectize_input(ID = 'cell_line_name', choices = unique(model$StrippedCellLineName), 
                  selected = sort(model$StrippedCellLineName[1]))
  
  
  # Function to filter metadata based on input values
  filter_data <- function(input) {
    filtered_metadata <- model %>% 
      filter(Sex %in% input$sex 
             & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category 
             & OncotreePrimaryDisease %in% input$onco_type
             #& StrippedCellLineName %in% input$cell_line_name
      )
    
    return(filtered_metadata)
  }
  
  # Function to filter expression data based on filtered metadata and input
  filter_expression <- function(filtered_metadata, input) {
    filtered_expr <- tidy_expression %>%
      filter(
        ModelID %in% filtered_metadata$ModelID,  # Match with ModelID or equivalent identifier
        gene %in% input$gene_name        # Filter based on selected genes
      )
    
    return(filtered_expr)
  }
  
  
  merge_data <- function(filtered_metadata, filtered_expr) {
    
    filtered_metadata <- filter_data(input)
    filtered_expr <- filter_expression(filtered_metadata, input)
    merged <- merge(filtered_metadata[, c("ModelID", "StrippedCellLineName", "Sex", "PatientRace", "AgeCategory", "OncotreePrimaryDisease")], filtered_expr, by = "ModelID", all = FALSE)
    print(merged)
    
    return(merged)
  }
  
  
  output$boxplot_per_gene <- renderPlotly({
    
    merged <- merge_data(filtered_metadata, filtered_expr)
    
    if (length(unique(merged$gene)) > 1) {
      text_angle = -90
      
    }
    else {
      text_angle = 0
    }
    

    
    boxplot_per_gene <- generate_box_plot(merged, text_angle)
    return(boxplot_per_gene)
  })
  
  output$heatmap_per_gene <- renderPlotly({
    merged <- merge_data(filtered_metadata, filtered_expr)
    
    if (length(unique(merged$gene)) > 6) {
      
      text_angle = -90
      
    }
    else {
      text_angle = 0
    }
    
    if(input$palette == "Grayscale"){
      palette = "Greys"
    }
    
    if(input$palette == "Purple-Green"){
      palette = "PRGn"
    }
    
    if(input$palette == "Blue"){
      palette = "Blues"
    }
    
    if(input$palette == "Red-Blue"){
      palette = "RdBu"
    }
    
    heatmap_per_gene <- generate_heatmap(merged, text_angle, palette)
    
    return(heatmap_per_gene)
  })
  
  output$barplot_per_gene <- renderPlotly({
    merged <- merge_data(filtered_metadata, filtered_expr)
    
    if (input$barplot_x_axis_parameter == "Gene") {
      
      
      if (input$barplot_parameter == "Sex") {
        
        barplot_per_gene <- generate_barplot(merged, merged$Sex, "Sex")
        
      }
      
      if (input$barplot_parameter == "Race") {
        
        barplot_per_gene <- generate_barplot(merged, merged$PatientRace, "Race")
        
      }
      
      if (input$barplot_parameter == "Age Category") {
        
        barplot_per_gene <- generate_barplot(merged, merged$AgeCategory, "Age Category")
        
      }
      
      if (input$barplot_parameter == "Cancer Type") {
        
        barplot_per_gene <- generate_barplot(merged, merged$OncotreePrimaryDisease, "Cancer Type")
        
      }
    }
    
    
    return(barplot_per_gene)
  })
  
  
  # Renders table with filtered data (tab 2)
  output$filtered_table <- renderDT({
    merged <- merge_data(filtered_metadata, filtered_expr)
    generate_table(merged)
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
