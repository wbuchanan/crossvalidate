cscript "model fitting phase for cross-validation" adofile fitit

// Load some example data
sysuse auto.dta, clear

// expand the data to make a simple K-Fold case where each fold will have the 
// same coefficient and so should the all training set case
expand 6

// Create the split indicator
bys make: g byte splitvar = _n

// call fitit
fitit "reg price mpg i.foreign i.rep78 headroom trunk, vce(rob)", res(tst) 	 ///   
spl(splitvar) noall
