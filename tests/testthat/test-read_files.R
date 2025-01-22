library(here)

testthat::test_that("test error for missing model/expression.csv file", {
    
    # Create a temporary config file with paths to model.csv and expression.csv
    temp_config <- here("tests", "testthat", "temp", "temp_config.yaml")
    writeLines("model_csv: 'tests/testthat/temp/temp_model.csv' \nexpression_csv: 'tests/testthat/temp/temp_expression.csv' \nexpression_rdata: 'tests/testthat/temp/temp_expression.rdata' \nmodel_rdata: 'tests/testthat/temp/temp_model.rdata' ", 
               temp_config)
    
    # Creates temporary paths to simulate model.csv and expression.csv, without 
    # actually creating files
    temp_model <- file.path("tests", "testthat", "temp", "temp_model.csv")
    temp_expression <- file.path("tests", "testthat", "temp", "temp_expression.csv")
    
    
    # Test if the correct error is given for when the file is not found
    testthat::expect_error(read_files(temp_config), 
                           "Expression CSV file and/or Model CSV file not found.", 
                           fixed = TRUE)
    
    # Delete temporary config file
    unlink(temp_config)
    
    
})

testthat::test_that("Test missing keys in yaml", {
    
    temp_config <- here("tests", "testthat", "temp", "temp_config.yaml")
    
    # Write yaml with incorrect amount of keys (2 instead of 4)
    writeLines("model_csv: 'tests/testthat/temp/temp_model.csv' \nexpression_csv: 'tests/testthat/temp/temp_expression.csv'", 
               temp_config)
    
    # Test if the correct error is given for missing keys in config.yaml
    testthat::expect_error(read_files(temp_config), "Missing/incorrect keys in yaml.config, the 4 keys that are needed are: expression_csv, model_csv, expression_rdata, model_rdata", fixed = TRUE)
    
    # Delete temporary config file
    unlink(temp_config)
})


testthat::test_that("Test incorrect keys in yaml", {
    
    temp_config <- here("tests", "testthat", "temp", "temp_config.yaml")
    
    # Write yaml with incorrect key-names, I replaced all underscores with '.'
    writeLines("model.csv: 'tests/testthat/temp/temp_model.csv' \nexpression.csv: 'tests/testthat/temp/temp_expression.csv' \nexpression.rdata: 'tests/testthat/temp/temp_expression.rdata' \nmodel.rdata: 'tests/testthat/temp/temp_model.rdata' ", 
               temp_config)
    
    # Test if the correct error is given for incorrect keys in config.yaml  
    testthat::expect_error(read_files(temp_config), "Missing/incorrect keys in yaml.config, the 4 keys that are needed are: expression_csv, model_csv, expression_rdata, model_rdata", fixed = TRUE)
    
    # Delete temporary config file
    unlink(temp_config)
})

testthat::test_that("Test error for missing config file", {
    
    temp_config <- here("tests", "testthat", "temp", "temp_config.yaml")
    
    # Test if the correct error is given for when config.yaml is missing    
    testthat::expect_error(read_files(temp_config), 
                           "config.yaml file not found.", 
                           fixed = TRUE)
    
})





