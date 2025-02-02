source("functions.R")


server <- function(input, output, session) {
    
    selectize_input <- function(ID, choices, selected) {
        updateSelectizeInput(session, ID, 
                             choices = choices, 
                             server = TRUE, 
                             selected = selected)
    }
    
    # Dialog that pops up on app launch, with link to repo (for further info)
    showModal(modalDialog(
        title = "Welcome!",
        size = "xl",
        easyClose = FALSE,
        tags$div("Thank you for using DepMap Visualiser! For more information on how to use the app, or for more information on the used data, please visit my GitHub repo. This can be done by clicking the GitHub logo at the top of the application, or by clicking ", 
                 tags$a(href = "https://github.com/YamilaTimmer/depmap-portal-data-visualizations", "here"), 
                 "."),
        
    ))
    
    # Updates all dropdown inputs using server-side selectize
    selectize_input(ID = 'gene_name', choices = tidy_expression$gene,
                    selected = sort(tidy_expression$gene[1]))
    
    selectize_input(ID = 'onco_type', choices = sort(model$OncotreePrimaryDisease), 
                    selected = "Acute Myeloid Leukemia")
    
    selectize_input(ID = 'sex', choices = unique(model$Sex), 
                    selected = c("Female", "Male", "Unknown"))
    
    selectize_input(ID = "race", choices = model$PatientRace, selected = 
                        c("caucasian", "asian", "black_or_african_american",
                          "african", "american_indian_or_native_american", 
                          "east_indian", "north_african", "hispanic_or_latino", "unknown"))
    
    selectize_input(ID = "age_category", choices = model$AgeCategory, selected = 
                        c("Fetus", "Pediatric", "Adult", "Unknown"))
    
    
    # Filters metadata based on input values
    filter_data <- function(input) {
        filtered_metadata <- model %>% 
            filter(Sex %in% input$sex 
                   & PatientRace %in% input$race 
                   & AgeCategory %in% input$age_category 
                   & OncotreePrimaryDisease %in% input$onco_type
            )
        
        return(filtered_metadata)
        
    }
    
    # Filters expression data based on filtered metadata and input
    filter_expression <- function(filtered_metadata, input) {
        filtered_expr <- tidy_expression %>%
            filter(
                ModelID %in% filtered_metadata$ModelID,  # Match with ModelID or equivalent identifier
                gene %in% input$gene_name        # Filter based on selected genes
            )
        
        return(filtered_expr)
        
    }
    
    
    # Merges filtered (meta)data
    merge_data <- function(filtered_metadata, filtered_expr) {
        
        input$submit_button
        
        filtered_metadata <- filter_data(input)
        filtered_expr <- filter_expression(filtered_metadata, input)
        merged <- merge(filtered_metadata, 
                        filtered_expr, 
                        by = "ModelID", 
                        all = FALSE)
        
    }
    
    # Makes merged data reactive, so that plots will be rendered instantly if 
    # the contents of the merged data do not change
    reactive_merged <- reactive({
        
        merged <- merge_data(filtered_metadata, filtered_expr)
    })
    
    
    # Calls function to generate barplot
    output$barplot_per_gene <- renderPlotly({
        
        merged <- reactive_merged()
        
        # Updates table_columns input based on colnames of merged
        selectize_input(ID = 'table_columns', 
                        choices = colnames(merged), 
                        selected = c("gene", "StrippedCellLineName", "expression"))
        
        # Required merged to have atleast 1 row, prevents error from showing up
        req(nrow(merged) >= 1)
        
        
        # Fill list, parameter is assigned to corresponding UI option
        fill_list <- list(
            "Sex" = merged$Sex,
            "Race" = merged$PatientRace,
            "Age Category" = merged$AgeCategory,
            "Cancer Type" = merged$OncotreePrimaryDisease
        )
        
        fill = fill_list[[input$barplot_parameter]]
        
        # Will give same legend same label as chosen option
        fill_label <- input$barplot_parameter
        
        # If-statement that, based on user input, decides what parameter gets
        # used for the x-axis/facet-wrap (gene or cell line)
        if (input$barplot_x_axis_parameter == "Gene") {
            
            
            # Sorts cell line names on expression from high to low, only shows 
            # when only one gene is selected
            merged$StrippedCellLineName <- reorder(merged$StrippedCellLineName, 
                                                   merged$expression)
            
            barplot_per_gene <- generate_barplot(merged, merged$StrippedCellLineName, 
                                                 fill, fill_label) + 
                ylab("Tumor Cell Line")
            
            
            if (length(merged$gene) > 1) {
                
                # Facet wrap to display multiple bar plots of each of the chosen genes
                barplot_per_gene <- barplot_per_gene + facet_wrap( ~ merged$gene)
            }
        }
        
        else if (input$barplot_x_axis_parameter == "Cell line") {
            
            barplot_per_gene <- generate_barplot(merged, merged$gene, fill, fill_label) + 
                ylab("Gene")
            
            # Facet wrap to display multiple bar plots of each of the corresponding 
            # cell lines
            if (length(merged$StrippedCellLineName) > 1) {
                
                # Facet wrap to display multiple bar plots of each of the chosen cell lines
                barplot_per_gene <- barplot_per_gene + facet_wrap( ~ merged$StrippedCellLineName)
            }
        }

    })
    
    
    # Calls function to generate boxplot (also used for violin plot due to similarity)
    output$boxplot_per_gene <- renderPlotly({
        
        
        merged <- reactive_merged()
        
        # Required merged to have atleast 1 row, prevents error from showing up
        req(nrow(merged) >= 1)
        
        
        # If-statement for xlab angles, with more than 1 gene they will be 
        # vertical (for better readability)
        if (length(unique(merged$gene)) > 1) {
            text_angle <- -90
            
        }
        else {
            text_angle <- 0
        }
        
        # Parameter list, parameter is assigned to corresponding UI option
        parameter_list <- list(
            "Sex" = merged$Sex,
            "Race" = merged$PatientRace,
            "Age Category" = merged$AgeCategory,
            "Cancer Type" = merged$OncotreePrimaryDisease
        )
        
        # Assign parameter, based on input
        parameter = parameter_list[[input$boxplot_parameter]]
        
        # Assign arguments using the application input
        fill_label <- input$boxplot_parameter
        xlab <- input$boxplot_parameter
        boxplot_violinplot <- input$boxplot_violinplot
        individual_points_checkbox <- input$individual_points_checkbox
        merge_genes_checkbox <- input$merge_genes_checkbox
        
        # Call function with arguments to generate the plot
        boxplot_per_gene <- generate_box_plot(merged, parameter, text_angle, 
                                              xlab, fill_label, 
                                              boxplot_violinplot, 
                                              individual_points_checkbox,
                                              merge_genes_checkbox)
        
    })
    
    # Calls function to generate heatmap
    output$heatmap_per_gene <- renderPlotly({
        
        merged <- reactive_merged()
        
        # Required merged to have atleast 1 row, prevents error from showing up
        req(nrow(merged) >= 1)
        
        # If-statement for xlab angles, with more than 6 genes they will be 
        # vertical (for better readability)
        if (length(unique(merged$gene)) > 6) {
            
            text_angle <- -90
            
        }
        
        else {
            text_angle <- 0
        }
        
        # Assign heatmap options to corresponding colorbrewer names
        palettes <- list("Grayscale" = "Greys", 
                         "Purple-Green" = "PRGn", 
                         "Blue" = "Blues", 
                         "Red-Blue" = "RdBu")
        
        # Assigns palette to heatmap that aligns with chosen option
        palette = palettes[[input$palette]]
        
        heatmap_per_gene <- generate_heatmap(merged, text_angle, palette)
        
    })
    
    # Renders table with filtered data
    output$filtered_table <- renderDT({
        
        merged <- reactive_merged()
        
        # Required merged to have atleast 1 row, prevents error from showing up
        req(nrow(merged) >= 1)
        
        # Displays only the columns the user has selected to display
        merged <- merged %>% select(matches(input$table_columns))
        
        # Calls create_link function to generate genecards URL for each gene, 
        # to provide user with additional info on gene
        merged$gene <- create_link(merged$gene)
        
        # Rounds expression to 5 decimals, does not change the data itself in 
        # the .xslx and .csv files
        merged$expression <- round(merged$expression, 5)
        
        # Escape false in order to render the hyperlink properly
        filtered_table <- datatable((merged), escape = FALSE)
        
    })
    
    
    # Allows for downloading data as .csv file
    output$download_csv <- downloadHandler(
        filename = function() {
            paste("DepMap_data_", Sys.Date(), ".csv", sep = "") # Naming file
        },
        contentType = "text/csv",
        content = function(file) {
            merged <- merge_data(filtered_metadata, filtered_expr)
            
            # FALSE for row.names so no 'empty' column will be made with indexes
            write.csv(merged, file, row.names = FALSE)
        }
    )
    
    
    # Allows for downloading data as .xlsx file
    output$download_excel <- downloadHandler(
        filename = function() {
            paste("DepMap_data_", Sys.Date(), ".xlsx", sep = "") # Naming file
        },
        content = function(file) {
            
            # Obtain filtered data and write it to path
            merged <- merge_data(filtered_metadata, filtered_expr)
            write_xlsx(merged, path = file)
        }
    )
    
}
