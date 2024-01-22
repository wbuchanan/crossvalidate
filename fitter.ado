/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! fitter
*! v 0.0.1
*! 08DEC2023

// Drop program from memory if already loaded
cap prog drop fitter

// Define program
prog def fitter, eclass properties(kfold)

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = cmd id="estimation command name"),				 ///   
			PStub(string asis)	[ Classes(integer 0) RESults(string asis) 	 ///   
			Kfold(integer 1) RESTItle(string asis) THReshold(passthru) ]
	
	// Handles fitting for KFold and non-KFold CV
	forv i = 1/`kfold' {
		
		// Get the if/in statement from the estimation command
		// modify to fit only on the training sample
		// generate a second modification that only includes validation sample
		
		
		// Call the estimation command passed by the user
		`cmd'
				
		// Check if results should be stored
		if `"`results'"' != "" {
			
			// Stores the estimation results in a more persistent way
			est sto `results'`i'
			
			// Test if user wants title added
			if !mi(`"`restitle'"') est title: `restitle' 
			
		} // End of IF Block for persistent storage of estimation results
		
		// Test whether this is a "regression" task
		if `classes' == 0 {
			
			// If it is, predict on the validation sample:
			predict double `pstub'`i' // Need to handle the if statement here
			
		} // End IF Block for "regression" tasks
		
		// Otherwise
		else {
			
			// Call the classification program
			// Also need to handle the if statement here as well
			classify `classes' if ..., `threshold' ps(`pstub'`i')
				
		} // End ELSE Block for classifcation tasks
		
	} // Loop over the KFolds
	
	// For regression tasks use double precision for the predictions
	if `classes' == 0 egen double `pstub' = rowfirst(`pstub'*)
	
	// For classification tasks use a byte
	else egen byte `pstub' = rowfirst(`pstub'*)
	
	// Attach a variable label to the predicted variable
	la var `pstub' "Predicted value of `e(depvar)'"
	
	// Repost the estimation results to return them to users
	ereturn repost
	
// End definition of the command
end



