# Load data
load("C:\\Users\\yamil\\OneDrive - Hanze\\Bio-informatica\\Jaar 2\\2.1 applicatie\\tidy_expression.rdata")
load("C:\\Users\\yamil\\OneDrive - Hanze\\Bio-informatica\\Jaar 2\\2.1 applicatie\\model.rdata")


#' Generate bar plot
#'
#' This function generates a bar plot using the merged data (tidy_expression + model)
#'
#' The generated bar plot shows the expression levels on the x-axis and the cell line name
#' on the y-axis.
#' 
#' @param data merged dataframe of tidy_expression and model
#' @param fill a column of the merged dataframe, depending on the filter options chosen by user
#' @return a ggplot2 bar plot object
#' @examples
#' generate_barplot(merged, merged$AgeCategory)

generate_barplot <- function(data, fill, fill_label){
  
  # Generate barplot for when multiple genes are chosen
  
  if (length(unique(data$gene)) > 1) {
    ggplot(data = data, 
           aes(x = expression, 
               y = StrippedCellLineName,
               fill = fill)) +
      geom_bar(stat = "identity") + 
      ylab("Tumor Cell Line") +
      xlab("Expression level (log2 TPM)") +
      labs(fill = fill_label) +
      theme_minimal() + 
      facet_wrap( ~ gene) # To display multiple bar plots of each of the chosen genes
  }
  
  # Generate barplot for when only one gene is chosen
  
  else {
    ggplot(data = data, 
           aes(x = expression, 
               y = reorder(StrippedCellLineName, expression), # Sort from high to low expression 
               fill = fill)) + 
      geom_bar(stat = "identity") + 
      ylab("Tumor Cell Line") +
      xlab("Expression level (log2 TPM)") +
      labs(fill = fill_label) +
      theme_minimal()
  }
}


#' Generate box plot
#'
#' This function generates a box plot using the merged data (tidy_expression + model)
#'
#' The generated box plot shows the gene name on the x-axis and the expression levels
#' on the y-axis.
#' 
#' @param data merged dataframe of tidy_expression and model
#' @return a ggplot2 box plot object
#' @examples
#' generate_box_plot(merged)

generate_box_plot <- function(data){
  
  # Generate boxplot for when multiple genes are chosen
  
  if (length(unique(data$gene)) > 1) {
    ggplot(data = data,
           aes(x = gene, 
               y = expression)) +
      geom_boxplot() +
      labs(x = "Gene", 
           y = "Expression level(log2 TPM)") + 
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = -90)) # Rotate gene names x-axis
  }
  
  # Generate boxplot for when only one gene is chosen
  
  else {
    ggplot(data = data,
           aes(x = gene, 
               y = expression)) +
      geom_boxplot() +
      labs(x = "Gene", 
           y = "Expression level(log2 TPM)") + 
      theme_minimal()
  }
}



#' Generate heat map
#'
#' This function generates a heat map using the merged data (tidy_expression + model)
#' 
#' The generated heat map shows the gene name on the x-axis, the cell line name on the
#' y-axis and shows the expression levels with colour (fill).
#' 
#' @param data merged dataframe of tidy_expression and model
#' @return a ggplot2 heat map object
#' @examples
#' generate_heatmap(merged)

generate_heatmap <- function(data, text_angle){
  
  # Generate heat map for when less than 6 genes are selected
  
  # if (length(unique(data$gene)) < 6) {
  #   ggplot(data = data, 
  #          aes(x = gene, 
  #              y = StrippedCellLineName, 
  #              fill= expression)) +
  #     geom_tile() + 
  #     ylab("Tumor Cell Line") +
  #     xlab("Gene") +
  #     labs(fill = "Expression level (log2 TPM)") +
  #     theme_minimal() + 
  #     scale_fill_distiller(palette = "RdPu")
  #   
  # }
  # 
  # else {
    
    # Generate heat map for when more than 6 genes are selected (rotates x-axis labels)
    
    ggplot(data = data, 
           aes(x = gene, 
               y = StrippedCellLineName, 
               fill= expression)) +
      geom_tile() + 
      ylab("Tumor Cell Line") +
      xlab("Gene") +
      labs(fill = "Expression level (log2 TPM)") +
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = text_angle))
  }




# Function for rendering table with filtered data
generate_table <- function(data){
  # Shows information from 3 columns: StrippedCellLineName, gene, expression
  data %>% select(matches("StrippedCellLineName"), matches("gene"),
                  matches("expression"))
}

# 
# merge_data <- function(filtered_metadata, filtered_expr) {
#   
#   filtered_metadata <- filter_data(input)
#   filtered_expr <- filter_expression(filtered_metadata, input)
#   merged <- merge(filtered_metadata[, c("ModelID", "StrippedCellLineName")], filtered_expr, by = "ModelID", all = FALSE)
#   
#   
#   return(merged)
# }


# # Function for rendering barchart that shows gene expression of one gene across multiple cell lines (tab 3)
# generate_plot_per_cell_line <- function(data){
#   
#   ggplot(data = data, aes(x=gene,y=expression)) +
#     geom_bar(stat = "identity", fill = 'blue') + 
#     ylab("Gene") + coord_flip() +
#     xlab("Expression level(log2 TPM)") +
#     theme_minimal()
#   
# }