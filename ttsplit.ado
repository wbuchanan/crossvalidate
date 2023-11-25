/*******************************************************************************
*                                                                              *
*                 Train test splits for cross-sectional models                 *
*                                                                              *
*******************************************************************************/

*! ttsplit
*! v 0.0.1
*! 24NOV2023

// Drop program from memory if already loaded
cap prog drop ttsplit

// Defines the program; properties lists the applicable options for this prefix 
// The tpoint option is only valid for panel/time-series cross-validation
prog def ttsplit, eclass properties(prefix metric uid retain kfold state 	 ///   
									monitors results grid params tuner)

	// Stata version statement, can check for backwards compatibility later
	version 18

	// Tokenize the input string
	gettoken cv cmd : 0, parse(":") bind 
	
	// Need to parse the split proportion from cv
	gettoken 
	
	
	// Then parse the options from the remainder of the macro
	
	
	// Remove leading colon from the estimation command
	loc cmd `: subinstr loc cmd `":"' ""'
	
	// If the seed option is populated set the seed value to the seed that the 
	// user specified
	
	// If uid, identify the groups/clusters that will be randomly split into the
	// train and test sets
	
	
	// Check for if/in conditions
	mata: getifin(`"`cmd'"')
	
	// Marking for refactoring since this logic should be encapsulated in a 
	// standalone program or Mata function since it will be used repeatedly 
	// across each of the commands
	{
	
	// If there is an if/in expression 
	if `"`ifin'"' != "" {
		
		// Modify the if/in expression to include the conditioning on train set
		// If using kfold, the expression needs to include a macro placeholder
		// for the looping over the kfolds
		
		
	}
	
	else {
		
		
		
	}
	
	
	}
	
	// If state, call separate program that will get and bind all of the state 
	// information with the dataset
	
	// This will be the execution block for a single fitting of the model to the 
	// data.  This should also likely be refactored into a separate/standalone 
	// function or program since this can be standardized for each command type
	{
	
	// Fitt the statistical model in `cmd'
	
	// store the estimation results w/est sto
	
	// Compute/return monitors

	// predict the dependent variable for the set defined by getifin + ! train
	
	// pass prediction and dv variable names to mata function that will need to 
	// compute the validation/test metric
	
	// return all the values from the ereturn list in the same element names 
	// if possible
	
		
	}
	
	

// End definition of ttsplit prefix command	
end 

	