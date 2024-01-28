cscript "classification prediction and data management" adofile classify

/*******************************************************************************
*                                                                              *
*                  Binary Logistic Regression Tests Start Here                 *
*                                                                              *
*******************************************************************************/

// Load example data set
webuse lbw, clear

// Fit the example logistic regression model 
logit low age lwt i.race smoke ptl ht ui

// Predict low using classify 
classify 2, ps(pred)

// Predict the values manually
predict double newvar, pr

// Replace newvar based on default threshold of 0.5
replace newvar = cond(newvar <= 0.5, 0, cond(newvar > 0.5, 1, .))

// Compress newvar
compress newvar

// Test that the predictions are equal
assert pred == newvar

// Drop the variables pred and newvar
drop pred newvar

// Refit the model
logit low age lwt i.race smoke ptl ht ui

// Predict low using classify 
classify 2, ps(pred) thr(0.75)

// Predict the values manually
predict double newvar, pr

// Replace newvar based on default threshold of 0.5
replace newvar = cond(newvar <= 0.75, 0, cond(newvar > 0.75, 1, .))

// Compress newvar
compress newvar

// Test that the predictions are equal
assert pred == newvar

// Drop the variables pred and newvar
drop pred newvar

/*******************************************************************************
*                                                                              *
*                  Ordered Logistic Regression Tests Start Here                *
*                                                                              *
*******************************************************************************/

// Load example dataset
webuse fullauto, clear

// Fit the example model from the manual
ologit rep77 foreign length mpg

// Get the number of outcome classes
qui: ta rep77

// Use classify to generate the predicted classes
classify r(r), ps(pred)

// Manually predict the class probabilities
predict double pvars*, pr

// Get the name of the predicted variables
qui: ds pvars*

// Store the name of these variables
loc pvars `r(varlist)'

// Get the value with the highest probability for each record
egen double pstub = rowmax(`pvars')

// Manually code the changes for pstub
replace pstub = cond(pstub == pvars1, 1, cond(pstub == pvars2, 2,			 ///   
				cond(pstub == pvars3, 3, cond(pstub == pvars4, 4,			 ///   
				cond(pstub == pvars5, 5, .)))))
				
// Compress the values of pstub
compress pstub

// Ensure the values match what classify produced
assert pstub == pred
				
/*******************************************************************************
*                                                                              *
*              Multinomial Logistic Regression Tests Start Here                *
*                                                                              *
*******************************************************************************/

// Load example dataset
webuse sysdsn1, clear

// Fit the model to the data
mlogit insure age male nonwhite i.site

// Get the number of outcome classes
qui: ta insure

// Use classify to generate the predicted classes
classify r(r), ps(pred)

// Manually predict the class probabilities
predict double pvars*, pr

// Get the name of the predicted variables
qui: ds pvars*

// Store the name of these variables
loc pvars `r(varlist)'

// Get the value with the highest probability for each record
egen double pstub = rowmax(`pvars')

// Manually code the changes for pstub
replace pstub = cond(pstub == pvars1, 1, cond(pstub == pvars2, 2,			 ///   
				cond(pstub == pvars3, 3, .)))
				
// Compress the values of pstub
compress pstub

// Ensure the values match what classify produced
assert pstub == pred

