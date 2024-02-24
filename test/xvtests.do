cscript "cross-validation prefix tests" adofile xv


// Load some example data
sysuse nlsw88.dta, clear

// make sure mata functions are defined in memory
run crossvalidate.mata

/*******************************************************************************
* This block tests all of the error codes that xv attempts to throw as soon    *
* as possible.  We assume subsequent errors are captured correctly by the      *
* individual commands that are called subsequently in the prefix.              *
*******************************************************************************/


// Test that error code is thrown for missing metric   
rcof "xv 0.7, pstub(pred): reg wage i.industry" == 198

// Test that error code is thrown for missing predicted value stub 
rcof "xv 0.7, metric(mse): reg wage i.industry" == 198

// Clear everything
clear all

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
xv 0.8, metric(r2) pstub(pred) monitors() display retain: reg mpg price i.rep78, vce(rob)

// There should be N stored estimation results, pred, predall, and _xvsplit 
// added as variables

// There should be values in e(splitter), e(training), e(validation), 
// e(stype), e(flavor), e(estresname), e(estresall)

