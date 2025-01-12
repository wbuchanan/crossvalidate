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

// Test that correct error code is thrown when there are no results to replay
rcof "xvloo 0.8, replay: mlogit industry south" == 119

// Test that correct error code is thrown when 
rcof "xvloo 0.98, pstub(pred) metric(mse) classes(12): mlogit industry south" == 1002

// Test that error code is thrown for missing metric
rcof "xvloo 0.7, pstub(pred): reg wage i.industry" == 198

// Test that error code is thrown for missing predicted value stub
rcof "xvloo 0.7, metric(mse): reg wage i.industry" == 198

// Test that error code is thrown if the user tries to specify K-Folds
rcof "xvloo 0.7, pstub(pred) metric(mse) kfold(4): reg wage i.industry " == 184

// Create a variable that should trigger an error for an existing `pstub'all 
// variable
qui: g byte predall = rbinomial(3, 0.5)

// Test that error code is thrown if the user is trying to create the `pstub'all
// variable if it already exists
rcof "xvloo 0.7, pstub(pred) metric(mse): reg wage i.industry " == 110

// Now test that the same will happen if the pstub variable already exists
rename predall pred

// Test that error code is thrown if the user is trying to create the `pstub'
// variable if it already exists
rcof "xvloo 0.7, pstub(pred) metric(mse): reg wage i.industry " == 110

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
xvloo 0.8, metric(mse) pstub(pred) monitors(mae mape) display retain: 		 ///   
reg mpg price i.rep78, vce(rob)

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

assert `"`e(stype)'"' == "Leave One Out"

// Create a test case for mixed effects models
webuse pig.dta, clear

// Fit the mixed effect model
xvloo 0.6, metric(msle) pstub(p) display retain monitors(mse rmse mae bias   ///   
mbe r2 mape smape rmsle rpd iic ccc huber phl rpiq r2ss) split(loosplit)     ///   
uid(id): mixed weight week || id:week, reml dfmethod(kroger)

// Load dataset for poisson example
webuse epilepsy.dta, clear

// Simple TT split case
xvloo 0.6, metric(pll) pstub(p) display retain monitors(mse rmse mae bias    ///   
mbe r2 mape smape msle rmsle rpd iic ccc huber phl rpiq r2ss) split(loosplt) ///   
pmethod(n): poisson seizures treat lbas lbas_trt lage v4

// Load dataset for ivregress example
webuse hsng2.dta, clear

// Simple TT split case
xvloo 0.5, metric(msle) pstub(p) display retain monitors(mse rmse mae bias   ///   
mbe r2 mape smape rmsle rpd iic ccc huber phl rpiq r2ss) split(ivsplit):     ///   
ivregress 2sls rent pcturban (hsngval = faminc i.region), small

// Load dataset for ologit example
webuse fullauto.dta, clear

// Simple test case 
// Something here is causing an error in the cleanup phase of predictit
xvloo 0.4, metric(mcacc) pstub(p) display classes(5) retain split(mcsplit)	 ///   
monitors(mcsens mcprec mcspec mcppv mcnpv mcbacc mcmcc mcf1 mcjindex		 ///   
mcdetect mckappa): ologit rep77 foreign length mpg
