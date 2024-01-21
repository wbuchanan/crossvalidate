/*******************************************************************************
*                                                                              *
*             Handles fitting the models and returning results                 *
*                                                                              *
*******************************************************************************/

*! fitter
*! v 0.0.1
*! 08DEC2023

// Drop program from memory if already loaded
cap prog drop fitter

// Define program
prog def fitter, eclass properties(kfold)

	// Version statement 
	version 18
	
	// Syntax
	syntax anything(name = cmd id="estimation command name") [, 			 ///   
			Classes(integer 0) RESults(string asis) Kfold(integer 0) 		 ///   
			MEtric(passthru) MONitors(passthru) RESTItle(string asis) 		 ///   
			RESNotes(string asis) DISplay ]
	
	// Check whether this requires iteration over kfolds
	if `kfold' == 0 {
		
		// Allocate a tempname
		tempname mod modesamp
		
		// Call the estimation command passed by the user
		`cmd'
		
		// Hold the estimation results
		_estimates hold `mod', n var(`modesamp') c r
		
		// Check if results should be stored
		if `"`results'"' != "" {
			
			// Stores the estimation results in a more persistent way
			est sto `results'
			
			// Test if user wants title added
			if !mi(`"`restitle'"') est title: `restitle' 
			
		} // End of IF Block for persistent storage of estimation results
		
		// Call program/subroutine to handle the validation portion of things
		// validate if , `metric' `monitors' 
		
		// Repost the estimation results to return them to users
		ereturn repost
		
	} // End IF Block for non-KFold CV cases
	
	// For KFold CV
	else {
		
		
	} // End ELSE block for KFold CV
	
	
// End definition of the command
end

