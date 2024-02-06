/*******************************************************************************
*                                                                              *
*             Handles the validation/testing part of the process               *
*                                                                              *
*******************************************************************************/

*! validate
*! v 0.0.3
*! 06FEB2024

// Drop program from memory if already loaded
cap prog drop validate

// Define program
prog def validate, rclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax [if] [in] , MEtric(string asis) Pred(varname) [ Obs(varname) 	 ///   
	MOnitors(string asis) DISPlay ]
	
	// Mark the sample that will be used for validation
	marksample touse
	
	// Test if missing observed outcome variable name
	if mi("`obs'") loc obs `e(depvar)'
	
	// Verify that there is only a single metric
	if `: word count `metric'' > 1 {
		
		// Display an error message
		di as err "Users can only specify a single metric for hyperparameter optimization".
		
		// Throw an error code
		err 134
		
	} // End IF Block for invalid number of metric
	
	// This should be the pattern for monitors:
	
	// Test for display of metrics/monitors
	if !mi("`display'") di as res "Monitor results: " _n
	
	// Count the words in monitors
	loc mons : word count `monitors'
	
	// Loop over the monitors
	forv i = 1/`mons' {
		
		// Get the name of the function for monitoring
		loc monnm : word `i' of `monitors'
		
		// Call the mata function
		mata: monval = `monnm'("`pred'", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm'", monval)
		
		// Creates a Stata scalar with the appropriate value
		mata: st_numscalar("`monnm'sc", monval)
		
		// Sets the return value for the scalar
		return scalar `monnm' = `= `monnm'sc'
		
	} // End loop over monitors
	
	// Test for display of metrics/monitors
	if !mi("`display'") di as res "Validation Metric: " _n

	// Call the mata function for the metric
	mata: metval = `metric'("`pred'", "`obs'", "`touse'")
	
	// Print the monitor to the console if requested
	if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric'", metval)
		
	// Push the value into a scalar
	mata: st_numscalar("`metric'sc", metval)
	
	// Sets the return value for the scalar
	return scalar metric = `= `metric'sc'
	
// End of program definition
end

	