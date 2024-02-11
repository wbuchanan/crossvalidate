/*******************************************************************************
*                                                                              *
*                Cross-Validation for Stata Estimation Commands                *
*                                                                              *
*******************************************************************************/

*! xv
*! v 0.0.1
*! 11FEB2023

// Drop program from memory if already loaded
cap prog drop xv

// Defines the program; properties lists the applicable options for this prefix 
// The tpoint option is only valid for panel/time-series cross-validation
prog def xv, eclass properties(prefix xv)

	// Stata version statement, can check for backwards compatibility later
	version 18

	// Tokenize the input string
	gettoken cv cmd : 0, parse(":") bind 
	
	// Parse the prefix on the comma.  `props' will contain split proportions
	gettoken props xvopts : cv, parse(",") bind
	
	// Remove the leading comma from the options for xv.
	loc xvopts `"`= substr(`"`xvopts'"', 2, .)'"'

	// Then parse the options from the remainder of the macro
	mata: cvparse(`"`xvopts'"')
	
	// Set a local for the missing parameters
	loc miss 
	
	// This should be a loop over the required parameters across all four 
	// underlying commands.  If one is missing we can collect it's name and 
	// then throw one big error message listing all of the missing parameters.
	foreach i in  metric monitors uid tpoint retain kfold state results grid ///   
	params tuner seed classes threshold pstub split display pred obs modifin ///   
	kfifin noall {
		
		// If a required parameter is missing, add it to the local
		if mi(`"`i'"') loc miss "`miss' `i',"
		
	} // End loop over required parameters
	
	// If there is anything in the missing local throw an error message
	if !mi(`"`miss'"') {
		
		// Display the error message
		di as err `"You must supply arguments to the following parameters "' ///   
		`"to use the xv prefix: `miss' please modify your command statement"'
		
		// Throw an error code to exit
		err
		
	} // End IF Block for missing required parameters
		
	// Remove leading colon from the estimation command
	loc cmd `: subinstr loc cmd `":"' ""'
	
	// Allocate a tempvar in case it is needed
	tempvar xvtouse
	
	// Check for if/in conditions
	mata: getifin(`"`cmd'"')
	
	// If there is an if/in expression 
	if ustrregexm(`"`ifin'"', "\s?in\s+") {
		
		// Create an indicator that can be used to generate an if expression in 
		// the estimation command instead
		qui: g byte `xvtouse' = 1 `ifin'
		
		// Replaces the cmd macro with an updated version that uses an if 
		// expression instead of an in expression
		mata: st_local("cmd", subinstr(`cmd', `"`ifin'"', " if `xvtouse' == 1"))		
		
	} // End IF Block for in expression handling
	
	// If the seed option is populated set the seed value to the seed that the 
	// user specified
	if !mi(`"`seed'"') {
		
		// Parse the seed option
		mata: getarg("`seed'")
		
		// Set the seed to the user specified value
		set seed `argval'
		
	} // End IF Block to set the pseudo-random number generator seed.
	
	/*
	The split, fit, predict, and validate commands should be able to be called 
	sequentially from this point down.  It will be important to remember to 
	pass all of the returned values from each command back into the appropriate 
	ereturn type (e.g., ereturn macro ...).  Since some commands return a 
	variable number of macros, this means there will need to be some loops used 
	that mirror some of the internal logic (e.g., using the number of kfolds and 
	the stub for the estimation result name to reference all of the macros like 
	eret loc estres`i' "`results'`i'").  
	*/
	
	
	/*
	For any optional arguments where we will set defaults (e.g., split variable 
	name, etc...) we need to clean those up (e.g., if the user doesn't want to 
	retain the split variable we need to drop it prior to exiting the command)
	*/
	
	// Remember to repost results
	ereturn repost 

// End definition of ttsplit prefix command	
end 

	