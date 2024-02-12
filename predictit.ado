/*******************************************************************************
*                                                                              *
*             Handles predicting the models and returning results              *
*                                                                              *
*******************************************************************************/

*! predictit
*! v 0.0.1
*! 09FEB2024

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
			KFIfin(string asis) noall ]

	// Test if the user passed of the necesary info for this to work
	if mi(`cmd') & mi(`"`modifin'"') {
		
		// Display error message
		di as err "You must provide either the estimation command string "	 ///
		"or pass an argument to modifin to use this command"
		
		// Return an error code and exit
		err
		
	} // End IF Block for insufficient information for the command	 
				 
	// If the user passes a command string 
	if !mi(`cmd') {
		
		// Make sure a split variable is passed
		if mi("`split'") {
		
			// Display an error message
			di as err "If you pass a command string as the first argument "	 ///   
			"you must also specify the variable that identifies the " 		 ///   
			"variable with the split group identifiers."
			
			// Return an error code and exit
			err 
			
		} // End IF Block for insufficient options with command string.
		
		// If there is something passed to split confirm it exists
		else confirm v `split'
		
		// Generate the modified if expressions for predictions
		cmdmod `cmd', split(`split') kf(`kfold')
		
		// Then substitute the individual split case to modifin
		loc modifin "`macval(r(predifin))'"
		
		// And substitute the K-Fold case for the entire training set
		loc kfifin "`macval(r(kfpredifin))'"
		
	} // End IF Block for cases where the user passes the command string
			
	// Handles predictting for KFold and non-KFold CV
	forv i = 1/`kfold' {
		
		// Stores the estimation results in a more persistent way
		qui: est restore *`i'
		
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'`i' `modifin'
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' `modifin', `threshold' ps(`pstub'`i')
				
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
		est restore *all
		
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'all `kfifin'
			
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
	forv i = 1/`kfold' {
		
		// Drop any predicted value variables that are intermediate in nature
		qui: drop `pstub'`i'
		
	} // End of Loop to clean up the data set
		
// End definition of the command
end



