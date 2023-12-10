/*******************************************************************************
*                                                                              *
*             Handles the validation/testing part of the process               *
*                                                                              *
*******************************************************************************/

*! validate
*! v 0.0.1
*! 08DEC2023

// Drop program from memory if already loaded
cap prog drop validate

// Define program
prog def validate, rclass properties(kfold)

	// Version statement 
	version 18
	
	// Syntax
	syntax , MEtric(string asis) [ MOnitors(string asis) ]
	

	
// End of program definition
end

	