library(tidyr)
library(yaml)


#' Read files
#'
#' This function loads the file paths from config.yaml and reads them with read.csv
#'
#' @return list containing yaml file paths[1] and dataframes (model[2] and expression_db[3]) from .csv files
#' @examples
#' read_files()


read_files <- function(config_path){
    
   
    if (file.exists(config_path)){
        
        # Read file paths from yaml configuration file
        config <- yaml::read_yaml(config_path)
        
    } 
    
    else {
        

        # Raises an error if config file does not exist
        stop("config.yaml file not found.")
    }
    
    
    # Will read the files if the paths exist
    if (file.exists(config$expression_csv) && file.exists(config$model_csv)) {
        expression_db <- read.csv(config$expression_csv)
        model <- read.csv(config$model_csv, na.strings = "") 
        
        }
    
    else {
        
        # Raises an error if (one of) the files do(es) not exist
        stop("Expression CSV file and/or Model CSV file not found.")
    }
    
    return(list(config = config, 
                model = model, 
                expression_db = expression_db))
}


#' Prepare data
#'
#' This function applies minor changes to the contents of expression_csv and 
#' model_csv, in order to prepare the data for use
#'
#' @param model dataframe containing metadata
#' @param expression_db dataframe containing expression data
#' @return list with model and expression_db dataframes (with minor changes)
#' @examples
#' prepare_data(data$model, data$expression_db)

prepare_data <- function(model, expression_db){
    
    # Rename all NA's for PatientRace column to "unknown", so they can be displayed in the app
    model$PatientRace[is.na(model$PatientRace)] <- "unknown"
    
    # Change colname from 'X' to 'ModelID', to make the merging process in the application easier
    colnames(expression_db)[1] <- "ModelID"
    
    # Converts gene names of columns to simplified, cleaner version using regex statement
    for (col in 2:ncol(expression_db)){
        colnames(expression_db)[col] <-  sub("\\.\\.[0-9]+\\.", 
                                             "", 
                                             colnames(expression_db)[col])
    }
    
    return(list(model = model,
                expression_db = expression_db))
}


#' Tidy data
#'
#' This function makes the data tidy, by converting it from horizontal format to 
#' vertical format, using pivot_longer()
#'
#' @param expression_db dataframe containing expression data
#' @return tidy dataframe (`tidy_expression`), with new gene and expression columns
#' @examples
#' tidy_data(prepared_data$expression_db)

tidy_data <- function(expression_db){
    
    tidy_expression <- expression_db %>% 
        pivot_longer(
            cols = 2:ncol(expression_db),
            names_to = "gene",
            values_to = "expression"
        )
    
    return(tidy_expression)
}


#' Save data
#'
#' This function saves the modified expression_csv and model_csv as R objects,
#' so it can be (quickly) loaded when the app is launched.
#' 
#' @param tidy_expression tidy dataframe containing expression data
#' @param model dataframe containing metadata
#' @param config list with yaml file paths
#' @examples
#' save_data(tidy_expression, prepared_data$model, data$config)

save_data <- function(tidy_expression, model, config){
    
    # Saves generated tidy dataframes as R objects with config.yaml provided path
    save(tidy_expression, file = config$expression_rdata)
    save(model, file = config$model_rdata)
    
}


#' Main function
#'
#' This function calls all earlier defined functions in the correct order, 
#' passing the correct arguments
#' 
#' @examples
#' main()

main <- function(){
    
    config_path <- "config/config.yaml"
    data <- read_files(config_path)
    prepared_data <- prepare_data(data$model, data$expression_db)
    tidy_expression <- tidy_data(prepared_data$expression_db)
    save_data(tidy_expression, prepared_data$model, data$config)
    
}

# Run script
main()
