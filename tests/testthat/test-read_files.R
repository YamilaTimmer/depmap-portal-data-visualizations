library(here)

testthat::test_that("test error for missing files (config/model/expression.csv)", {
    
    #temp <- dir.create(temp_dir, recursive = TRUE)
    # Create a temporary config file with paths to model.csv and expression.csv
    temp_config <- here("tests", "testthat", "temp", "temp_config.yaml")
    writeLines("model_csv: 'tests/testthat/temp/temp_model.csv' \nexpression_csv: 'tests/testthat/temp/temp_expression.csv'", 
               temp_config)

    # Creates temporary paths to simulate model.csv and expression.csv, without 
    # actually creating files
    temp_model <- file.path("tests", "testthat", "temp", "temp_model.csv")
    temp_expression <- file.path("tests", "testthat", "temp", "temp_expression.csv")
    
    
    # Test if the correct error is given for when config.yaml is missing
    testthat::expect_error(read_files(temp_config), "Expression CSV file and/or Model CSV file not found.", fixed = TRUE)
    
    # Delete temporary config file
    unlink(temp_config)
    
    # Test if the correct error is given for when config.yaml is missing
    testthat::expect_error(read_files(temp_config), "config.yaml file not found.", fixed = TRUE)
    
})



