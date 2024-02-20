cscript "model fitting phase for cross-validation" adofile fitit

// Load some example data
sysuse auto.dta, clear

// Case with no splits

// Create indicator for "splitting"
g byte splitvar = 1

// Make sure the mata library is loaded
run crossvalidate.mata

// Test invalid number of k-folds
rcof `"fitit "reg price mpg", res(tst) spl(splitvar) kf(-1)"' == 198

// Test invalid results option
rcof `"fitit "reg price mpg", res(tst2) spl(splitvar)"' == 198

// call fitit with a single fold
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) 

// Save the stored results
storedresults save fitit1 e()

// Fit the model to the data directly
reg price mpg i.foreign headroom trunk, vce(rob)

// Compare the results
storedresults compare fitit1 e(), ex(macro: predifin kfpredifin estres1 	 ///   
estresnames estimates_title cmdline) tol(1e-10)

// Drop the split variable
drop splitvar

// expand the data to make a simple K-Fold case where each fold will have the 
// same coefficient and so should the all training set case
expand 6

// Create the split indicator
bys make: g byte splitvar = _n

// call fitit with 5 folds
fitit "reg price mpg i.foreign i.rep78 headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) noall kf(5)

// Store the results
storedresults save fitit2 e()

// Check macros added by fitit
assert "`e(estresnames)'" == " tst1 tst2 tst3 tst4 tst5"
assert "`e(estres1)'" == "tst1"
assert "`e(estres2)'" == "tst2"
assert "`e(estres3)'" == "tst3"
assert "`e(estres4)'" == "tst4"
assert "`e(estres5)'" == "tst5"
assert "`e(predifin)'" == "if !e(sample) & splitvar =="
assert "`e(kfpredifin)'" == "if !e(sample) & splitvar == 6" 
assert "`e(estimates_title)'" == "Model fit on Fold #5"

// Fit the model to the data directly for the same sample that the last 
// estimates used
reg price mpg i.foreign i.rep78 headroom trunk if splitvar != 5, vce(rob)

// Compare the results
storedresults compare fitit2 e(), ex(macro: predifin kfpredifin estres1 	 ///   
estres2 estres3 estres4 estres5 estresnames estimates_title cmdline) tol(1e-10)


// call fitit with 5 K-Folds and estimating the model on all of the training set
fitit "reg price mpg i.foreign i.rep78 headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) kf(5)

// Store the results
storedresults save fitit3 e()

// Check macros added by fitit
assert "`e(estresnames)'" == " tst1 tst2 tst3 tst4 tst5 tstall"
assert "`e(estresall)'" == "tstall"
assert "`e(estres1)'" == "tst1"
assert "`e(estres2)'" == "tst2"
assert "`e(estres3)'" == "tst3"
assert "`e(estres4)'" == "tst4"
assert "`e(estres5)'" == "tst5"
assert "`e(predifin)'" == "if !e(sample) & splitvar =="
assert "`e(kfpredifin)'" == "if !e(sample) & splitvar == 6" 
assert "`e(estimates_title)'" == "Model Fitted on All Training Folds"

// Fit the model to the data directly for the entire training set
reg price mpg i.foreign i.rep78 headroom trunk if splitvar <= 5, vce(rob)

// Compare the results
storedresults compare fitit3 e(), ex(macro: predifin kfpredifin estres1 	 ///   
estres2 estres3 estres4 estres5 estresnames estresall estimates_title 		 ///   
cmdline) tol(1e-10)

