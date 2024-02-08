/*******************************************************************************
*                                                                              *
*             Handles the validation/testing part of the process               *
*                                                                              *
*******************************************************************************/

*! validate
*! v 0.0.4
*! 08FEB2024

// Drop program from memory if already loaded
cap prog drop validate

// Define program
prog def validate, rclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax [if] [in] , MEtric(string asis) Pred(varname) [ Obs(varname) 	 ///   
	MOnitors(string asis) DISPlay KFold(integer 1)]
	
	// Test to ensure the metric is not included in the monitor
	if `: list metric in monitors' {
		
		// Display an informative message
		di as error "The metric `metric' is included in the monitors `monitors'."
		
		// Throw an error code
		err 134
		
	} // End IF Block to handle metric included in monitors
	
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
	
	// Loop over the K-Folds
	forv i = 1/`kfold' {
		
		// If there is only a single fold
		if `kfold' == 1 {
			
			// Set a null macro for the fold identifier
			loc kf 
			
			// set the display text for metrics and monitors
			loc ditxt 
			
		} // End IF Block for no-K-Folds
		
		// If there are greater than 1 K-Folds
		else if `kfold' > 1 {
			
			// Set the macro for the fold identifier
			loc kf `i'
			
			// set the display text for metrics and monitors 
			loc ditxt " for K-Fold #`i'"
			
		} // End ELSEIF block for K-Fold CV
		
		// Test for display of metrics/monitors
		if !mi("`display'") & `kfold' == 1 di as res "Monitor results`ditxt': " _n
		
		// Count the words in monitors
		loc mons : word count `monitors'
		
		// Loop over the monitors
		forv i = 1/`mons' {
			
			// Get the name of the function for monitoring
			loc monnm : word `i' of `monitors'
			
			// Call the mata function
			mata: monval = `monnm'("`pred'", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm'`ditxt'", monval)
			
			// Creates a Stata scalar with the appropriate value
			mata: st_numscalar("`monnm'sc", monval)
			
			// Sets the return value for the scalar
			return scalar `monnm'`kf' = `= `monnm'sc'
			
		} // End loop over monitors
		
		// Test for display of metrics/monitors
		if !mi("`display'") di as res "Validation Metric`ditxt': " _n

		// Call the mata function for the metric
		mata: metval = `metric'("`pred'", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric'`ditxt'", metval)
			
		// Push the value into a scalar
		mata: st_numscalar("`metric'sc", metval)
		
		// Sets the return value for the scalar
		return scalar metric`kf' = `= `metric'sc'

	} // End Loop over K-Folds
	
	// If this is a K-Fold CV case
	if `kfold' > 1 {
		
		// Set the macro for the display text
		loc ditxt "for all training data"
		
		// Test for display of metrics/monitors
		if !mi("`display'") & `kfold' == 1 di as res "Monitor results`ditxt': " _n
		
		// Count the words in monitors
		loc mons : word count `monitors'
		
		// Loop over the monitors
		forv i = 1/`mons' {
			
			// Get the name of the function for monitoring
			loc monnm : word `i' of `monitors'
			
			// Call the mata function
			mata: monval = `monnm'("`pred'all", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm'`ditxt'", monval)
			
			// Creates a Stata scalar with the appropriate value
			mata: st_numscalar("`monnm'sc", monval)
			
			// Sets the return value for the scalar
			return scalar `monnm'all = `= `monnm'sc'
			
		} // End loop over monitors
		
		// Test for display of metrics/monitors
		if !mi("`display'") di as res "Validation Metric`ditxt': " _n

		// Call the mata function for the metric
		mata: metval = `metric'("`pred'all", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric'`ditxt'", metval)
			
		// Push the value into a scalar
		mata: st_numscalar("`metric'sc", metval)
		
		// Sets the return value for the scalar
		return scalar metricall = `= `metric'sc'
		
	} // End IF Block for K-Fold case
	
// End of program definition
end

	