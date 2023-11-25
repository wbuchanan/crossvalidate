/*******************************************************************************
*                                                                              *
*                    Mata library for -crossvalidate- package                  *
*                                                                              *
*******************************************************************************/



// Starts mata interpreter
mata:

// A function to retrieve an if/in expression from an estimation command
void function getifin(string scalar x) {
	
	// Used to store the result from testing the match for the regular expression
	real scalar matched
	
	// Contains the if/in expression from the command that will be modified
	string scalar strexp
	
	// Tests if there is an if/in expression in the estimation command
	matched = ustrregexm(x, "(i[fn]{1}\s+[^,]+),")
	
	// If there is an expression in the estimation command
	if (matched) {
		
		// Stores the expression in strexp
		strexp = ustrregexs(1)
		
	// If there isn't a match	
	} else {
		
		// Stores an empty string
		strexp = ""
		
	} // End ELSE block from testing for presence of if/in expression
	
	// Stores the if/in expression in the local macro ifin
	st_local("ifin", strexp)
	
} // End of Mata function definition to retrieve if/in expressions from command

// Defines a function used to replace the if/in expression in the command with 
// the version that would be used to identify the training set
void function repifin(string scalar x, string scalar swap) {
	
	// Stores the new string prior to returning it in a macro
	string scalar newcmd
	
	// Replaces the existing if/in statement with the swapped statement
	newcmd = ustrregexra(x, "(i[fn]{1}\s+[^,]+)", swap)
	
	// Returns the new command statement 
	st_local("newcmd", newcmd)
	
} // End of definition of Mata function to replace if/in expression in command

// Defines a function to parse the prefix command into it's constituent parts
void function cvparse(string scalar cv) {
	
	// Defines a string vector with the names of the potential options
	string rowvector opts 
	
	// Defines a variable to use for iterating over the options
	real scalar i
	
	// Stores the name of all the potential options
	opts = [ "metric", "monitors", "uid", "tpoint", "retain", "kfold", 		 ///   
			 "state", "results", "grid", "params", "tuner", "seed" ]
	
	// Loop over the index values for each of the options
	for(i = 1; i <= 11; i++) {
		
		// Test for matches for each of the options
		if (ustrregexm(cv, "(" + opts[1, i] + "\([a-zA-Z0-9]+\))", 1)) {
			
			// Returns the option name and argument(s) in a local with the same 
			// name (e.g., kfold might contain kfold(10))
			st_local(opts[1, i], ustrregexs(1))
			
		} // End IF block for identified options
		
	} // End loop over the option indices
	
} // End of function definition to parse prefix options for crossvalidate package

// Defines a function to retrieve the argument(s) passed to a parameter with an 
// option to pass the name of the parameter
void function getarg(string scalar param, | string scalar pname) {
	
	// String scalar to store the argument(s)
	string scalar retval
	
	// If the parameter name is supplied to the function
	if (args() == 2) {
		
		// subinstr removes the parameter name, and regex replace should remove
		// the parentheses
		retval = ustrregexra(subinstr(param, pname, ""), "[\(\)]", "")
	
	// If the parameter name is not supplied to the function
	} else {
		
		// Removes everything up to the opening parentheses with the regex, then 
		// removes the closing parenthesis with subinstr
		retval = subinstr(ustrregexra(param, "[a-z]+\(", ""), ")", "")
		
	} // End ELSE Block for no parameter name supplied
	
	// Returns the argument value in a local macro
	st_local("argval", retval)
	
} // End of function definition to get argument value from a parameter


// End mata interpreter
end

