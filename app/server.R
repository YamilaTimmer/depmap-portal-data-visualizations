source("functions.R")


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
        merged <- merge(filtered_metadata[, c("ModelID", "StrippedCellLineName", 
                                              "Sex", "PatientRace", "AgeCategory", 
                                              "OncotreePrimaryDisease")], 
                        filtered_expr, by = "ModelID", all = FALSE)
    }
    
    # Makes merged data reactive, so that plots will be rendered instantly if 
    # the contents of the merged data do not change
    reactive_merged <- reactive({
        merge_data(filtered_metadata, filtered_expr)
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
        
        
        # If-statement for user-chosen fill parameter, the generated barplot
        # will be coloured according to the parameter. e.g. "Sex" will result in 
        # red bars for "Female" and blue bars for "Male".
        if (input$barplot_parameter == "Sex") {
            fill <- merged$Sex
            fill_label <- "Sex"
            
        }
        
        else if (input$barplot_parameter == "Race") {
            fill <- merged$PatientRace
            fill_label <- "Race"
            
        }
        
        else if (input$barplot_parameter == "Age Category") {
            fill <- merged$AgeCategory
            fill_label <- "Age Category"
            
        }
        
        else if (input$barplot_parameter == "Cancer Type") {
            fill <- merged$OncotreePrimaryDisease
            fill_label <- "Cancer Type"
            
        }
        
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
                barplot_per_gene <- generate_barplot(merged, merged$StrippedCellLineName, 
                                                     fill, fill_label) + 
                    facet_wrap( ~ merged$gene) +
                    ylab("Tumor Cell Line")
            }
        }
        
        else if (input$barplot_x_axis_parameter == "Cell line") {
            y = reorder(merged$gene, merged$expression)
            
            barplot_per_gene <- generate_barplot(merged, y, fill, fill_label) + 
                ylab("Gene")
            
            # Facet wrap to display multiple bar plots of each of the corresponding 
            # cell lines
            if (length(merged$StrippedCellLineName) > 1) {
                
                # Facet wrap to display multiple bar plots of each of the chosen cell lines
                barplot_per_gene <- generate_barplot(merged, merged$gene, fill, fill_label) + 
                    facet_wrap( ~ merged$StrippedCellLineName) +
                    ylab("Gene")
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
        
        # If-statement for user-chosen x-axis parameter, one boxplot/violinplot
        # will be shown per parameter, e.g. "Sex" will give one "Female" and one 
        # "Male" boxplot, showing difference in gene expression between sexes.
        if (input$boxplot_parameter == "Sex"){
            
            parameter <- merged$Sex
            xlab <- "Sex"
        }
        
        else if (input$boxplot_parameter == "Race"){
            
            parameter <- merged$PatientRace
            xlab <- "Race" 
        }
        
        else if (input$boxplot_parameter == "Age Category"){
            
            parameter <- merged$AgeCategory
            xlab <- "Age Category" 
        }
        
        else if (input$boxplot_parameter == "Cancer Type"){
            
            parameter <- merged$OncotreePrimaryDisease
            xlab <- "Cancer Type" 
        }
        
        # Will give same label to legend as to x-axis
        fill_label <- xlab
        
        # If-statement for the two checkboxes, one where the user selects boxplot 
        # or violinplot and one where the user selects to (not) show individual points in the plot
        if (input$boxplot_violinplot == "Boxplot" && input$individual_points_checkbox != TRUE) {
            
            boxplot_per_gene <- generate_box_plot(merged, parameter, text_angle, xlab, fill_label) + geom_boxplot()
            
        }
        
        else if (input$boxplot_violinplot == "Violin plot" && input$individual_points_checkbox != TRUE) {
            
            boxplot_per_gene <- generate_box_plot(merged, parameter, text_angle, xlab, fill_label)  + geom_violin()
            
        }
        else if (input$boxplot_violinplot == "Boxplot" && input$individual_points_checkbox == TRUE) {
            
            boxplot_per_gene <- generate_box_plot(merged, parameter, text_angle, xlab, fill_label) + geom_boxplot() + geom_point() 
            
        }
        else if (input$boxplot_violinplot == "Violin plot" && input$individual_points_checkbox == TRUE) {
            
            boxplot_per_gene <- generate_box_plot(merged, parameter, text_angle, xlab, fill_label) + geom_violin() + geom_point() 
            
        }
        
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
