cscript "prediction phase for cross-validation" adofile predictit

// Load some example data
sysuse auto.dta, clear

// Case with no splits

// Create indicator for "splitting"
g byte splitvar = 1

// Make sure the mata library is loaded
run crossvalidate.mata

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) 

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", 		 ///   
ps(pred) spl(splitvar) 

// Fit the model manually
reg price mpg i.foreign headroom trunk, vce(rob)

// Generate manual prediction
predict double mpred

// Assert the predicted values are the same
assert pred == mpred

// drop splitvar and predicted value variables
drop splitvar pred

// expand the data to make a simple K-Fold case where each fold will have the 
// same coefficient and so should the all training set case
expand 6

// Create the split indicator
bys make: g byte splitvar = _n

// call fitit for 5 folds
fitit "reg price mpg i.foreign headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) kfold(5)

// Called with estimation command for K-Fold case without fitting to entire 
// training split
predictit "reg price mpg i.foreign headroom trunk, vce(rob)", 		 ///   
ps(pred) spl(splitvar) kf(5) noall

// Assert the values are the same
assert abs(pred - mpred) <= 1e-10 if !mi(pred, mpred)
