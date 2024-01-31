cscript "command modification for cross-validation" adofile cmdmod

// Create a single observation
set obs 1

// Generate a split variable 
// Since the split option requires a variable name to be passed, we need a 
// variable with that name to exist in memory when calling the program
g byte spvar = 1

// Load all the mata functions for crossvalidate
run crossvalidate.mata




// Instance with no if/in expression or options for a train/test split
cmdmod "ivreg price (mpg i.foreign)", spl(spvar) 

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if spvar == 1" 

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if !e(sample) & spvar == 2" 





// Instance with no if/in expression or options for 5-fold CV
cmdmod "ivreg price (mpg i.foreign)", spl(spvar) kf(5)

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if spvar != `i'" 

// Test the modified command for kfold cv
assert `"`r(kfmodcmd)'"' == "ivreg price (mpg i.foreign) if spvar <= 5"

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if !e(sample) & spvar == `i'" 

// Test the if statement for the overall model fitting after the k-folds
assert `"`r(kfpredifin)'"' == " if !e(sample) & spvar == 6" 





// Instance with no if/in expression and options for a train/test split
cmdmod "ivreg price (mpg i.foreign), vce(rob)", spl(spvar) 

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if spvar == 1, vce(rob)" 

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if !e(sample) & spvar == 2" 





// Instance with no if/in expression and options for 5-fold CV
cmdmod "ivreg price (mpg i.foreign), vce(rob)", spl(spvar) kf(5)

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if spvar != `i', vce(rob)" 

// Test the modified command for kfold cv
assert `"`r(kfmodcmd)'"' == "ivreg price (mpg i.foreign) if spvar <= 5, vce(rob)"

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if !e(sample) & spvar == `i'" 

// Test the if statement for the overall model fitting after the k-folds
assert `"`r(kfpredifin)'"' == " if !e(sample) & spvar == 6" 





// Instance with an if/in expression and no options for a train/test split
cmdmod "ivreg price (mpg i.foreign) if rep78 == 2", spl(spvar) 

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar == 1" 

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if rep78 == 2 & !e(sample) & spvar == 2" 





// Instance with no if/in expression or options for 5-fold CV
cmdmod "ivreg price (mpg i.foreign) if rep78 == 2", spl(spvar) kf(5)

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar != `i'" 

// Test the modified command for kfold cv
assert `"`r(kfmodcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar <= 5"

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if rep78 == 2 & !e(sample) & spvar == `i'" 

// Test the if statement for the overall model fitting after the k-folds
assert `"`r(kfpredifin)'"' == " if rep78 == 2 & !e(sample) & spvar == 6" 





// Instance with an if/in expression and options for a train/test split
cmdmod "ivreg price (mpg i.foreign) if rep78 == 2, vce(rob)", spl(spvar) 

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar == 1, vce(rob)" 

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if rep78 == 2 & !e(sample) & spvar == 2" 





// Instance with an if/in expression and options for 5-fold CV
cmdmod "ivreg price (mpg i.foreign) if rep78 == 2, vce(rob)", spl(spvar) kf(5)

// Test the modified command
assert `"`r(modcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar != `i', vce(rob)" 

// Test the modified command for kfold cv
assert `"`r(kfmodcmd)'"' == "ivreg price (mpg i.foreign) if rep78 == 2 & spvar <= 5, vce(rob)"

// Test the if statement for prediction
assert `"`r(predifin)'"' == " if rep78 == 2 & !e(sample) & spvar == `i'" 

// Test the if statement for the overall model fitting after the k-folds
assert `"`r(kfpredifin)'"' == " if rep78 == 2 & !e(sample) & spvar == 6" 
