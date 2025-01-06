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
  
  # Generate barplot for when only one gene is chosen, here the cell lines will be sorted on expression levels
  
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

generate_box_plot <- function(data, text_angle){
  
  # Generates boxplot
  
  ggplot(data = data,
         aes(x = gene, 
             y = expression)) +
    geom_boxplot() +
    labs(x = "Gene", 
         y = "Expression level(log2 TPM)") + 
    theme_minimal() +
    theme(axis.text.x = element_text(angle = text_angle)) # Rotate gene names x-axis
}


#' Generate heat map
#'
#' This function generates a heat map using the merged data (tidy_expression + model)
#' 
#' The generated heat map shows the gene name on the x-axis, the cell line name on the
#' y-axis and shows the expression levels with colour (fill).
#' 
#' @param data merged dataframe of tidy_expression and model
#' @param text_angle int that determines rotation of x-axis labels
#' @param palette string that determines color palette of heatmap
#' @return a ggplot2 heat map object
#' @examples
#' generate_heatmap(merged, -90, "Blues")

generate_heatmap <- function(data, text_angle, palette){
  
  # Generate heat map 
  
  ggplot(data = data, 
         aes(x = gene, 
             y = StrippedCellLineName, 
             fill= expression)) +
    geom_tile() + 
    ylab("Tumor Cell Line") +
    xlab("Gene") +
    labs(fill = "Expression level (log2 TPM)") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = text_angle)) +
    scale_fill_distiller(palette = palette)
}


#' Generate table
#'
#' This function generates a table using the merged data (tidy_expression + model)
#' 
#' The generated table shows three columns from the merged dataframe; "StrippedCellLineName", "gene", and "expression"
#' 
#' @param data merged dataframe of tidy_expression and model
#' @return a table object
#' @examples
#' generate_table(merged)

# Function for rendering table with filtered data
generate_table <- function(data){
  # Shows information from 3 columns: StrippedCellLineName, gene, expression
  data %>% select(matches("StrippedCellLineName"), matches("gene"),
                  matches("expression"))
}
