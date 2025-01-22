library(tidyr) # for using tibble datatype

testthat::test_that("Tests if data gets converted to tidy format", {
    
    # Checks whether tidy_data() correctly converts expression_db to a tidy format
    # here the "sunny day scenario" is being tested
    
    # Input, which is horizontal, "untidy" data
    expression_db <- data.frame(
        ModelID = 1:3,
        TSPAN6 = c(4.2, 0.4, 2.7), 
        TNMD = c(0.1, 0.5, 3.4),
        DPM1 = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Vertical, "tidy" data
    expected_tidy_df <- tibble(
        ModelID = rep(1:3, each = 3),
        gene = c("TSPAN6", "TNMD", "DPM1", 
                 "TSPAN6", "TNMD", "DPM1", 
                 "TSPAN6", "TNMD", "DPM1"),
        expression = c(4.2, 0.1, 2.3, 
                       0.4, 0.5, 1.9, 
                       2.7, 3.4, 4.0)
    )
    
    # Call function
    result <- tidy_data(expression_db)
    
    # Check if expected and actual result are the same
    testthat::expect_equal(result, expected_tidy_df)
    
})


testthat::test_that("Tests error for invalid datatype", {
    
    
    # Incorrect input where class is a list instead of a data frame
    expression_db <- list(
        ModelID = 1:3,
        TSPAN6 = c(4.2, 0.4, 2.7), 
        TNMD = c(0.1, 0.5, 3.4),
        DPM1 = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Tests if correct error gets called for invalid format
    testthat::expect_error(tidy_data(expression_db), 
                           "Invalid format, expression has to be in a dataframe", 
                           fixed = TRUE)
    
})

testthat::test_that("Tests error for invalid datatype", {
    
    
    # Incorrect input where class is a list instead of a data frame
    expression_db <- list(
        ModelID = 1:3,
        TSPAN6 = c(4.2, 0.4, 2.7), 
        TNMD = c(0.1, 0.5, 3.4),
        DPM1 = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Tests if correct error gets called for invalid format
    testthat::expect_error(tidy_data(expression_db), 
                           "Invalid format, expression has to be in a dataframe", 
                           fixed = TRUE)
    
})

testthat::test_that("Tests error for NA's in expression", {
    
    
    # Incorrect input where there are NA values in the expression data
    expression_db <- data.frame(
        ModelID = 1:3,
        TSPAN6 = c(4.2, NA, 2.7), 
        TNMD = c(NA, 0.5, 3.4),
        DPM1 = c(2.3, NA, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Tests if correct error gets called for invalid format
    testthat::expect_error(tidy_data(expression_db), 
                           "NA values found in expression data", 
                           fixed = TRUE)
    
})
