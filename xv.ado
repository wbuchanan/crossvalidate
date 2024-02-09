/*******************************************************************************
*                                                                              *
*                Cross-Validation for Stata Estimation Commands                *
*                                                                              *
*******************************************************************************/

*! xv
*! v 0.0.1
*! 02FEB2023

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
	loc xvopts `"`= substr(`"`opts'"', 2, .)'"'
	
	// Then parse the options from the remainder of the macro
	mata: cvparse(`"`xvopts'"')
	
	foreach i in  metric monitors uid tpoint retain kfold state results grid ///   
	params tuner seed classes threshold pstub split display pred obs modifin ///   
	kfifin noall {
		di as res `"Value of `i' is ``i''"'
	}
	
	
	// Remove leading colon from the estimation command
	loc cmd `: subinstr loc cmd `":"' ""'
		
	// If the seed option is populated set the seed value to the seed that the 
	// user specified
	if !mi(`"`seed'"') {
		
		// Parse the seed option
		mata: getarg("`seed'")
		
		// Set the seed to the user specified value
		set seed `argval'
		
	} // End IF Block to set the pseudo-random number generator seed.
	
	
	// Check for if/in conditions
	//mata: getifin(`"`cmd'"')
	
	// Marking for refactoring since this logic should be encapsulated in a 
	// standalone program or Mata function since it will be used repeatedly 
	// across each of the commands
	
	
	// If there is an if/in expression 
	if `"`ifin'"' != "" {
		
		/*
			Test to see if this is an `in` expression.  If it is generate a 
			tempvar called xvifin like: qui: g byte xvifin = 1 `ifin'.
			Next substitute "if xvifin == 1" into the estimation command to 
			replace the `in` expression.  This should make all subsequent stuff 
			only see an `if` expression instead of trying to manage combining 
			if and in logic in multiple places.
		
		*/
		
		
	}
	
	else {
		
		
		
	}
	
	
	
	
	
	

// End definition of ttsplit prefix command	
end 

	