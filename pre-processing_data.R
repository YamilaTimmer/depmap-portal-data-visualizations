library(tidyr)
library(naniar)
library(yaml)

config <- yaml::read_yaml("config.yaml")

expression_db <- read.csv(config$expression_csv)
model <- read.csv(config$model_csv, na.strings = "") 

colnames(expression_db)[1] <- "ModelID"

for (col in 2:ncol(expression_db)){
    colnames(expression_db)[col] <-  sub("\\.\\.[0-9]+\\.", "", colnames(expression_db)[col])
}

tidy_expression <- expression_db %>% 
  pivot_longer(
    cols = 2:ncol(expression_db),
    names_to = "gene",
    values_to = "expression"
  )

save(tidy_expression, file=config$expression_rdata)
save(model, file=config$model_rdata)


