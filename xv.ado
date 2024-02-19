/*******************************************************************************
*                                                                              *
*                Cross-Validation for Stata Estimation Commands                *
*                                                                              *
*******************************************************************************/

*! xv
*! v 0.0.1
*! 18FEB2023

// Drop program from memory if already loaded
cap prog drop xv

// Defines the program; properties lists the applicable options for this prefix 
// The tpoint option is only valid for panel/time-series cross-validation
prog def xv, eclass properties(prefix xv)

	// Stata version statement, can check for backwards compatibility later
	version 18

	// Set the prefix name for Stata to recognize it
	set prefix xv

	// Tokenize the input string
	gettoken cv cmd : 0, parse(":") bind 
	
	// Parse the prefix on the comma.  `props' will contain split proportions
	gettoken props xvopts : cv, parse(",") bind
	
	// Remove the leading comma from the options for xv.
	loc xvopts `"`= substr(`"`xvopts'"', 2, .)'"'

	// Then parse the options from the remainder of the macro
	mata: cvparse(`"`xvopts'"')
	
	// If there is anything in the missing local throw an error message
	if mi(`"`metric'"') | mi(`"`pred'"') {
		
		// Display the error message
		di as err `"You must supply valid arguments to metric and pred "'    ///   
		`"to use the xv prefix."'
		
		// Throw an error code to exit
		err 198
		
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
	
	// Check to see if the user passed the state option
	if !mi(`"`state'"') {
		
		// Call the state command
		`state'
		
		// Capture all of the returned values in locals
		loc rng `r(rng)'
		loc rngcurrent `r(rngcurrent)'
		loc rngstate `r(rngstate)'
		loc rngseed `r(rngseed)'
		loc rngstream `r(rngstream)'
		loc filename `r(filename)'
		loc filedate `r(filedate)'
		loc version `r(version)'
		loc currentdate `r(currentdate)'
		loc currenttime `r(currenttime)'
		loc stflavor `r(stflavor)'
		loc processors `r(processors)'
		loc hostname `r(hostname)'
		loc machinetype `r(machinetype)'
		
	} // End IF Block to call the state command
	
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
	
	// Return all of the macros from the state command if invoked
	eret loc rng = "`rng'"
	eret loc rngcurrent = "`rngcurrent'"
	eret loc rngstate = "`rngstate'"
	eret loc rngseed = "`rngseed'"
	eret loc rngstream = "`rngstream'"
	eret loc filename = "`filename'"
	eret loc filedate = "`filedate'"
	eret loc version = "`version'"
	eret loc currentdate = "`currentdate'"
	eret loc currenttime = "`currenttime'"
	eret loc stflavor = "`stflavor'"
	eret loc processors = "`processors'"
	eret loc hostname = "`hostname'"
	eret loc machinetype = "`machinetype'"

// End definition of ttsplit prefix command	
end 

	