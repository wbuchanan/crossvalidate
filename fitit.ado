/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! fitit
*! v 0.0.6
*! 19FEB2024

// Drop program from memory if already loaded
cap prog drop fitit

// Define program
prog def fitit, eclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = cmd id="estimation command name"),				 ///   
			SPLit(passthru) RESults(string asis) [ KFold(integer 1) noall 	 ///   
			DISplay]

	// Test for invalid KFold option
	if `kfold' < 1 {
		
		// Display an error message
		di as err "There must always be at least 1 K-Fold.  This would be "	 ///   
		"the training set in a simple train/test split.  You specified "	 ///   
		"`kfold' K-Folds."
		
		// Return error code and exit
		err 198
		
	} // End IF Block for invalid K-Fold argument
	
	// Test whether the results option conforms to requirements to end with a 
	// letter
	if ustrregexm("`results'", "\d\$") {
		
		// Display error message
		di as err "The argument passed to results ends in a number.  The "	 ///   
		"last character must not be a number for this option."
		
		// Return error code
		err 198
		
	} // End IF Block for invalid results option
	
	// If the user does not request results be displayed
	if mi("`display'") loc q "qui:"
					
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
	forv k = 1/`kfold' {
		
		// Call the estimation command passed by the user
		if !mi(`"`: char _dta[modcmd]'"') `q'`: char _dta[modcmd]'
		
		// Otherwise call the returned macro from cmdmod
		else `q'`r(modcmd)'
		
		// Add a title for standard cases
		if `kfold' == 1 est title: Model Fit on Training Sample
		
		// Add a title for K-Fold cases
		else est title: Model fit on Fold #`k'
		
		// Stores the estimation results in a more persistent way
		est sto `results'`k'
		
		// Return the estimation result name in a macro
		loc estres`k' "`results'`k'"
		
		// Add the name of the estimation results to the estres macro
		loc estres "`estres' `results'`k'"
			
	} // Loop over the KFolds

	// Test if K-Fold cross validation is being used
	if `kfold' > 1 & mi(`"`all'"') {
		
		// If the dataset characteristic is not missing
		if !mi(`"`: char _dta[kfmodcmd]'"') {
			
			// Call the estimation command stored in the characteristic
			`q'`: char _dta[kfmodcmd]'
		
		} // End IF Block for estimation command in characteristic
		
		// Otherwise, use the returned result from cmdmod
		else `q'`r(kfmodcmd)'
		
		// Test if user wants title added
		est title: Model Fitted on All Training Folds 
		
		// Stores the estimation results in a more persistent way
		est sto `results'all
		
		// Return the estimation result name in a macro
		eret loc estresall "`results'all"
		
		// Add the name of the estimation results to the estres macro
		loc estres "`estres' `results'all"

	} // End IF Block for K-Fold CV fitting to all training data
	
	// Loop over the kfolds to return the individual stored result names
	forv k = 1/`kfold' {
		
		// Returns the individual estimation result names in their own macros
		eret loc estres`k' "`estres`k''"
		
	} // End Loop over the K-Folds to return the estimation result names
	
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



