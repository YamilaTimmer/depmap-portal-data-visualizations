# Checks whether prepare_data() correctly modifies model and expression_db, by
# comparing expected result to end result
testthat::test_that("tests if dataframe gets modified correctly", {
    
    # Input for function
    model <- data.frame(
        ModelID = c(1, 2, 3),
        PatientRace = c("caucasian", "hispanic", NA),
        stringsAsFactors = FALSE
    )
    
    # Expected output from function
    model_expected_result <- data.frame(
        model <- data.frame(
            ModelID = c(1, 2, 3),
            PatientRace = c("caucasian", "hispanic", "unknown"),
            stringsAsFactors = FALSE
        )
    )
    
    # Input for function
    expression_db <- data.frame(
        X = 1:3,
        TSPAN6..7105. = c(4.2, 0.4, 2.7), 
        TNMD..64102. = c(0.1, 0.5, 3.4),
        DPM1..8813. = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Expected output from function
    expression_expected_result <- data.frame(
        ModelID = 1:3,
        TSPAN6 = c(4.2, 0.4, 2.7), 
        TNMD = c(0.1, 0.5, 3.4),
        DPM1 = c(2.3, 1.9, 4.0),
        stringsAsFactors = FALSE
    )
    
    # Call function
    result <- prepare_data(model, expression_db)
    
    # Check if expected and actual result are the same
    testthat::expect_equal(result$model, model_expected_result)
    testthat::expect_equal(result$expression_db, expression_expected_result)
    
})
