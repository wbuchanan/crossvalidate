/*******************************************************************************
*                                                                              *
*             Handles the validation/testing part of the process               *
*                                                                              *
*******************************************************************************/

*! validateit
*! v 0.0.7
*! 19FEB2024

// Drop program from memory if already loaded
cap prog drop validateit

// Define program
prog def validateit, rclass 

	// Version statement 
	version 18
	
	// Syntax
	syntax , MEtric(string asis) PStub(string asis) SPLit(varname) 			 ///   
	[ Obs(varname) MOnitors(string asis) DISplay KFold(integer 1) noall loo ]
	
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
	
	// Test for invalid kfold with loo option
	if `kfold' <= 1 & !mi("`loo'") {
		
		// Display an error message
		di as err "Leave-One-Out cross-validation cannot be used with a "	 ///   
		"single K-Fold."
		
		// Return error code and exit
		err 198
		
	} // End IF block for invalid kfold & loo combination
	
	// Test for invalid KFold option
	if `kfold' < 1 {
		
		// Display an error message
		di as err "There must always be at least 1 K-Fold.  This would be "	 ///   
		"the training set in a simple train/test split.  You specified "	 ///   
		"`kfold' K-Folds."
		
		// Return error code and exit
		err 198
		
	} // End IF Block for invalid K-Fold argument
		
	// Test for `pstub'all if using K-Fold and not specifying noall
	if `kfold' > 1 & mi(`"`all'"') {
		
		// Capture the code from confirming the variable's presence
		cap: confirm v `pstub'all
		
		// If this fails
		if _rc != 0 {
			
			// Print an error message to the console
			di as err "The variable `pstub'all was not found and you are "	 ///   
			"requesting evaluating metrics that require that variable." _n   ///   
			"You can either pass the noall option, or need to predict the "	 ///   
			"values from your models again to generate that variable."
			
			// Throw an error code and exit
			err 111
			
		} // End IF Block for missing `pstub'all variable
		
	} // End IF Block for detecting missing `pstub'all w/K-Fold and missing noall
	
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
	if `kfold' == 1 & mi("`loo'") {

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
			mata: monval = `monnm'("`pstub'", "`obs'", "`touse'")
			
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
		mata: metval = `metric'("`pstub'", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `ditxt'", metval)
			
		// Push the value into a scalar
		mata: st_numscalar("`metric'sc", metval)
		
		// Sets the return value for the scalar
		return scalar metric = `= `metric'sc'
		
	} // End IF Block for no-K-Folds
	
	// If this involves K-Fold CV
	else if `kfold' > 1 & mi("`loo'") {
		
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
				mata: monval = `monnm'("`pstub'", "`obs'", "`touse'")
				
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
			mata: metval = `metric'("`pstub'", "`obs'", "`touse'")
			
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
					mata: monval = `monnm'("`pstub'all", "`obs'", "`touse'")
					
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
				mata: metval = `metric'("`pstub'all", "`obs'", "`touse'")
				
				// Print the monitor to the console if requested
				if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `kfalttxt'", metval)
					
				// Push the value into a scalar
				mata: st_numscalar("`metric'sc", metval)
				
				// Sets the return value for the scalar
				return scalar metricall = `= `metric'sc'
				
			} // End IF Block for K-Fold case
			
		} // End Loop over K-Folds
		
	} // End ELSE Block for K-Fold CV
	
	// Otherwise it will be for leave-one-out CV
	else if `kfold' > 1 & !mi("`loo'") {
		
		// Set the value of the touse tempvariable
		qui: replace `touse' = cond(`split' <= `= `kfold'', 1, 0)

		// Test for display of metrics/monitors
		if !mi("`display'") & !mi(`"`monitors'"') di as res _n "`montxt' `kfalttxt': " _n
		
		// Count the words in monitors
		loc mons : word count `monitors'
		
		// Loop over the monitors
		forv i = 1/`mons' {
			
			// Get the name of the function for monitoring
			loc monnm : word `i' of `monitors'
			
			// Call the mata function
			mata: monval = `monnm'("`pstub'", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`monnm' `kfalttxt'", monval)
			
			// Creates a Stata scalar with the appropriate value
			mata: st_numscalar("`monnm'sc", monval)
			
			// Sets the return value for the scalar
			return scalar `monnm'1 = `= `monnm'sc'
			
		} // End loop over monitors
		
		// Test for display of metrics/monitors
		if !mi("`display'") di as res _n "`metrictxt' `kfalttxt': " _n

		// Call the mata function for the metric
		mata: metval = `metric'("`pstub'", "`obs'", "`touse'")
		
		// Print the monitor to the console if requested
		if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `kfalttxt'", metval)
			
		// Push the value into a scalar
		mata: st_numscalar("`metric'sc", metval)
		
		// Sets the return value for the scalar
		return scalar metric1 = `= `metric'sc'
		
		// Test for the all option
		if mi(`"`all'"') {
			
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
				mata: monval = `monnm'("`pstub'all", "`obs'", "`touse'")
				
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
			mata: metval = `metric'("`pstub'all", "`obs'", "`touse'")
			
			// Print the monitor to the console if requested
			if !mi("`display'") mata: printf("%s = %9.0g\n", "`metric' `kfalttxt'", metval)
				
			// Push the value into a scalar
			mata: st_numscalar("`metric'sc", metval)
			
			// Sets the return value for the scalar
			return scalar metricall = `= `metric'sc'
			
		} // End IF Block for K-Fold case		
		
	} // End ELSEIF Block for LOO CV case

// End of program definition
end

