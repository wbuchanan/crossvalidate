/*******************************************************************************
*                                                                              *
*             Handles string substitution needed to fit the model              *
*              to the appropriate subset of data during training               *
*                                                                              *
*******************************************************************************/

*! cmdmod
*! v 0.0.2
*! 03FEB2024

// Drop program from memory if already loaded
cap prog drop cmdmod

// Define this as a program that will return results in r() elements
prog def cmdmod, rclass

	// Version statement
	version 18

	// Defines the syntax for this program
	syntax anything(name = cmd id="estimation command"), 					 ///   
			SPLit(varlist min = 1 max = 1) [ KFold(integer 1) ]

	// This should all get refactored into a new program/function
	
	// Get any if/in statements
	mata: tosub = getifin(`cmd')
	
	// Test for no if/in statements
	if mi(`"`ifin'"') {
		
		// Gets the string from the cmd that will be used for substitution
		mata: tosub = getnoifin(`cmd')
		
		// Need to find first occurrence of a comma not enclosed in parentheses
		// That comma then needs to be replaced by an appropriate if statement
		// to fit the model to the subset of data for training
		// loc modifin if
		
		// For KFold CV cases
		if `kfold' > 1 {
			
			// For KFold CV use the loop iterator to ID the holdout sample to 
			// exclude from model fitting
			loc modifin " if `split' != \`k'"
			
			// Creates the new command string with the substituted value stored 
			// in the local cmdmod and a mata variable with the same name
			mata: cmdmod = subinstr(`cmd', tosub, tosub + "`macval(modifin)'")
			mata: st_local("cmdmod", cmdmod)

			// For KFold CV we'll use the loop iterator value to ID the holdout
			// sample for validation
			ret loc predifin " if !e(sample) & `split' == \`k'"
			
			// Also create a modified statement to fit the model to all training
			// data
			loc kfifin " if `split' <= `kfold'"
			
			// And do the same for the prediction
			ret loc kfpredifin " if !e(sample) & `split' == `= `kfold' + 1'"
			
			// Creates the modified command string for fitting all training data 
			// following the k-folds.
			mata: st_local("kfcmdmod",										 ///   
							subinstr(`cmd', tosub, tosub + "`kfifin'"))			
			
		} // End IF Block for KFold missing if/in statement cases
		
		// For non-KFold cases
		else {
			
			// Create the model if/in statement
			loc modifin " if `split' == 1"
			
			// For TT and TVT splits, use the validation sample group ID
			ret loc predifin " if !e(sample) & `split' == 2"

			// Creates the new command string with the substituted value stored 
			// in the local cmdmod
			mata: st_local("cmdmod", subinstr(`cmd', tosub, tosub + "`modifin'"))

		} // End ELSE Block for non-KFold cases w/o if/in statements
							
	} // End IF Block for no if or in statements in the estimation command
	
	// If there is an if or in statement in the estimation command
	else {
		
		// Create the modified if/in statements for KFold cases
		if `kfold' > 1 { 
			
			// Create the modified if/in statement to be pushed into the user's 
			// estimation command
			loc modifin "`ifin' & `split' != \`k'"
			
			// Creates the new command string with the substituted value stored 
			// in the local cmdmod
			mata: st_local("cmdmod", subinstr(`cmd', `"`ifin'"', `"`macval(modifin)'"'))
						
			// Create the if/in statement for predictions
			ret loc predifin " `ifin' & !e(sample) & `split' == \`k'"
			
			// Also create a modified statement to fit the model to all training
			// data
			loc kfifin "`ifin' & `split' <= `kfold'"
			
			// And do the same for the prediction
			ret loc kfpredifin " `ifin' & !e(sample) & `split' == `= `kfold' + 1'"
			
			// Creates the modified command string for fitting all training data 
			// following the k-folds.
			mata: st_local("kfcmdmod", subinstr(`cmd', `"`ifin'"', `"`kfifin'"'))			

		} // End IF Block for KFold if/in statements
		
		// For non-KFold
		else {
			
			// Create the modified if/in statement for non-KFold cases
			loc modifin "`ifin' & `split' == 1"
			
			// Create the if/in statement for predictions
			ret loc predifin " `ifin' & !e(sample) & `split' == 2"
			
			// Creates the new command string with the substituted value stored 
			// in the local cmdmod
			mata: st_local("cmdmod", subinstr(`cmd', `"`ifin'"', `"`modifin'"'))
						
		} // End ELSE Block for non-KFold if/in statements
				
	} // End ELSE Block for estimation commands w/if/in statements.
	
	// Returns the modified command string in r(modcmd)
	ret loc modcmd `macval(cmdmod)'

	// Returns the modified command string for the KFold all training data case
	// in r(kfmodcmd)
	ret loc kfmodcmd `"`kfcmdmod'"'
	
// End program
end	
	
	