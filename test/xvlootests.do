cscript "leave-one-out cross-validation prefix tests" adofile xvloo

// Get current maxvar setting
loc cmaxvar `c(max_k_theory)'

// Set low maximum variable to test first error 
set maxvar 2048

// Load some example data
sysuse nlsw88.dta, clear

// make sure mata functions are defined in memory
run crossvalidate.mata

/*******************************************************************************
* This block tests all of the error codes that xvloo attempts to throw as soon *
* as possible.  We assume subsequent errors are captured correctly by the      *
* individual commands that are called subsequently in the prefix.              *
*******************************************************************************/

// Test that correct error code is thrown when 
rcof "xvloo 0.7, pstub(pred) metric(mse) classes(12): mlogit industry south" == 1002

// Test that error code is thrown for missing metric
rcof "xvloo 0.7, pstub(pred): reg wage i.industry" == 198

// Test that error code is thrown for missing predicted value stub
rcof "xvloo 0.7, metric(mse): reg wage i.industry" == 198

// Test that error code is thrown if the user tries to specify K-Folds
rcof "xvloo 0.7, pstub(pred) metric(mse) kfold(4): reg wage i.industry " == 184

// Clear everything
clear all

// Resets the maxvar value to it's previous setting
set maxvar `cmaxvar'

// Load a smaller dataset
sysuse auto.dta, clear

// Run the Mata code again to ensure the functions are available
run crossvalidate.mata

/*******************************************************************************
* These tests should focus on ensuring returned results meet expectations and  *
* that variables created by the program are cleaned up or retained as the user *
* requested.  All other functionality should be addressed by tests for those   *
* individual commands.                                                         *
*******************************************************************************/

// Fit the model to 80% of the cases for training and retain the created 
// variables 
xvloo 0.8, metric(mse) pstub(pred) monitors(mae mape) display retain: reg mpg price i.rep78, vce(rob)

// There should be 59 stored estimation results, pred, predall, and _xvsplit 
// added as variables

// There should be values in e(splitter), e(training), e(validation), 
// e(stype), e(flavor), e(estresname), e(estresall)

