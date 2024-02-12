/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! fitit
*! v 0.0.5
*! 12FEB2024

// Drop program from memory if already loaded
cap prog drop fitit

// Define program
prog def fitit, eclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = cmd id="estimation command name"),				 ///   
			SPLit(passthru) RESults(string asis) [ KFold(integer 1) noall ]
			
	// Create a macro to store the names of all the estimation results
	loc estres 
	
	// Call the command to generate the modified estimation command string
	cmdmod `cmd', `split' kf(`kfold')
	
	// Stores the returned modified prediction if expression so it can be 
	// returned by fitit
	loc predifin `r(predifin)'
	
	// Does the same with the macro used for the all training set component when
	// used with K-Fold CV
	loc kfpredifin `r(kfpredifin)'

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
			
	} // Loop over the KFolds

	// Test if K-Fold cross validation is being used
	if `kfold' > 1 & mi(`"`all'"') {
		
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

	} // End IF Block for K-Fold CV fitting to all training data
	
	// Return the names of all the stored estimation results
	eret loc estresnames "`estres'"
	
	// Return the predict macro 
	eret loc predifin `macval(predifin)'
	
	// Return the predict macro for the K-Fold case on all training data
	eret loc kfpredifin `macval(kfpredifin)'
		
	// Repost the estimation results to return them to users
	ereturn repost
	
// End definition of the command
end



