
tidy_merged <- read.csv("C:/Users/yamil/OneDrive - Hanze/Bio-informatica/Jaar 2/2.1 applicatie/goede_git/tidy_merged")


generate_plot_per_cell_line <- function(data){
  
  ggplot(data = data, aes(x=gene,y=expression)) +
    geom_bar(stat = "identity", fill = 'blue') + 
    ylab("Gene") + coord_flip() +
    xlab("Expression level(log2 TPM)") +
    theme_minimal()
  
}

generate_plot <- function(data){
  
  ggplot(data = data, 
         aes(x = expression, 
             y = reorder(StrippedCellLineName, expression))) +
    geom_bar(stat = "identity", fill = 'blue') + 
    ylab("Tumor Cell Line") +
    xlab("Expression level(log2 TPM)") +
    theme_minimal()
  
  
}

generate_table <- function(data){
  # only displays 3 given columns in application
  data %>% select(matches("StrippedCellLineName"), matches("gene"),
                  matches("expression"))
  
}


