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
rcof "xv 0.8, replay: mlogit industry south" == 119

// Test that error code is thrown for missing metric   
rcof "xv 0.7, pstub(pred): reg wage i.industry" == 198

// Test that error code is thrown for missing predicted value stub - code now allows pstub to be missing?
//rcof "xv 0.7, metric(mse): reg wage i.industry" == 198

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
assert mi("`e(rng)'")
assert mi("`e(rngcurrent)'")
assert mi("`e(rngstate)'")
assert mi("`e(rngseed)'")
assert mi("`e(rngstream)'")
assert mi("`e(filename)'")
assert mi("`e(filedate)'")
assert mi("`e(version)'")
assert mi("`e(currentdate)'")
assert mi("`e(currenttime)'")
assert mi("`e(stflavor)'")
assert mi("`e(processors)'")
assert mi("`e(hostname)'")
assert mi("`e(machinetype)'")
assert "`e(splitter)'" == "_xvsplit"
assert "`e(training)'" == "1"
assert mi("`e(validation)'")
assert "`e(testing)'" == "2"
assert "`e(stype)'" == "Train/Test Split"
assert "`e(flavor)'" == "Simple Random Sample"
assert mi("`e(forecastset)'")
assert !mi("`e(estresnames)'")				
assert mi("`e(estresall)'")
assert "`e(fitnm)'" == "xvfit"
assert "`e(valnm)'" == "xvval"
assert !mi("`e(xv)'")       //Since this is a matrix I think it needs to be in double quotes
assert !mi(`e(metric)')



// Remove the split and prediction variables
drop _xvsplit pred*

// Simple test with optional arguments passed to monitors
xv .8, metric(mse) pstub(pred) monitors(rmse((1, 2)) mae mape smape(("y"))): ///   
reg price mpg i.foreign

assert !mi(`e(rmse)')
assert !mi(`e(mae)')
assert !mi(`e(mape)')
assert !mi(`e(smape)')
assert !mi(`e(metric)')
assert !mi(`e(xv)')

// Simple test with k-fold cv
xv .8, metric(mse) pstub(pred) monitors(rmse huber phl mae mape smape)		 ///   
kfold(4) display: reg price mpg i.foreign

// Create a test case for mixed effects models
webuse nlswork.dta, clear

// Use clustered sampling when creating the splits aligned with the modeling
xv 0.8, metric(msle) pstub(p) uid(id) display retain split(mixsplit):		 ///   
mixed ln_w grade age c.age#c.age ttl_exp tenure c.tenure#c.tenure || id:

// Summarize the predicted values
su p

// Create a testcase for logit
webuse lbw.dta, clear

// Use some monitors as well
xv 0.6, metric(acc) pstub(p) display retain split(logsplit2)				 ///   
monitors(sens recall spec prev ppv npv bacc mcc f1 jindex) classes(2):		 ///   
logit low age lwt i.race smoke ptl ht ui

// Tabulate the predicted values
ta p

// Load data for multiclass classification
webuse sysdsn1.dta, clear

// Create a testcase for multiclass logit
xv 0.6, metric(mcacc) pstub(p) display classes(3) retain split(	csplit)		 ///   
monitors(mcsens mcprec mcspec mcppv mcnpv mcbacc mcmcc mcf1 mcjindex 		 ///   
mcdetect mckappa): mlogit insure age male nonwhite i.site

// Tabulate the predicted values
ta p

// Load dataset for ologit example
webuse fullauto.dta, clear

// Simple test case
xv 0.6, metric(mcacc) pstub(p) display classes(5) retain split(mcsplit)		 ///   
monitors(mcsens mcprec mcspec mcppv mcnpv mcbacc mcmcc mcf1 mcjindex		 ///   
mcdetect mckappa): ologit rep77 foreign length mpg

// Tabulate the predicted values
ta p

// Load dataset for ivregress example
webuse hsng2.dta, clear

// Simple TT split case
xv 0.8, metric(msle) pstub(p) display retain monitors(mse rmse mae bias mbe  ///   
r2 mape smape rmsle rpd iic ccc huber phl rpiq r2ss) split(ivsplit):         ///   
ivregress 2sls rent pcturban (hsngval = faminc i.region), small
  
// Summarize predicted outcome
su p

// Load dataset for poisson example
webuse epilepsy.dta, clear

// Simple TT split case
xv 0.6, metric(pll) pstub(p) display retain monitors(mse rmse mae bias mbe   ///   
r2 mape smape msle rmsle rpd iic ccc huber phl rpiq r2ss) split(poisplit) 	 ///   
pmethod(n): poisson seizures treat lbas lbas_trt lage v4

// Summarize the prediced outcomes
su p

