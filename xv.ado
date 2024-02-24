/*******************************************************************************
*                                                                              *
*                Cross-Validation for Stata Estimation Commands                *
*                                                                              *
*******************************************************************************/

*! xv
*! v 0.0.3
*! 24FEB2023

// Drop program from memory if already loaded
cap prog drop xv

// Defines the program; properties lists the applicable options for this prefix 
// The tpoint option is only valid for panel/time-series cross-validation
prog def xv, eclass properties(prefix xv)

	// Stata version statement, can check for backwards compatibility later
	version 18

	// Set the prefix name for Stata to recognize it
	set prefix xv
	
	// Allocate a tempvars for the unique identifier variable and for other 
	// options to use a default
	tempvar uuid xvtouse

	// Tokenize the input string
	gettoken cv cmd : 0, parse(":") bind 
	
	// Parse the prefix on the comma.  `props' will contain split proportions
	gettoken props xvopts : cv, parse(",") bind
	
	// Remove the leading comma from the options for xv.
	loc xvopts `"`= substr(`"`xvopts'"', 2, .)'"'

	// Then parse the options from the remainder of the macro
	mata: cvparse(`"`xvopts'"')
	
	// Get the value of classes
	mata: getarg("`classes'")
	
	// If missing or the default downstream set the value to 1
	if (mi("`argval'") | "`argval'" == "0") loc c 1
	
	// Otherwise set it to the number of classes being predicted
	else loc c `argval'
	
	// If there is anything in the missing local throw an error message
	if mi(`"`metric'"') | mi(`"`pred'"') {
		
		// Display the error message
		di as err `"You must supply valid arguments to metric and pred "'    ///   
		`"to use the xv prefix."'
		
		// Throw an error code to exit
		err 198
		
	} // End IF Block for missing required parameters
		
	// Test if results is missing a value
	if mi(`"`results'"') {
		
		// Set a default to use for the results
		loc results "results(xvres)"
		
		// Set a macro to automatically clean this up at the end
		if mi("`retain'") loc dropresults "estimates drop xvres*"
		
	} // End IF Block to set default results values
	
	// If missing the split option
	if mi(`"`split'"') {
		
		// use the tempvar
		loc split "split(_xvsplit)"
		
	} // End IF Block for the split variable name
	
	// Parses the split option
	mata: getarg("`split'")
	
	// Assigns the argument value to spvar
	loc spvar `argval'
	
	// Check to see if the split variable already exists
	cap confirm new v `spvar'
	
	// If the variable already exists set the do split local to 0
	if _rc != 0 loc dosplit 0
	
	// If it doesn't exist set do split to 1
	else loc dosplit 1
		
	// Parses the pstub option
	mata: getarg("`pstub'")
	
	// If the user does not want to retain variables
	if mi("`retain'") loc dropvars `spvar' `argval'*
		
	// Check to see if predict stub variable is present
	cap confirm new v `argval'all
	
	// If the variable exists
	if _rc != 0 {
		
		// Display an error message
		di as err "The variable `argval'all already exists.  You can drop "  ///
		"the variable, or specify a new predict value stubname." 
		
		// Throw an error and exit
		err 110
		
	} // End IF Block for existing `pstub'all variable
		
	// Check to see if the predicted variable is present
	cap confirm new v `argval'
	
	// If the variable exists
	if _rc != 0 {
		
		// Display an error message
		di as err "The variable `argval' already exists.  You can drop "     ///
		"the variable, or specify a new predict value stubname." 
		
		// Throw an error and exit
		err 110
		
	} // End IF Block for existing `pstub'all variable
			
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
		mata: st_local("cmd", subinstr(`cmd', `"`ifin'"', " if `xvtouse' == 1"))		
		
	} // End IF Block for in expression handling

	// Check for if/in conditions
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
	
	// If the split variable is not already present split the data
	if `dosplit' {

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
		
	} // End IF Block for optional splitting

	// Call the command to fit the model to the data
	fitit `"`cmd'"', `split' `results' `kfold' `all' `display'
	
	// Capture the macros that get returned
	loc estresnames `e(estres)'
	loc estresall `e(estresall)'
	
	// Predict the outcomes using the model fits
	predictit, `pstub' `split' `classes' `kfold' `threshold' `all' `pmethod' 
	
	// Compute the validation metrics for the LOO sample
	validateit, `metric' `pstub' `split' `monitors' `display' `kfold' `all'
	
	// Loops over the names of the scalars created by validate it
	foreach i in `r(allnames)' {
		
		// Returns all of the scalars in e()
		eret sca `i' = r(`i')
		
	} // End Loop over the returned scalars
	
	// Need to assign returned matrix to a new matrix
	mat xv = r(xv)
	
	/*
	For any optional arguments where we will set defaults (e.g., split variable 
	name, etc...) we need to clean those up (e.g., if the user doesn't want to 
	retain the split variable we need to drop it prior to exiting the command)
	*/
	
	// If the user doesn't want to retain the results
	if mi(`"`retain'"') {
	
		// Drop the stored estimation results
		`dropresults'
		
		// Drop the variables created by xvloo
		drop `dropvars'
		
		// Clears all of the characteristics that may have been set 
		char _dta[rng]
		char _dta[rngcurrent]
		char _dta[rngstate]
		char _dta[rngseed]
		char _dta[rngstream]
		char _dta[filename]
		char _dta[filedate]
		char _dta[version]
		char _dta[currentdate]
		char _dta[currenttime]
		char _dta[stflavor]
		char _dta[processors]
		char _dta[hostname]
		char _dta[machinetype]
		char _dta[predifin]
		char _dta[kfpredifin]
		char _dta[modcmd]
		char _dta[kfmodcmd]
			
	} // End IF Block remove results generated by the program

	// If the user wants to retain the results
	else {
		
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

		// Return the macros from splitit
		eret loc splitter = "`splitter'"
		eret loc training = "`training'"
		eret loc validation = "`validation'"
		eret loc testing = "`testing'"
		eret loc stype = "`stype'"
		eret loc flavor = "`flavor'"
		eret loc forecastset = "`forecastset'"

		// Then return the macros from fitit
		eret loc estresnames = "`estres'"
		eret loc estresall = "`estresall'"
	
	} // End ELSE Block to return a few extra macros related to stored results
	
	// Remember to repost results
	ereturn repost 
	
	// Returns the matrix containing all of the validation/test metrics and 
	// monitors
	eret mat xv = xv

// End definition of ttsplit prefix command	
end 	

	