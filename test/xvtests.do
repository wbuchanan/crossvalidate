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

// Test that correct error code is thrown when there are no results to replay
rcof "xvloo 0.8, replay: mlogit industry south" == 119

// Test that error code is thrown for missing metric   
rcof "xv 0.7, pstub(pred): reg wage i.industry" == 198

// Test that error code is thrown for missing predicted value stub 
rcof "xv 0.7, metric(mse): reg wage i.industry" == 198

// Create a variable that should trigger an error for an existing `pstub'all 
// variable
qui: g byte predall = rbinomial(3, 0.5)

// Test that error code is thrown if the user is trying to create the `pstub'all
// variable if it already exists
rcof "xv 0.7, pstub(pred) metric(mse): reg wage i.industry " == 110

// Now test that the same will happen if the pstub variable already exists
rename predall pred

// Test that error code is thrown if the user is trying to create the `pstub'
// variable if it already exists
rcof "xv 0.7, pstub(pred) metric(mse): reg wage i.industry " == 110

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


// Make sure the returned values are populated
assert !mi(`e(rng)')
assert !mi(`e(rngcurrent)')
assert !mi(`e(rngstate)')
assert !mi(`e(rngseed)')
assert !mi(`e(rngstream)')
assert !mi(`e(filename)')
assert !mi(`e(filedate)')
assert !mi(`e(version)')
assert !mi(`e(currentdate)')
assert !mi(`e(currenttime)')
assert !mi(`e(stflavor)')
assert !mi(`e(processors)')
assert !mi(`e(hostname)')
assert !mi(`e(machinetype)')
assert !mi(`e(splitter)')
assert !mi(`e(training)')
assert !mi(`e(validation)')
assert !mi(`e(testing)')
assert !mi(`e(stype)')
assert !mi(`e(flavor)')
assert mi(`e(forecastset)')
assert !mi(`e(estresnames)')
assert !mi(`e(estresall)')
assert !mi(`e(fitnm)')
assert !mi(`e(valnm)')
assert !mi(`e(xv)')
