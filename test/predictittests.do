cscript "prediction phase for cross-validation" adofile predictit

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

// Test invalid number of k-folds
rcof `"predictit "reg price mpg", ps(pred) spl(splitvar) kf(-1)"' == 198

// Test error if no estimation command and no value passed to modifin
rcof "predictit, ps(pred) spl(splitvar)" == 197

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 			 ///   
spl(splitvar) 

// Test error if estimation command passed without split variable
rcof `"predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(p)"' == 198

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", ps(pred)		 ///   
spl(splitvar) 

// Fit the model manually
reg price mpg i.foreign headroom trunk if splitvar == 1, vce(rob)

// Generate manual prediction
predict double mpred if !e(sample) & splitvar == 2

// Assert the predicted values are the same
assert pred == mpred


**# TVT Splits
/*******************************************************************************
*                                                                              *
*                    Simple Train/Validate/Test Split Case                     *
*                                                                              *
*******************************************************************************/

// Load some example data
sysuse auto.dta, clear

// expand the data to make a simple K-Fold case where each fold will have the 
// same coefficient and so should the all training set case
expand 3

// Create the split indicator
bys make: g byte splitvar = _n

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) 

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", 		 ///   
ps(pred) spl(splitvar) 

// Fit the model manually
reg price mpg i.foreign headroom trunk if splitvar == 1, vce(rob)

// Generate manual prediction
predict double mpred if !e(sample) & splitvar == 2

// Assert the predicted values are the same
assert pred == mpred

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

// call fitit for 5 folds without fitting to full training set
fitit "reg price mpg, vce(rob)", res(tst) spl(splitvar) noall kf(5)

// Called with estimation command for K-Fold case without fitting to entire 
// training split
rcof `"predictit "reg price mpg, vce(rob)", ps(pred) kf(5) spl(splitvar)"' == 198

predictit "reg price mpg, vce(rob)", ps(pred) kf(5) noall spl(splitvar)

// Fit the model manually
reg price mpg if splitvar != 5, vce(rob)

// Generate manual prediction
predict double mpred if !e(sample) & splitvar == 5

// Assert the predicted values are the same
assert pred == mpred if splitvar == 5

// Since this is all the same data generate another predicted value to test
predict double mpred2 if splitvar < 6

// Assert predicted values are the same across all splits
assert pred == mpred2

// Load some example data
sysuse auto.dta, clear

// Duplicate the dataset once
expand 6

// Create indicator for "splitting"
bys make: g byte splitvar = _n

// call fitit for 5 folds without fitting to full training set
fitit "reg price mpg, vce(rob)", res(tst) spl(splitvar) kf(5)

// Generate the predictions for each fold and for the case of fitting to the 
// entire training set
predictit "reg price mpg, vce(rob)", ps(pred) kf(5) spl(splitvar) 

// Fit the model manually
reg price mpg if splitvar != 5, vce(rob)

// Generate manual prediction
predict double mpred1 if !e(sample) & splitvar == 5

// Fit the model to all training data
reg price mpg if splitvar <= 5, vce(rob)

// Create manual prediction
predict double mpred2 if splitvar == 6

// test assertions
assert mpred1 == pred if splitvar == 5

assert mpred2 == predall if splitvar == 6



**# TVT Splits
/*******************************************************************************
*                                                                              *
*                          K-Fold Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Load some example data
sysuse auto.dta, clear

// expand the data to make a simple K-Fold case where each fold will have the 
// same coefficient and so should the all training set case
expand 7

// Create the split indicator
bys make: g byte splitvar = _n

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) kfold(5)

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", 		 ///   
ps(pred) spl(splitvar) kf(5)

// Fit the model manually
reg price mpg i.foreign headroom trunk if splitvar != 5, vce(rob)

// Generate manual prediction
predict double mpred if !e(sample) & splitvar == 5

// Assert the predicted values are the same
assert pred == mpred if splitvar == 5

// Fit the model manually
reg price mpg i.foreign headroom trunk if splitvar <= 5, vce(rob)

// Generate manual prediction
predict double mpred2 if !e(sample) & splitvar == 6

// Assert that the predict values from fitting to the entire training set are 
// the same
assert predall == mpred2
