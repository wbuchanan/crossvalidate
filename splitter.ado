/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! splitter
*! v 0.0.1
*! 10DEC2023

// Drop program from memory if already loaded
cap prog drop splitter

// Define program
prog def splitter, rclass properties(kfold uid tpoint retain) 

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = props id = "Split proportion(s)") [if] [in] [, 	 ///   
		   Uid(varname) TPoint(real -999) KFold(integer 0) RETain(string asis) ]
	
	// First we'll check/verify that appropriate arguments are passed to the 
	// parameters and handle as much defensive stuff up front as possible.
	// Tokenize the first argument
	gettoken train valid: props
	
	// Determine if the values are not proportions
	if `train' > 1 | (!mi(`valid') & `valid' > 1) {
		
		// If not a proportion issue an error message
		di as err "Splits must be specified as proportions of the sample."
		
		// Return error code 
		error 198
		
	} // End of IF Block for non-proportion splits
	
	// Now test for invalid combination of splits
	if !mi(`valid') & `= `valid' + `train'' > 1 {
		
		// Display error message
		di as err "Invalid validation/test split.  The proportion is > 1."
		
		// Return error code
		error 198
		
	} // End IF Block for proportions that sum to greater than unity

	// Test if there is a _splitter variable already defined
	cap confirm v _splitter
	
	// If the variable exists make sure a value is passed to retain
	if _rc != 0 & mi(`"`retain'"') {
		
		// Display error message 
		di as err "The _splitter variable is already defined and no varname" ///   
		" was provided to the retain option."
		
		// Return an error code
		error 110
		
	} // End IF Block to verify requirement for new varname if _splitter defined
		   
	// Require an argument for retain if the user wants a validation and test 
	// split
	if !mi(`valid') & mi(`"`retain'"') {
		
		// If no varname is passed to retain
		di as err "New varname required in retain for validation/test splits."
		
		// Return error code
		error 100
		
	} // End IF Block for new varname requirement for tvt splits
	
	// If tpoint is used expect that the data are xt/tsset
	if `tpoint' != -999 {
		
		// Check whether the data are xt/tsset or not
		cap xtset
		
		// If not xtset
		if _rc != 0 {
			
			// Display an error message
			di as err "Data required to be xt/tsset when using tpoint."
			
			// Return an error code
			error 459
			
		} // End IF Block for non-xt/tsset data with panel data arguments
		
	} // End IF Block to check for the time point option
	
	// Test for presence of sampling unit id if provided
	if !mi(`"`uid'"') {
		
		// Confirm the variable exists and let this handle returning the error 
		confirm v `uid'
		
	} // End IF Block to verify variable in uid if specified
		   
	// Now that error/syntax checking is done, we can start getting into the 
	// meat of the problem.
	
	// If no varname was passed to retain, put the default name in that macro
	// so we can use that one macro to define the name of the variable with the 
	// splits.
	if mi(`"`retain'"') loc retain _splitter
	
	// Mark the sample to handle any if/in arguments (can now pass if `touse') 
	// for the downstream work to handle user specified if/in conditions.
	marksample touse
	
	/* 
	TODO:
		* Identify what class of split is requested tt or tvt
		* Identify if they want kfold CV 
			* We'll also need to return a string with an unevaluated macro in it
				for this that we can use to modify the ifin values in the down-
				stream estimation command when looping over the kfolds
		* Identify if this is a timeseries case:
			* If timeseries we need to determine if panelvar is defined, if so
				that will be the `uid' variable
			* If not no need to worry about `uid' since it is a single timeseries
		* Identify if clustered sampling is needed (e.g., `uid' is populated)
		
		
	*/
	
	// If `kfold' == 0 then create 2 or 3 groups
	
	// Set an r macro with the variable name with the split variable to make 
	// sure it can be cleaned up by the calling command later in the process
	ret loc splitter = `retain'
	
// End of program definitions	
end

