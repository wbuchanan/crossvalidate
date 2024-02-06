/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! fitit
*! v 0.0.3
*! 05FEB2024

// Drop program from memory if already loaded
cap prog drop fitit

// Define program
prog def fitit, eclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = cmd id="estimation command name"),				 ///   
			PStub(string asis) SPLit(passthru) RESults(string asis) 		 ///   
			[ Classes(integer 0) Kfold(integer 1) THReshold(passthru) ]
			
	// Create a macro to store the names of all the estimation results
	loc estres 
	
	// Call the command to generate the modified estimation command string
	cmdmod `cmd', `split' kf(`kfold')
			
	// Handles fitting for KFold and non-KFold CV
	forv i = 1/`kfold' {
		
		// Call the estimation command passed by the user
		`r(modcmd)'
				
		// Add a title for standard cases
		if `kfold' == 1 est title: Model Fit on Training Sample
		
		// Add a title for K-Fold cases
		else est title: Model fit on Fold #`i'
		
		// Stores the estimation results in a more persistent way
		est sto `results'`i'
		
		// Return the estimation result name in a macro
		eret loc estres`i' "`results'`i'"
		
		// Add the name of the estimation results to the estres macro
		loc estres "`estres' `results'`i'"
			
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'`i' `r(predifin)'
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' `r(predifin)', `threshold' ps(`pstub'`i')
				
		} // End ELSE Block for classifcation tasks
		
	} // Loop over the KFolds

	// Attach a variable label to the predicted variable
	la var `pstub' "Predicted value of `e(depvar)'"
	
	// Test if K-Fold cross validation is being used
	if `kfold' > 1 {
		
		// Fit the model to all the training data
		`r(kfmodcmd)'
		
		// Test if user wants title added
		est title: Model Fitted on All Training Folds 
		
		// Stores the estimation results in a more persistent way
		est sto `results'all
		
		// Return the estimation result name in a macro
		eret loc estresall "`results'all"
		
		// Add the name of the estimation results to the estres macro
		loc estres "`estres' `results'all"

		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'all `r(predifin)'
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' `r(predifin)', `threshold' ps(`pstub'all)
				
		} // End ELSE Block for classifcation tasks
		
		// Add variable label for the all training set case
		la var `pstub'all "Predicted value of `e(depvar)' from model w/full training set"

	} // End IF Block for K-Fold CV fitting to all training data
	
	// Return the predict macro 
	eret loc predifin `r(predifin)'
	
	// Return the predict macro for the K-Fold case on all training data
	eret loc kfpredifin `r(kfpredifin)'
	
	// Return the names of all the stored estimation results
	eret loc estresnames "`estres'"
	
	// Repost the estimation results to return them to users
	ereturn repost
	
// End definition of the command
end



