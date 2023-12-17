/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! splitter
*! v 0.0.1
*! 17DEC2023

// Drop program from memory if already loaded
cap prog drop splitter

// Define program
prog def splitter, rclass properties(kfold uid tpoint retain) 

	// Version statement 
	version 18
	
	// Syntax for the splitter subroutine
	syntax anything(name = props id = "Split proportion(s)") [if] [in] [, 	 ///   
		   Uid(varname) TPoint(real -999) KFold(integer 0) RETain(string asis) ]
	
	// Mark the sample to handle any if/in arguments (can now pass if `touse') 
	// for the downstream work to handle user specified if/in conditions.
	marksample touse
	
	// First we'll check/verify that appropriate arguments are passed to the 
	// parameters and handle as much defensive stuff up front as possible.
	// Tokenize the first argument
	gettoken train valid: props
	
	// Set a macro for label use later to define the type of splitting
	if `: word count `props'' == 1 loc stype "Train/Test Split"
	
	// If there are two thresholds it is tvt
	if `: word count `props'' == 2 loc stype "Train/Validate/Test Split"
	
	// Define the flavor of the splits based on how the units are allocated
	if !mi(`"`uid'"') & `tpoint' != -999 loc flavor "Clustered & Panel Sampling"
	else if !mi(`"`uid'"') & `tpoint' == -999 loc flavor "Clustered Sampling"
	else if mi(`"`uid'"') & `tpoint' != -999 loc flavor "Panel Unit Sampling"
	else loc flavor "Simple Random Sample"
	
	// Allocate tempname for xt/group splitting
	tempvar tag sgrp sgrp2 uni
	
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
		
		// Retain the panel and time variables
		loc ivar `r(panelvar)'
		loc tvar `r(timevar)'
		
		// Test if the `uid' parameter has an argument and if so if it includes 
		// the panel variable, when there is a panel variable
		if !mi(`"`uid'"') & !`: list ivar in uid' & !mi(`"`ivar'"') {
			
			// Could handle this in a couple of ways.  We could either add the 
			// panel variable to the `uid' value, or could issue an error to 
			// tell the users to include that variable in the variable list 
			// passed to uid.  I'd go with the error to make sure that it is 
			// clear to them instead of adding it under the hood.
			di as err "When passing variables to uid with panel/timeseries " ///   
			"data, you must include the panel identifier in uid to ensure "  ///   
			"valid splits of the panel data."
			
			// Return error code
			error 100
			
		} // End IF Block for missing panel var in uid 
		
	} // End IF Block to check for the time point option
	
	/***************************************************************************
	* This is the section where we create a marker to identify how we will     *
	* split the records.  For hierarchical/panel data, we need to assign whole *
	* clusters of observations, while cross-sectional data can split the all   *
	* of the records.  The temporary variable `tag' is used to mark the obs in *
	* conjunction with any if/in expressions passed by the user.               *
	***************************************************************************/
	
	// Test for presence of sampling unit id if provided
	if !mi(`"`uid'"') {
		
		// Confirm the variable exists and let this handle returning the error 
		confirm v `uid'
		
		// Test if time point is also listed to determine how to tag records
		// If there is a time point, that should be included in the if condition
		if `tpoint' != -999 egen byte `tag' = tag(`uid') if `touse' & `tvar' <= `tpoint'
		
		// This will handle hierarchical cases as well
		else byte egen `tag' = tag(`uid') if `touse'
		
	} // End IF Block to verify variable in uid if specified
	
	// Handle the case where we use the xtset info for the xt case
	if mi(`"`uid'"') & `tpoint' != -999 {
		
		// Create the tag variable using the panel var if panel data
		if !mi(`"`ivar'"') egen byte `tag' = tag(`ivar') if `touse' & 		 ///   
															`tvar' <= `tpoint'

		// Otherwise, create the tag for the timeseries including all obs 
		else g byte `tag' = 1 if `touse' & `tvar' < `tpoint'
		
	} // End IF block for xtset based splits
	
	// Create the tag variable for non xt/hierarchical cases
	g byte `tag' = 1 if `touse' 
	
	// Generate a random uniform in [0, 1] for the tagged observations
	g double `uni' = runiform() if `touse' & `tag' == 1
	
	/***************************************************************************
	* This is the section where the splits get defined now that we've ID'd the *
	* way we will allocate the observations/clusters.                          *
	***************************************************************************/
	
	// For the kfold case, we'll use xtile on the random uniform to create the 
	// groups
	if `kfold' != 0 {
		
		// Generate the split group tempvar to create `kfold' equal groups
		xtile `sgrp' = `uni' if `touse' & `tag' == 1 & `uni' <= `train', 	 ///   
		n(`kfold')
		
		// Define the training splits
		loc trainsplit 1(1)`kfold'
				
		// Set number of levels for the splits
		deflabs, val(`trainsplit') t(Training)
		
		// If there is no validation split 
		if mi(`valid') {
			
			// Define the test split
			loc testsplit `= `kfold' + 1'
			
			// Add the testsplit ID to the variable for the test cases
			qui: replace `sgrp' = `testsplit' if `touse' & `tag' == 1 & 	 ///   
												 `uni' > `train' & !mi(`uni')
			
			// Generate the value label for the test split
			deflabs, val(`testsplit') t(Test)
			
		} // End IF Block for KFold CV train/test split
		
	} // End IF block to handle splitting the training set
	
	// If the user also wants to use kfold for a validation set as well:
	if `kfold' != 0 & !mi(`valid') {
		
		// Generate the split group tempvar to create `kfold' equal groups
		xtile `sgrp2' = `uni' if `touse' & `tag' == 1 & (`uni' > `train' &	 ///   
		`uni' <= `valid') n(`kfold')
		
		// Update these values to occur sequentially after the training IDs
		qui: replace `sgrp2' = `sgrp2' + `kfold'
		
		// Summarize this variable to get min/max values
		qui: su `sgrp2'
		
		// Set starting value for the sequence
		loc sval `r(min)'
		
		// Set the ending value for the sequence
		loc eval `r(max)'
		
		// Create a macro with the validation splits
		loc validsplit `sval'(1)`eval'
		
		// Set the value for the test set
		loc testsplit `= `eval' + 1'
		
		// Add the value of `kfold' to `sgrp2' in order to store the splits in 
		// a single variable that are distinct from the training set
		qui: replace `sgrp' = `sgrp2' if `touse' & `tag' == 1 & mi(`sgrp') & ///   
										 !mi(`sgrp2')
		
		// Add the test split ID to the sgrp temp variable
		qui: replace `sgrp' = `testsplit' if `touse' & `tag' == 1 & mi(`sgrp')
		
		// Generate value labels for the validation set
		deflabs, val(`validsplit') t(Validation)
		
		// Generate value labels for the test set
		deflabs, val(`testsplit') t(Test)
		 	
	} // End IF Block for kfold CV with validation and test splits
	
	// For the other cases we can generate the train and validation splits 
	// collectively
	if !mi(`valid') {
		
		// Create the split indicator for the training, validation, and test set
		g byte `sgrp' = cond(`touse' & `tag' == 1 & `uni' <= `train', 1, 	 ///   
						cond(`touse' & `tag' == 1 & `uni' > `train' & 		 ///   
							 `uni' <= `valid' & !mi(`uni'), 2, 				 ///   
						cond(`touse' & `tag' == 1 & `uni' > `valid' & 		 ///   
							 !mi(`uni'), 3, .)))
		
		// Generate value labels for the training set ID					 
		deflabs, val(1) t(Training)
		
		// Generate value labels for the validation set ID
		deflabs, val(2) t(Validation)
		
		// Generate value labels for the test set ID
		deflabs, val(2) t(Test)
							 						
	} // End IF block for train/validation/test splits
	
	// If this is only a train/test split situation
	else {
		
		// Create the split indicator for training and test sets
		g byte `sgrp' = cond(`touse' & `tag' == 1 & `uni' <= `train', 1, 	 ///  
						cond(`touse' & `tag' == 1 & `uni' > `train' & 		 ///   
							 !mi(`uni'), 2, .))

		// Generate value labels for the training set ID					 
		deflabs, val(1) t(Training)
		
		// Generate value labels for the test set ID
		deflabs, val(2) t(Test)
							 
	} // End ELSE Block for train/test split
		
	/***************************************************************************
	* This is the section where we will handle populating the split ID record  *
	* for cases involving hierarchical/custered sampling, panel/timeseries, &  *
	* combinations of the two cases, since we only assigned split IDs to a     *
	* single record per cluster/group above.                                   *
	***************************************************************************/
	
	// Handle populating the split ID for hierarchical cases/clustered splits
	if !mi(`uid') & `tpoint' == -999 {

		// This should fill in the split group ID assignment for the case of 
		// hierarchical splitting
		bys `uid' (`sgrp'): replace `sgrp' = `sgrp'[_n - 1] if `touse' &	 ///   
							mi(`sgrp'[_n]) & !mi(`sgrp'[_n - 1]) 
										
	} // End IF Block to fill things in for hierarchical splits
	
	// Handle the case where these is timeseries/panel data without `uid' passed
	else if !mi(`uid') & `tpoint' != -999 {
		
		// This should fill in the split group ID assignment for the case of 
		// hierarchical splitting
		bys `uid' (`sgrp'): replace `sgrp' = `sgrp'[_n - 1] if `touse' &	 ///   
							mi(`sgrp'[_n]) & !mi(`sgrp'[_n - 1]) & 		 	 ///   
							`tvar' <= `tpoint'
												
	} // End ELSEIF block for timeseries/panel with specified clustering
	
	// Handle timeseries/panel case without additional hierarchy specified
	else if mi(`uid') & `tpoint' != -999 & !mi(`"`ivar'"') {
		
		// This should fill in the split group ID assignment for the case of 
		// hierarchical splitting
		bys `ivar' (`sgrp'): replace `sgrp' = `sgrp'[_n - 1] if `touse' &	 ///   
							mi(`sgrp'[_n]) & !mi(`sgrp'[_n - 1]) & 		 	 ///   
							`tvar' <= `tpoint'

	} // End ELSEIF Block for panel/timeseries data with a specified panel var
	
	// Create a variable label for the split IDs
	la var `sgrp' `"`stype' Identifiers"'
	
	// For the last step we'll move the values from the tempvar into the 
	// permanent variable (which could have happened earlier)
	clonevar `retain' = `sgrp' if `touse'
	
	// Apply the value label to the split group variable
	la val `retain' _splitter
	
	// Set an r macro with the variable name with the split variable to make 
	// sure it can be cleaned up by the calling command later in the process
	ret loc splitter = `retain'
	
	// Return the IDs that identifies the training splits
	ret loc training = `trainsplit'
	
	// Return the IDs that identifies the validation splits
	ret loc validation = `validsplit'
	
	// Return the ID that identifies the test split
	ret loc testing = `testsplit'
	
	// Return the type of split
	ret loc stype = `stype'
	
	// Return the flavor of the split
	ret loc flavor = `flavor'
	
// End of program definitions	
end


// Subroutine to define value labels for the split identifier
prog def deflabs

	// Declares the syntax for this subroutine
	syntax, VALues(numlist integer min = 1 > 0) Type(string asis) 
	
	// If there is only a single ID passed to the command generate this style of 
	// value label for that split type
	if `: word count `values'' == 1 la def _splitter `values' "`type' Split", modify
	
	// If multiple ID values are passed loop over them and construct the split 
	// labels like this
	else {
		
		// Loop over the values in the numlist
		foreach i in `values' {
			
			// Generate a new value label with the split IDs
			la def _splitter `i' "`type' Split #`i'", modify
			
		} // End Loop over the range
		
	} // End ELSE Block for multiple values
	
// End sub-sub-routine for other label types	
end

