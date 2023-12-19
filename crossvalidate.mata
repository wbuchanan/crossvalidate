/*******************************************************************************
*                                                                              *
*                    Mata library for -crossvalidate- package                  *
*                                                                              *
*******************************************************************************/



// Starts mata interpreter
mata:

// A function to retrieve an if/in expression from an estimation command.  The 
// value is returned in a Stata local macro named `ifin' and will be missing if 
// no if or in conditions were included in the command passed to the function.
void function getifin(string scalar x) {
	
	// Used to store the result from testing the match for the regular expression
	real scalar matched
	
	// Contains the if/in expression from the command that will be modified
	string scalar strexp
	
	// Tests if there is an if/in expression in the estimation command
	matched = regexmatch(x, "i[fn]{1}\s+.*?(?=, *[a-zA-Z]|\$)")
	
	// If there is an expression in the estimation command
	if (matched) {
		
		// Stores the expression in strexp
		strexp = regexcapture(0)
		
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
	real scalar i, nopts
	
	// Stores the name of all the potential options
	opts = ("metric", "monitors", "uid", "tpoint", "retain", "kfold", 		 ///   
			 "state", "results", "grid", "params", "tuner", "seed", "classes" )
	
	// Gets the number of options so we don't need to track it manually and 
	// avoid the minor performance penalty of using cols(opts) in the loop below
	nopts = cols(opts)
	
	// Loop over the index values for each of the options 
	for(i = 1; i <= nopts; i++) {
		
		// Test for matches for each of the options
		if (ustrregexm(cv, "(" + opts[1, i] + "\([a-zA-Z0-9]+\))", 1)) {
			
			// Returns the option name and argument(s) in a local with the same 
			// name (e.g., kfold might contain kfold(10))
			st_local(opts[1, i], ustrregexs(1))
			
		} // End IF block for identified options
		
	} // End loop over the option indices
	
} // End of function definition to parse prefix options for crossvalidate package

// Defines a function to retrieve the argument(s) passed to a parameter with an 
// option to pass the name of the parameter; It might be worth considering using 
// an AssociativeArray object for the return value where the key would be the 
// parameter name and the value could be the argument passed to the parameter.
// This would avoid calling this on each possible parameter, but would mean we 
// would need to keep track of that object on the Mata stack.
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

// Create a function to return a confusion matrix from the predicted/observed 
// value variables and a third variable to identify which records to subset.  
// We'll use this same signature for all metrics and monitors to make it easier 
// for others to create their own metrics/monitors as well.  The difference is 
// that metrics and monitors should generally return a scalar.
real matrix confusion(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Initialize matrix to store the confusion matrix, a temp matrix that will 
	// store the raw data in sorted order, and the unique combinations of 
	// predicted and observed outcomes
	real matrix conf, temp, urows
	
	// Initialize vector to store unique values of predicted/observed values
	real colvector uvals, idx
	
	// Real scalar to iterate over values, number of observations, a scalar for 
	// the cell size, and matrix indices to populate the confusion matrix using 
	// the values of the predicted and observed values
	real scalar i, nobs, cell, m, n
	
	// Create the temp matrix by selecting the predicted and observed variables
	// that satisfy the condition encoded in the variable touse.  Sorts the data
	// in order of predicted then observed values, and then adds a row ID to the 
	// resulting matrix.
	temp = (sort(st_data(., (pred + " " + obs), touse), (1, 2)), 			 ///   
			J(1, 1, (1::nobs)))
	
	// Identifies all unique values across predicted and observed; this will 
	// ensure we always return a square matrix since we will define the 
	// dimension of the confusion matrix based on the combination of unique 
	// values that are predicted/observed.  If a model performs poorly and 
	// collapses to a single state, this will make it easier to return 0 cells 
	// in the appropriate locations.
	uvals = uniqrows(temp[., 1] \ temp[., 2])
	
	// Create a null matrix for the confusion matrix using dimensions based on 
	// the combination of unique predicted/observed variable values.
	conf = J(rows(uvals), rows(uvals), 0)
	
	// Get number of observations in the data; not doing anything now, but could
	// be useful if we decide to return a struct with other information later
	// instead of just the confusion matrix with cell counts.
	nobs = rows(temp)
	
	// Get the unique combinations of predicted and observed values to iterate
	// over to get the min/max boundaries for the cell frequencies
	urows = uniqrows(temp[., (1, 2)])
	
	// Iterate over the urows to start selecting the min/max row indices for 
	// each combination
	for(i = 1; i <= rows(urows); i++) {
		
		// Gets the row indices for the ith combination of unique predicted and 
		// observed values.  The select function returns a matrix since it is 
		// comparing two columns, so we need to pass that to the rowsum function
		// and test whether both columns match by looking for a rowsum of 2.  
		// The : before the equality operator is used to perform elementwise 
		// operations instead of set/matrix operations.
		idx = select(temp[., 3], rowsum(temp[., (1, 2)] :== urows[i, .]) :== 2)
		
		// If a single row is returned the cell size is 1
		if(rows(idx) == 1) cell = 1
		
		// If there is more than a single row, take the difference between the 
		// first and last indices and add 1 to it for the cell size
		else cell = max(idx) - min(idx) + 1
		
		// Get the row index
		m = urows[i, 1]
		
		// Get the column index
		n = urows[i, 2]
		
		// Populate the cell in the confusion matrix with the cell size that 
		// corresponds with the predicted (row) and observed (column) locations
		conf[m, n] = cell
		
	} // End Loop over unique combinations of predicted and observed values
	
	// Return the confusion matrix
	return(conf)
	
} // End function definition for confusion matrix

// Can define each of the common metrics/monitors for binary prediction, based 
// on passing the arguments for the confusion matrix.  There will be additional 
// computational overhead this way, but we could also consider coding around 
// this so we would return the confusion matrix to a Mata object and then do the 
// subsequent computations on the single confusion matrix.

// End mata interpreter
end

