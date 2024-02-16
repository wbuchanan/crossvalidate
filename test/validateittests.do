cscript "validation phase for cross-validation" adofile validateit

**# TT Splits
/*******************************************************************************
*                                                                              *
*                          Simple Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Load some example data
sysuse auto.dta, clear

// Duplicate the dataset once
expand 2

// Create indicator for "splitting"
bys make: g byte splitvar = _n

// Make sure the mata library is loaded
run crossvalidate.mata

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 			 ///   
spl(splitvar) 

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred)		 ///   
spl(splitvar) 

// Test error case when metric is included in monitors
rcof "validateit, me(mae) p(pred) mo(rmse mae) split(splitvar)" == 134

// Test error case when there are multiple metrics specified
rcof "validateit, me(mse pll) p(pred) mo(rmse mae) split(splitvar)" == 134

// Drop the stored estimates
estimates clear

// Test error case when e(depvar) is not found and no value is passed to obs
rcof "validateit, me(mse pll) p(pred) mo(rmse mae) split(splitvar)" == 100

// drop the predicted variable and start fresh
drop pred

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 			 ///   
spl(splitvar) 

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred)		 ///   
spl(splitvar) 

// Issue the minimum valid command
validateit, me(mse) p(pred) spl(splitvar)

// Ensure that there is a scalar with a value named mse
assert !mi(`r(mse)')

