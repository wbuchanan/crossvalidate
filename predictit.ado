/*******************************************************************************
*                                                                              *
*             Handles predicting the models and returning results              *
*                                                                              *
*******************************************************************************/

*! predictit
*! v 0.0.3
*! 15FEB2024

// Drop program from memory if already loaded
cap prog drop predictit

// Define program
prog def predictit

	// Version statement 
	version 18
	
	// Syntax
	syntax [anything(name = cmd id="estimation command name")],				 ///   
			PStub(string asis) [ SPLit(varname)  Classes(integer 0) 		 ///   
			Kfold(integer 1) THReshold(passthru) MODifin(string asis) 		 ///   
			KFIfin(string asis) noall PMethod(string asis)]

	// Test the value of the classes option
	if `classes' < 0 {
		
		// Display an error message
		di as err "The classes option requires a value >= 0."
		
		// Return an error code
		err 125
		
	} // End IF Block for negative valued class arguments
			
	// For linear model cases use xb as the default prediction method
	if `classes' == 0 & mi(`"`pmethod'"') loc pmethod xb
	
	// For categorical model cases use pr as the default prediction method
	else if `classes' > 0 & mi(`"`pmethod'"') loc pmethod pr
			
	// Test if the user passed of the necesary info for this to work
	if mi(`"`cmd'"') & mi(`"`modifin'"') & mi(`"`: char _dta[predifin]'"') {
		
		// Display error message
		di as err "You must provide either the estimation command string "	 ///
		"or pass an argument to modifin to use this command if "			 ///   
		"{help cmdmod} was not called previously, or the characteristics "	 ///    
		"created by {help cmdmod} were removed."
		
		// Return an error code and exit
		err 197
		
	} // End IF Block for insufficient information for the command	 
				 
	// If the user passes a command string 
	if !mi(`"`cmd'"') {
		
		// Make sure a split variable is passed
		if mi("`split'") {
		
			// Display an error message
			di as err "If you pass a command string as the first argument "	 ///   
			"you must also specify the variable that identifies the " 		 ///   
			"variable with the split group identifiers."
			
			// Return an error code and exit
			err 198
			
		} // End IF Block for insufficient options with command string.
		
		// If there is something passed to split confirm it exists
		else confirm v `split'
		
		// If modded if expression in characteristic use it
		if !mi(`"`: char _dta[predifin]'"') loc modifin : char _dta[predifin]
		
		// Otherwise
		else {
			
			// Generate the modified if expressions for predictions
			cmdmod `cmd', split(`split') kf(`kfold')
		
			// Then substitute the individual split case to modifin
			loc modifin `r(predifin)'
			
			// And substitute the K-Fold case for the entire training set
			loc kfifin `r(kfpredifin)'
			
		} // End ELSE Block for missing dataset characteristics
		
		// If modded k-fold if expression in characteristic use it
		if !mi(`"`: char _dta[kfpredifin]'"') loc kfifin : char _dta[kfpredifin]
		
	} // End IF Block for cases where the user passes the command string
			
	// Handles predictting for KFold and non-KFold CV
	forv k = 1/`kfold' {
		
		// Check to verify that the modified if expression ends with a numeric 
		// value and if it is missing a numeric value at the iterator
		if !ustrregexm(`"`modifin'"', "\d\$") loc modifin `modifin' \`k'
		
		// Stores the estimation results in a more persistent way
		est restore *`k'
		
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'`k' `modifin', `pmethod'
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' `modifin', `threshold' ps(`pstub'`k')
				
		} // End ELSE Block for classifcation tasks
		
	} // Loop over the KFolds
	
	// Create the combined variable as a double for continuous outcomes
	if `classes' == 0 qui: egen double `pstub' = rowfirst(`pstub'*)
	
	// For classification models
	else qui: egen byte `pstub' = rowfirst(`pstub'*)

	// Attach a variable label to the predicted variable
	la var `pstub' "Predicted value of `e(depvar)'"
	
	// Test if K-Fold cross validation is being used and the user wants the 
	// predicted values based on the entire training set.
	if `kfold' > 1 & mi("`all'") {
		
		// Stores the estimation results in a more persistent way
		cap: est restore *all
		
		// If the estimation on all the training data is not done
		if _rc != 0 {
			
			// Remove all the predicted value variables
			drop `pstub'* `pstub'
			
			// Display an error message
			di as err "If {help fitit} was called without the noall option " ///   
			"predictit must also use that option."
			
			// Throw an error code
			err 198
			
		} // End IF Block for all training sample prediction w/o all sample fit
		
		est restore *all
		
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'all `kfifin', `pmethod'
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' `kfifin', `threshold' ps(`pstub'all)
				
		} // End ELSE Block for classifcation tasks
		
		// Add variable label for the all training set case
		la var `pstub'all "Predicted value of `e(depvar)' from model w/full training set"

	} // End IF Block for K-Fold CV predictting to all training data
	
	// Loop over the K-Folds
	forv k = 1/`kfold' {
		
		// Drop any predicted value variables that are intermediate in nature
		qui: drop `pstub'`k'
		
	} // End of Loop to clean up the data set
		
// End definition of the command
end



