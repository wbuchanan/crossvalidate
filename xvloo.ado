/*******************************************************************************
*                                                                              *
*        Leave-One-Out Cross-Validation for Stata Estimation Commands          *
*                                                                              *
*******************************************************************************/

*! xvloo
*! v 0.0.1
*! 19FEB2023

// Drop program from memory if already loaded
cap prog drop xvloo

// Defines the program; properties lists the applicable options for this prefix 
// The tpoint option is only valid for panel/time-series cross-validation
prog def xvloo, eclass properties(prefix xv)

	// Stata version statement, can check for backwards compatibility later
	version 18
	
	// Set the prefix name for Stata to recognize it
	set prefix xvloo
	
	// Allocate a tempvars for the unique identifier variable and for other 
	// options to use a default
	tempvar uuid xvsplit xvtouse
	
	// Tokenize the input string
	gettoken cv cmd : 0, parse(":") bind 
	
	// Parse the prefix on the comma.  `props' will contain split proportions
	gettoken props xvopts : cv, parse(",") bind
	
	// Determine if this is TT or TVT
	if `: word count `props'' == 1 {
		
		// Test the number of variables that need to be created vs allowed
		if (`props' * `c(N)' + `c(k)' + 2) >= `c(max_k_theory)' {
			
			// Display error message
			di as err "Currently, your Stata supports `c(max_k_theory)' "	 ///   
			"variables, but `= `props' * `c(N)' + `c(k)' + 2' variables "	 ///   
			"are needed for LOO cross-validation.  Reduce your training "	 ///   
			"set proportion or increase the maximum number of variables "	 ///   
			"(see {help memory}) in order to use LOO cross-validation."
			
			// Return error code and exit
			err 1002
			
		} // End IF Block for insufficient max variable
		
	} // End IF Block for TT split case
	
	// For TVT cases
	else {
		
		// Get the proportion for the training set
		loc trp `: word 1 of `props''
		
		// Test the number of variables that need to be created vs allowed
		if (`trp' * `c(N)' + `c(k)' + 2) >= `c(max_k_theory)' {
			
			// Display error message
			di as err "Currently, your Stata supports `c(max_k_theory)' "	 ///   
			"variables, but `= `trp' * `c(N)' + `c(k)' + 2' variables "		 ///   
			"are needed for LOO cross-validation.  Reduce your training "	 ///   
			"set proportion or increase the maximum number of variables "	 ///   
			"(see {help memory}) in order to use LOO cross-validation."
			
			// Return error code and exit
			err 1002
			
		} // End IF Block for insufficient max variable
				
	} // End ELSE Block for TVT split case
	
	// Remove the leading comma from the options for xv.
	loc xvopts `"`= substr(`"`xvopts'"', 2, .)'"'

	// Then parse the options from the remainder of the macro
	mata: cvparse(`"`xvopts'"')
	
	// If there is anything in the missing local throw an error message
	if mi(`"`metric'"') | mi(`"`pstub'"') {
		
		// Display the error message
		di as err `"You must supply valid arguments to metric and pstub "'   ///   
		`"to use the xv prefix."'
		
		// Throw an error code to exit
		err 198
		
	} // End IF Block for missing required parameters
	
	// Check for uid variable.  If none, create a unique ID as _n in a tempvar
	// and pass that as uid to splitit
	if mi(`"`uid'"') {
		
		// Generate the unique identifier if the user is not using clusters for 
		// the LOO CV
		qui: g long `uuid' = _n
		
		// Set the uid local to use this variable
		loc uid "uid(\`uuid')"
		
	} // End IF Block for missing 
	
	// Test if the user passed a K-fold option
	if !mi("`kfold'") {
		
		// Display an error message
		di as err "The kfold() option is invalid with Leave-One-Out cross-"	 ///   
		"validation.  The {opt:noall} option may still be used with Leave-"	 ///   
		"One-Out cross-validation."
		
		// Throw an error message
		err 184
		
	} // End IF Block for invalid kfold argument
	
	// Otherwise
	else {
		
		// Allocate a tempname for the scalar
		tempname xvn
		
		// Parses the argument(s) passed to the uid option (or set above)
		mata: getarg("`uid'")
		
		// Gets the number of clusters/records in the dataset
		mata: st_numscalar("`xvn'",											 ///   
		rows(uniqrows(st_data(., "(" + subinstr("`argval'", " ", ", ") + ")"))))
		
		// Gets the number of records that will need to be sampled for the 
		// clusters or individual records referenced by `uid'
		loc folds = int(`: word 1 of `props'' * `xvn')
		
		// Populates the kfold macro with the number of clusters to split the 
		// sample into
		loc kfold kfold(`folds')
		
	} // End ELSE Block for xvloo set kfold value
	
	// Test if results is missing a value
	if mi(`"`results'"') {
		
		// Set a default to use for the results
		loc results "results(xvres)"
		
		// Set a macro to automatically clean this up at the end
		loc dropresults "estimates drop xvres*"
		
	} // End IF Block to set default results values
	
	// If missing the split option
	if mi(`"`split'"') {
		
		// use the tempvar
		loc split "split(`xvsplit')"
		
	} // End IF Block for the split variable name
		
	// Remove leading colon from the estimation command
	loc cmd `= substr(`"`cmd'"', 2, .)'
	
	// Check for if/in conditions
	mata: getifin(`"`cmd'"')
	
	// If there is an if/in expression 
	if ustrregexm(`"`ifin'"', "\s?in\s+") {
		
		// Create an indicator that can be used to generate an if expression in 
		// the estimation command instead
		qui: g byte `xvtouse' = 1 `ifin'
		
		// Replaces the cmd macro with an updated version that uses an if 
		// expression instead of an in expression
		mata: st_local("cmd", subinstr(`"`cmd'"', `"`ifin'"', " if `xvtouse' == 1"))		
		
	} // End IF Block for in expression handling
	
	// Get any if expressions
	mata: getifin(`"`cmd'"')
	
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

	// Split the dataset into train/test or train/validation/test splits
	splitit `props' `ifin', `uid' `tpoint' `kfold' `split'
	
	// Capture the returned values so they can be returned at the end
	loc splitter `r(splitter)'
	loc training `r(training)'
	loc validation `r(validation)'
	loc testing `r(testing)'
	loc stype `r(stype)'
	loc flavor `r(flavor)'
	loc forecastset `r(forecastset)'
	
	// Call the command to fit the model to the data
	fitit `"`cmd'"', `split' `results' `kfold' `all'
	
	// Capture the macros that get returned
	loc estresnames `e(estres)'
	loc estresall `e(estresall)'
	
	// Predict the outcomes using the model fits
	predictit, `pstub' `split' `classes' `kfold' `threshold' `all' `pmethod' 
	
	// Compute the validation metrics for the LOO sample
	validateit, `metric' `pred' `split' `monitors' `display' `kfold' `all' loo
	
	// Get the arguments passed to monitors
	mata: getarg("`monitors'")
	
	// If there are monitors, loop over them
	if !mi(`"`argval'"') {
		
		// Loop over all the monitors
		foreach m of loc argval {
			
			// Return the scalars from the monitors for each iteration
			eret scalar `m'1 = `r(`m'1)'
			
		} // End Loop over the monitors

	} // End IF Block to test for presence of monitors
	
	// Return the metrics
	eret scalar metric1 = `r(metric1)'
		
	// Test if the user allowed computation on the full training set
	if mi("`all'") {
		
		// If there are monitors, loop over them
		if !mi(`"`argval'"') {
			
			// Loop over all the monitors
			foreach m of loc argval {
				
				// Return the scalars from the monitors for the full training set
				eret scalar `m'all = `r(`m'all)'
				
			} // End Loop over the monitors

		} // End IF Block to test for presence of monitors
		
		// Return the metric for the full training set
		eret scalar metricall = `r(metricall)'
		
	} // End IF Block to return scalars from the full training set

	// Need to handle cleanup for any stuff we generate that the user doesn't 
	// want to keep at this point.
	
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
	eret loc splitter = "`splitter'"
	eret loc training = "`training'"
	eret loc validation = "`validation'"
	eret loc testing = "`testing'"
	eret loc stype = "`stype'"
	eret loc flavor = "`flavor'"
	eret loc forecastset = "`forecastset'"

	// Test if we need to drop results
	if mi(`"`dropresults'"') {
	
		// If the user wanted to retain results (e.g., passed a value to results)
		// Then return these macros
		eret loc estresnames = "`estres'"
		eret loc estresall = "`estresall'"
		
	} // End IF Block to return estimation result names if user wanted them

	// If the user didn't provide an argument to results
	else {
		
		// Remove the estimation results from the dataset
		`dropresults'
		
	} // End ELSE Block to clean up estimation results from the dataset
	
	// Remember to repost results
	ereturn repost 

// End definition of ttsplit prefix command	
end 

	