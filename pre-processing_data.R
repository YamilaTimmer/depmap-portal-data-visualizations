library(tidyr)
library(yaml)

# Read file paths from yaml configuration file
config <- yaml::read_yaml("config.yaml")

# Will read the files if the paths exist
if (file.exists(config$expression_csv) && file.exists(config$model_csv)) {
  expression_db <- read.csv(config$expression_csv)
  model <- read.csv(config$model_csv, na.strings = "") 
  
} else {
  
  # Raises an error if (one of) the files do(es) not exist
  stop("Expression CSV file and/or Model CSV file not found: ", 
       config$expression_csv, 
       config$model_csv)
}


# Change colname from 'X' to 'ModelID', to make the merging process in the application easier
colnames(expression_db)[1] <- "ModelID"

# Converts gene names of columns to simplified, cleaner version using regex statement
for (col in 2:ncol(expression_db)){
    colnames(expression_db)[col] <-  sub("\\.\\.[0-9]+\\.", 
                                         "", 
                                         colnames(expression_db)[col])
}

# Makes data tidy, converts from horizontal format to vertical format
tidy_expression <- expression_db %>% 
  pivot_longer(
    cols = 2:ncol(expression_db),
    names_to = "gene",
    values_to = "expression"
  )

# Saves generated tidy dataframes as R objects with config.yaml provided path
save(tidy_expression, file = config$expression_rdata)
save(model, file = config$model_rdata)
