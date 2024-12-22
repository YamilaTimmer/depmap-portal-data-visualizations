source("functions.R")
library(shiny)
library(plotly)
library(writexl)
library(shinycssloaders) #loadingscreen
library(shinyjqui) #resizable
library(RColorBrewer)


server <- function(input, output, session) {
  
  selectize_input <- function(ID, choices, selected) {
    updateSelectizeInput(session, ID, 
                         choices = choices, 
                         server = TRUE, 
                         selected = selected)
  }
  
  jqui_resizable(ui = "#plot_per_gene", operation = "enable")
  
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
  
  
  # Filters data based on user input
  # filter_data <- function(input){
  #   
  #   filtered_metadata <- model %>% 
  #     filter(Sex %in% input$sex 
  #            & PatientRace %in% input$race 
  #            & AgeCategory %in% input$age_category 
  #            & OncotreePrimaryDisease %in% input$onco_type)
  #   
  #   
  #   # Uses the input of the slider to decide how many cell lines will be displayed
  #   #filtered <- head(filtered, input$cell_line_number)
  # 
  #   # If checkbox is checked, expression values of 0 will not be displayed
  #   #if(input$checkbox == TRUE) 
  #   
  #   #filtered <- filtered %>%
  #       #filter(expression != 0)
  #   
  #   return(filtered_metadata)
  #   
  # }
  # 
  # 
  # filter_expression <- function(filtered_metadata, input) {
  #   filtered_expr <- tidy_expression %>%
  #     filter(
  #       X %in% filtered_metadata$ModelID,  # Match with ModelID or equivalent identifier
  #       gene %in% input$gene_name          # Filter based on selected genes
  #     )
  #   
  #   return(filtered_expr)
  # }
  # 
  # # # Renders barchart that shows gene expression per cell line (tab 1)
  # # output$plot_per_cell_line <- renderPlotly({
  # #   
  # #   filtered <- filter_data(tidy_merged, input)
  # #   filtered_per_cell_line <- filtered %>% filter(StrippedCellLineName == 
  # #                                                   input$cell_line)
  # #   
  # #   plot_per_cell_line <- generate_plot_per_cell_line(filtered_per_cell_line)
  # #   return(plot_per_cell_line)
  # #   
  # #   
  # # })
  # 
  
  
  # # Renders barchart that shows gene expression of one gene across multiple cell lines (tab 3)
  # output$plot_per_gene <- renderPlotly({
  #   
  #   filter_data(input)
  #   filter_expression(filtered_metadata, input)
  # 
  #   plot_per_gene <- generate_plot(filtered_expr)
  #   return(plot_per_gene)
  #   
  #   
  # })
  

  # Function to filter metadata based on input values
  filter_data <- function(input) {
    filtered_metadata <- model %>% 
      filter(Sex %in% input$sex 
             & PatientRace %in% input$race 
             & AgeCategory %in% input$age_category 
             & OncotreePrimaryDisease %in% input$onco_type)
    
    return(filtered_metadata)
  }
  
  # Function to filter expression data based on filtered metadata and input
  filter_expression <- function(filtered_metadata, input) {
    filtered_expr <- tidy_expression %>%
      filter(
        ModelID %in% filtered_metadata$ModelID,  # Match with ModelID or equivalent identifier
        gene %in% input$gene_name          # Filter based on selected genes
      )
    
    return(filtered_expr)
  }
  
  
  merge_data <- function(filtered_metadata, filtered_expr) {
    
    filtered_metadata <- filter_data(input)
    filtered_expr <- filter_expression(filtered_metadata, input)
    merged <- merge(filtered_metadata[, c("ModelID", "StrippedCellLineName", "Sex", "PatientRace", "AgeCategory")], filtered_expr, by = "ModelID", all = FALSE)
    
    
    return(merged)
  }
  
  
  
  # Render Plotly plot
  output$plot_per_gene <- renderPlotly({
    merged <- merge_data(filtered_metadata, filtered_expr)
    
    if (input$plot_type == "Barchart") {
      if (input$visualise_parameter == "Sex") {
        
        plot_per_gene <- generate_plot(merged, merged$Sex)
       
      }
      
      if (input$visualise_parameter == "Race") {
        
        plot_per_gene <- generate_plot(merged, merged$PatientRace)
        
      }
      
      if (input$visualise_parameter == "Age Category") {
        
        plot_per_gene <- generate_plot(merged, merged$AgeCategory)
        
      }
    # Step 3: Generate plot using the filtered expression data
      return(plot_per_gene)
    }
    

    if (input$plot_type == "Heatmap") {
      
      heatmap_plot <- generate_heatmap(merged)
      return(heatmap_plot)
    }
    
    else {
    boxplot_per_gene <- generate_box_plot(merged)
    return(boxplot_per_gene)
    }
  })
  
  
  # Renders table with filtered data (tab 2)
  output$table <- renderDT({
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
