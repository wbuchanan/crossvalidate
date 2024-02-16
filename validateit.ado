/*******************************************************************************
*                                                                              *
*             Handles the validation/testing part of the process               *
*                                                                              *
*******************************************************************************/

*! validateit
*! v 0.0.5
*! 16FEB2024

// Drop program from memory if already loaded
cap prog drop validateit

// Define program
prog def validateit, rclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax , MEtric(string asis) Pred(varname) SPLit(varname) 				 ///   
	[ Obs(varname) MOnitors(string asis) DISplay KFold(integer 1) noall ]
	
	// Test to ensure the metric is not included in the monitor
	if `: list metric in monitors' {
		
		// Display an informative message
		di as error "The metric `metric' is included in the monitors `monitors'."
		
		// Throw an error code
		err 134
		
	} // End IF Block to handle metric included in monitors
	
	// Test if missing observed outcome variable name
	if mi("`obs'") & mi("`e(depvar)'") {
	
		// Display an error message
		di as err "If the dependent variable is not passed to {opt obs} it " ///   
		"must be accessible in e(depvar)."
		
		// Throw an error code and exit
		err 100
	
	} // End IF Block for unknown dependent variable
	
	// If no argument is passed to the option but it is found in e(depvar) 
	else if mi("`obs'") & !mi("`e(depvar)'") loc obs `e(depvar)'
	
	// Verify that there is only a single metric
	if `: word count `metric'' > 1 {
		
		// Display an error message
		di as err "Users can only specify a single metric for hyperparameter optimization".
		
		// Throw an error code
		err 134
		
	} // End IF Block for invalid number of metric
	
	// Mark the sample that will be used to compute the validation metrics for 
	// each K-Fold
	tempvar touse
	
	// Create the tempvariable used to identify the set to use for validation
	qui: g byte `touse' = 0
	
	// Set display related macros
	if !mi("`display'") {
		
		// Figure out the number of splits used in the dataset
		mata: st_numscalar("vals", rows(uniqrows(st_data(., "`split'"))))
		
		// Defines macros to use to construct the display strings used below
		loc kfditxt "for K-Fold #\`k'"
		loc kfalttxt "for results on entire Training Set"
		loc montxt "Monitor Results"
		loc metrictxt "Metric Result"
		
		// If there are two splits it is a train/test split
		if vals == 2 loc ditxt "for the Test Set"
		
		// If there are more than two splits (3) the second split is validation
		else loc ditxt "for the Validation Set"
		
	} // End IF Block for user requested display
	
	// If there is only a single fold
	if `kfold' == 1 {

		// Set the touse tempvariable
		qui: replace `touse' = cond(`split' == 2, 1, 0)
	
		// Display the header for the results
		if !mi("`display'") & !mi(`"`monitors'"') di as res _n "`montxt' `ditxt'" _n
		
		// Count the words in monitors
		loc mons : word count `monitors'
		
		// Loop over the monitors
		forv i = 1/`mons' {
			
			// Get the name of the function for monitoring
			loc monnm : word `i' of `monitors'
			
			// Call the mata function
			mata: monval = `monnm'("`pred'", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm' `ditxt'", monval)
			
			// Creates a Stata scalar with the appropriate value
			mata: st_numscalar("`monnm'sc", monval)
			
			// Sets the return value for the scalar
			return scalar `monnm' = `= `monnm'sc'
			
		} // End loop over monitors
		
		// Test for display of metrics/monitors
		if !mi("`display'") di as res _n "`metrictxt' `ditxt': " _n

		// Call the mata function for the metric
		mata: metval = `metric'("`pred'", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `ditxt'", metval)
			
		// Push the value into a scalar
		mata: st_numscalar("`metric'sc", metval)
		
		// Sets the return value for the scalar
		return scalar metric = `= `metric'sc'
		
	} // End IF Block for no-K-Folds
	
	// If this involves K-Fold CV
	else {
		
		// Loop over the K-Folds
		forv k = 1/`kfold' {
			
			// Set the value of the touse tempvariable
			qui: replace `touse' = cond(`split' == `k', 1, 0)
			
			// Test for display of metrics/monitors
			if !mi("`display'") & !mi(`"`monitors'"') di as res _n "`montxt' `kfditxt': " _n
			
			// Count the words in monitors
			loc mons : word count `monitors'
			
			// Loop over the monitors
			forv i = 1/`mons' {
				
				// Get the name of the function for monitoring
				loc monnm : word `i' of `monitors'
				
				// Call the mata function
				mata: monval = `monnm'("`pred'", "`obs'", "`touse'")
				
				// Print the monitor to the console if requested
				if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm' `kfditxt'", monval)
				
				// Creates a Stata scalar with the appropriate value
				mata: st_numscalar("`monnm'sc", monval)
				
				// Sets the return value for the scalar
				return scalar `monnm'`k' = `= `monnm'sc'
				
			} // End loop over monitors
			
			// Test for display of metrics/monitors
			if !mi("`display'") di as res _n "`metrictxt' `kfditxt': " _n

			// Call the mata function for the metric
			mata: metval = `metric'("`pred'", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `kfditxt'", metval)
				
			// Push the value into a scalar
			mata: st_numscalar("`metric'sc", metval)
			
			// Sets the return value for the scalar
			return scalar metric`k' = `= `metric'sc'
			
			// If this is a K-Fold CV case
			if mi(`"`all'"') & `k' == `kfold' {
				
				// Set the value of the touse tempvariable
				qui: replace `touse' = cond(`split' == `= `kfold' + 1', 1, 0)

				// Test for display of metrics/monitors
				if !mi("`display'") & !mi(`"`monitors'"') di as res _n "`montxt' `kfalttxt': " _n
				
				// Count the words in monitors
				loc mons : word count `monitors'
				
				// Loop over the monitors
				forv i = 1/`mons' {
					
					// Get the name of the function for monitoring
					loc monnm : word `i' of `monitors'
					
					// Call the mata function
					mata: monval = `monnm'("`pred'all", "`obs'", "`touse'")
					
					// Print the monitor to the console if requested
					if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm' `kfalttxt'", monval)
					
					// Creates a Stata scalar with the appropriate value
					mata: st_numscalar("`monnm'sc", monval)
					
					// Sets the return value for the scalar
					return scalar `monnm'all = `= `monnm'sc'
					
				} // End loop over monitors
				
				// Test for display of metrics/monitors
				if !mi("`display'") di as res _n "`metrictxt' `kfalttxt': " _n

				// Call the mata function for the metric
				mata: metval = `metric'("`pred'all", "`obs'", "`touse'")
				
				// Print the monitor to the console if requested
				if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `kfalttxt'", metval)
					
				// Push the value into a scalar
				mata: st_numscalar("`metric'sc", metval)
				
				// Sets the return value for the scalar
				return scalar metricall = `= `metric'sc'
				
			} // End IF Block for K-Fold case
			
		} // End Loop over K-Folds
		
	} // End ELSE Block for K-Fold CV

// End of program definition
end

