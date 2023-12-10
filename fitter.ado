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
	syntax anything(name = cmd id="estimation command name"), 				 ///   
			Classes(integer) [ RESults(string asis) Kfold(integer 0) 		 ///   
			MEtric(passthru) MONitors(passthru) ]
	
	// Check whether this requires iteration over kfolds
	if `kfold' == 0 {
		
		// Call the estimation command passed by the user
		`cmd'
		
		// Check if results should be stored
		if `"`results'"' != "" est sto `results'
		
		// Call program/subroutine to handle the validation portion of things
		
		
	} // End IF Block for non-KFold CV cases
	
	// For KFold CV
	else {
		
		
	} // End ELSE block for KFold CV
	
	
// End definition of the command
end

// Subroutine for 
prog def 
