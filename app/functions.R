# Read data
#tidy_merged <- read.csv("C:\\Users\\yamil\\OneDrive - Hanzehogeschool Groningen\\Bio-informatica\\Jaar 2\\2.1 applicatie\\goede_git\\tidy_merged.csv")
load("C:\\Users\\yamil\\OneDrive - Hanzehogeschool Groningen\\Bio-informatica\\Jaar 2\\2.1 applicatie\\tidy_merged.rdata")

# Function for rendering barchart that shows gene expression per cell line (tab 1)
generate_plot <- function(data){
  if (input$plot_type == 'Barchart') {
  ggplot(data = data, 
         aes(x = expression, 
             y = reorder(StrippedCellLineName, expression))) +
    geom_bar(stat = "identity", fill = 'blue') + 
    ylab("Tumor Cell Line") +
    xlab("Expression level(log2 TPM)") +
    theme_minimal() + facet_wrap(~gene)
  
  }
}

# Function for rendering table with filtered data

generate_table <- function(data){
  # Shows information from 3 columns: StrippedCellLineName, gene, expression
  data %>% select(matches("StrippedCellLineName"), matches("gene"),
                  matches("expression"))
  
}


# Function for rendering barchart that shows gene expression of one gene across multiple cell lines (tab 3)
generate_plot_per_cell_line <- function(data){
  
  ggplot(data = data, aes(x=gene,y=expression)) +
    geom_bar(stat = "identity", fill = 'blue') + 
    ylab("Gene") + coord_flip() +
    xlab("Expression level(log2 TPM)") +
    theme_minimal()
  
}