# Read data
load("C:\\Users\\yamil\\OneDrive - Hanze\\Bio-informatica\\Jaar 2\\2.1 applicatie\\tidy_expression.rdata")
load("C:\\Users\\yamil\\OneDrive - Hanze\\Bio-informatica\\Jaar 2\\2.1 applicatie\\model.rdata")

# Function for rendering barchart that shows gene expression per cell line (tab 1)
generate_plot <- function(data, fill){
  # Generate barplot for when multiple genes are chosen
  if (length(unique(data$gene)) > 1) {
    ggplot(data = data, 
           aes(x = expression, 
               y = StrippedCellLineName,
               fill = fill)) +
      geom_bar(stat = "identity") + 
      ylab("Tumor Cell Line") +
      xlab("Expression level(log2 TPM)") +
      theme_minimal() + facet_wrap(~gene)
  }
  
  # Generate barplot for when only one gene is chosen
  else {
    ggplot(data = data, 
           aes(x = expression, 
               y = reorder(StrippedCellLineName, expression))) + # Sort from high to low expression 
      geom_bar(stat = "identity", fill = 'blue') + 
      ylab("Tumor Cell Line") +
      xlab("Expression level(log2 TPM)") +
      theme_minimal()
  }
}


generate_box_plot <- function(data){
  
  # Generate boxplot for when multiple genes are chosen
  if (length(unique(data$gene)) > 1) {
    ggplot(data = data,
           aes(x = gene, y = expression)) +
      geom_boxplot() +
      labs(x = "Gene", y = "Gene Expression") + 
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = -90)) # Rotate gene names x-axis
  }
  
  # Generate boxplot for when only one gene is chosen
  else {
    ggplot(data = data,
           aes(x = gene, 
               y = expression)) +
      geom_boxplot() +
      labs(x = "Gene", y = "Gene Expression") + 
      theme_minimal()
  }
}

generate_heatmap <- function(data){
  if (length(unique(data$gene)) > 6) {
    # Generate barplot for when multiple genes are chosen
    ggplot(data = data, 
           aes(x = gene, 
               y = StrippedCellLineName, 
               fill= expression)) +
      geom_tile() + 
      ylab("Tumor Cell Line") +
      xlab("Gene") +
      labs(fill = "Expression level(log2 TPM)") +
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = -90))
  }
  else {
    
    ggplot(data = data, 
           aes(x = gene, 
               y = StrippedCellLineName, 
               fill= expression)) +
      geom_tile() + 
      ylab("Tumor Cell Line") +
      xlab("Gene") +
      labs(fill = "Expression level(log2 TPM)") +
      theme_minimal() + scale_fill_distiller(palette = "RdPu")
  }
}



# Function for rendering table with filtered data
generate_table <- function(data){
  # Shows information from 3 columns: StrippedCellLineName, gene, expression
  data %>% select(matches("StrippedCellLineName"), matches("gene"),
                  matches("expression"))
}


merge_data <- function(filtered_metadata, filtered_expr) {
  
  filtered_metadata <- filter_data(input)
  filtered_expr <- filter_expression(filtered_metadata, input)
  merged <- merge(filtered_metadata[, c("ModelID", "StrippedCellLineName")], filtered_expr, by = "ModelID", all = FALSE)
  
  
  return(merged)
}


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