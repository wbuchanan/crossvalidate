cscript "validation phase for cross-validation" adofile validateit

/*******************************************************************************
* The goal for all of these tests is solely to ensure that the results from    *
* the underlying metric functions are being returned in the expected locations *
* and NOT to verify the accuracy of the metrics.  Those tests should all       *
* appear in the tests related to libxv since that's where those functions are  *
* defined.                                                                     *
*******************************************************************************/

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

// call fitit 
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) spl(splitvar) 

// Called with estimation command 
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred)		 ///   
spl(splitvar) 

// Test error case when metric is included in monitors
rcof "validateit, me(mae) ps(pred) mo(rmse mae) split(splitvar)" == 134

// Test error case when there are multiple metrics specified
rcof "validateit, me(mse pll) ps(pred) mo(rmse mae) split(splitvar)" == 134

// Drop the stored estimates
estimates clear
eret clear

// Test error case when e(depvar) is not found and no value is passed to obs
rcof "validateit, me(mse) ps(pred) mo(rmse mae) split(splitvar)" == 100

// Verify it works if the varname is passed to obs
validateit, me(mse) ps(pred) mo(rmse mae) split(splitvar) o(price)

// Ensure that the returned scalar for the metric alone is not contained in a 
// samenamed scalar
assert mi("`r(mse)'")

// Ensure that there is a scalar with a value named metric
assert !mi(`r(metric)')

// drop the predicted variable and start fresh
drop pred

// call fitit 
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) spl(splitvar) 

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred)		 ///   
spl(splitvar) 

// Issue the minimum valid command
validateit, me(mse) ps(pred) spl(splitvar)

// Ensure that the returned scalar for the metric alone is not contained in a 
// samenamed scalar
assert mi("`r(mse)'")

// Ensure that there is a scalar with a value named metric
assert !mi(`r(metric)')

// Issue the command with some monitors included
validateit, me(mse) ps(pred) spl(splitvar) mo(mape smape mae bias rmse mbe 	 ///   
r2 msle rmsle rpd iic ccc huber phl rpiq r2ss)

// Ensure that there is a scalar with a value named metric
assert !mi(`r(metric)')

// Ensure all of the monitors are present
assert !mi(`r(mape)')
assert !mi(`r(smape)')
assert !mi(`r(mae)')
assert !mi(`r(bias)')
assert !mi(`r(rmse)')
assert !mi(`r(mbe)')
assert !mi(`r(r2)')
assert !mi(`r(msle)')
assert !mi(`r(rmsle)')
assert !mi(`r(rpd)')
assert !mi(`r(iic)')
assert !mi(`r(ccc)')
assert !mi(`r(huber)')
assert !mi(`r(phl)')
assert !mi(`r(rpiq)')
assert !mi(`r(r2ss)')

**# K-Fold TT Splits
/*******************************************************************************
*                                                                              *
*                          K-Fold Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Load some example data
sysuse auto.dta, clear

// Duplicate the dataset once
expand 6

// Create indicator for "splitting"
bys make: g byte splitvar = _n

// call fitit w/o fitting to entire training set
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) kf(5)	 ///   
spl(splitvar) noall

// Called with estimation command for the K-Fold hold-out sets only 
// (not the validation/test set when the noall option is not included)
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred) kf(5) ///   
spl(splitvar) noall

// Issue the command to trigger error for no `pred'all variable w/K-Fold and 
// no corresponding noall option
rcof "validateit, me(mse) ps(pred) spl(splitvar) kf(5)" == 111

// Now call the command with the noall option
validateit, me(mse) ps(pred) spl(splitvar) kf(5) noall

// Ensure that the returned scalar for the metric alone is not contained in a 
// samenamed scalar
assert mi("`r(mse)'")

// Ensure that there is not a scalar with a value named metric
assert mi("`r(metric)'")

// Ensure there are 5 metrics named and not 5 r(mse) scalars named
assert !mi(`r(metric1)')
assert !mi(`r(metric2)')
assert !mi(`r(metric3)')
assert !mi(`r(metric4)')
assert !mi(`r(metric5)')
assert mi("`r(mse1)'")
assert mi("`r(mse2)'")
assert mi("`r(mse3)'")
assert mi("`r(mse4)'")
assert mi("`r(mse5)'")

// Load some example data
sysuse auto.dta, clear

// Duplicate the dataset once
expand 6

// Create indicator for "splitting"
bys make: g byte splitvar = _n

// call fitit w/fitting to entire training set
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) kf(5)	 ///   
spl(splitvar) 

// Called with estimation command for the K-Fold hold-out sets and all training
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred) kf(5) ///   
spl(splitvar) 

// Now call the command w/o the noall option
validateit, me(mse) ps(pred) spl(splitvar) kf(5) 

// Ensure that the returned scalar for the metric alone is not contained in a 
// samenamed scalar
assert mi("`r(mse)'")

// Ensure that there is not a scalar with a value named metric
assert mi("`r(metric)'")

// Ensure there are 5 metrics named and not 5 r(mse) scalars named
assert !mi(`r(metric1)')
assert !mi(`r(metric2)')
assert !mi(`r(metric3)')
assert !mi(`r(metric4)')
assert !mi(`r(metric5)')
assert !mi(`r(metricall)')
assert mi("`r(mse1)'")
assert mi("`r(mse2)'")
assert mi("`r(mse3)'")
assert mi("`r(mse4)'")
assert mi("`r(mse5)'")
assert mi("`r(mseall)'")



