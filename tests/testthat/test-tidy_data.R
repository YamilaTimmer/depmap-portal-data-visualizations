library(tidyr)

# Checks whether tidy_data() correctly converts expression_db to a tidy format
testthat::test_that("tests if resulting dataframe is tidy", {
    
    # Horizontal, "untidy" data
    expression_db <- data.frame(
        ModelID = 1:3,
        TSPAN6 = c(4.2, 0.4, 2.7), 
        TNMD = c(0.1, 0.5, 3.4),
        DPM1 = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Vertical, "tidy" data
    expected_tidy_df <- expected_df <- tibble(
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