/*******************************************************************************
*                                                                              *
*                    Mata library for -crossvalidate- package                  *
*                                                                              *
*******************************************************************************/



// Starts mata interpreter
mata:

// A function to retrieve an if/in expression from an estimation command.  The 
// value is returned in a Stata local macro named `ifin' and will be missing if 
// no if or in conditions were included in the command passed to the function.
string scalar getifin(string scalar x) {
	
	// Used to store the result from testing the match for the regular expression
	real scalar matched
	
	// Contains the if/in expression from the command that will be modified
	string scalar strexp
	
	// Tests if there is an if/in expression in the estimation command
	matched = regexmatch(x, " i[fn]{1}\s+.*?(?=, *[a-zA-Z]|\$)")
	
	// If there is an expression in the estimation command
	if (matched) {
		
		// Stores the expression in strexp
		strexp = regexcapture(0)
		
	// If there isn't a match	
	} else {
		
		// Stores an empty string
		strexp = ""
		
	} // End ELSE block from testing for presence of if/in expression
	
	// Stores the if/in expression in the local macro ifin
	st_local("ifin", strtrim(strexp))
	
	// Returns the matched string
	return(strexp)
	
} // End of Mata function definition to retrieve if/in expressions from command

// Defines a function to parse and return the command string up to the comma 
// that starts specification of options.  This is needed for cases where no if 
// or in statements are included in the estimation command to insert the 
// appropriate if statement to fit the model to the training data only.
string scalar getnoifin(string scalar x) {
	
	// Used to store the result from testing the match for the regular expression
	real scalar matched
	
	// Contains the if/in expression from the command that will be modified
	string scalar strexp
	
	// Tests the regular expression that will capture everything up to options
	matched = regexmatch(x, "^(.*?)(?![^()]*\)),")
	
	// If there is a comma not enclosed in parentheses
	if (matched) {
		
		// Return the syntax up to the comma that starts the options
		strexp = regexcapture(1)

	// If this doesn't result in a match
	} else {
		
		// We'll assume no options are specified and return the string 
		strexp = x
		
	} // End ELSE Block for cmd string w/o options
	
	// Returns the string upto
	st_local("noifin", strexp)
	
	// Returns the matched string
	return(strexp)
	
} // End of function definition to return the cmd string up to the options

// Defines a function used to replace the if/in expression in the command with 
// the version that would be used to identify the training set
void function repifin(string scalar x, string scalar swap) {
	
	// Stores the new string prior to returning it in a macro
	string scalar newcmd
	
	// Replaces the existing if/in statement with the swapped statement
	newcmd = ustrregexra(x, "(i[fn]{1}\s+[^,]+)", swap)
	
	// Returns the new command statement 
	st_local("newcmd", newcmd)
	
} // End of definition of Mata function to replace if/in expression in command

// Defines a function to parse the prefix command into it's constituent parts
void function cvparse(string scalar cv) {
	
	// Defines a string vector with the names of the potential options
	string rowvector opts 
	
	// Defines a variable to use for iterating over the options
	real scalar i, nopts
	
	// Stores the name of all the potential options
	opts = ("metric", "monitors", "uid", "tpoint", "retain", "kfold", 		 ///   
			 "state", "results", "grid", "params", "tuner", "seed", "classes" )
	
	// Gets the number of options so we don't need to track it manually and 
	// avoid the minor performance penalty of using cols(opts) in the loop below
	nopts = cols(opts)
	
	// Loop over the index values for each of the options 
	for(i = 1; i <= nopts; i++) {
		
		// Test for matches for each of the options
		if (ustrregexm(cv, "(" + opts[1, i] + "\([a-zA-Z0-9]+\))", 1)) {
			
			// Returns the option name and argument(s) in a local with the same 
			// name (e.g., kfold might contain kfold(10))
			st_local(opts[1, i], ustrregexs(1))
			
		} // End IF block for identified options
		
	} // End loop over the option indices
	
} // End of function definition to parse prefix options for crossvalidate package

// Defines a function to retrieve the argument(s) passed to a parameter with an 
// option to pass the name of the parameter; It might be worth considering using 
// an AssociativeArray object for the return value where the key would be the 
// parameter name and the value could be the argument passed to the parameter.
// This would avoid calling this on each possible parameter, but would mean we 
// would need to keep track of that object on the Mata stack.
void function getarg(string scalar param, | string scalar pname) {
	
	// String scalar to store the argument(s)
	string scalar retval
	
	// If the parameter name is supplied to the function
	if (args() == 2) {
		
		// subinstr removes the parameter name, and regex replace should remove
		// the parentheses
		retval = ustrregexra(subinstr(param, pname, ""), "[\(\)]", "")
	
	// If the parameter name is not supplied to the function
	} else {
		
		// Removes everything up to the opening parentheses with the regex, then 
		// removes the closing parenthesis with subinstr
		retval = subinstr(ustrregexra(param, "[a-z]+\(", ""), ")", "")
		
	} // End ELSE Block for no parameter name supplied
	
	// Returns the argument value in a local macro
	st_local("argval", retval)
	
} // End of function definition to get argument value from a parameter

// Create a function to return a confusion matrix from the predicted/observed 
// value variables and a third variable to identify which records to subset.  
// We'll use this same signature for all metrics and monitors to make it easier 
// for others to create their own metrics/monitors as well.  The difference is 
// that metrics and monitors should generally return a scalar.
real matrix confusion(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Initialize matrix to store the confusion matrix
	real matrix conf
	
	// Create and call the tabulation command
	stata("ta " + pred + " " + obs + " if " + touse + ", matcell(c)", 1)

	// Access the Stata matrix with the confusion matrix
	conf = st_matrix("c")
	
	// Return the confusion matrix
	return(conf)
	
} // End function definition for confusion matrix

// Can define each of the common metrics/monitors for binary prediction, based 
// on passing the arguments for the confusion matrix.  There will be additional 
// computational overhead this way, but we could also consider coding around 
// this so we would return the confusion matrix to a Mata object and then do the 
// subsequent computations on the single confusion matrix.

// For sensitivity, specificity, prevalence, ppv, and npv see:
// https://yardstick.tidymodels.org/reference/ppv.html	
// For others in this section see other pages from above			
real scalar sensitivity(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Creates the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// For now, at least, we'll restrict these metrics to only the binary case
	// so this assertion will make sure that we have a binary confusion matrix
	assert(rows(conf) == 2 & cols(conf) == 2)
	
	// Computes the metric from the confusion matrix
	result = conf[2, 2] / colsum(conf[, 2])
	
	// Returns the metric as a scalar
	return(result)
	
} // End of function definition for sensitivity
					
// Function to compute precision from a confusion matrix.  See:
// https://yardstick.tidymodels.org/reference/precision.html for the formula
real scalar precision(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Creates the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// For now, at least, we'll restrict these metrics to only the binary case
	// so this assertion will make sure that we have a binary confusion matrix
	assert(rows(conf) == 2 & cols(conf) == 2)
	
	// Computes the metric from the confusion matrix
	result = conf[2, 2] / rowsum(conf[2, ])

	// Returns the metric
	return(result)
	
} // End of function definition for precision

// Function to compute recall, which appears to be a synonym for sensitivity.  
// See https://yardstick.tidymodels.org/reference/precision.html for formula					  
real scalar recall(string scalar pred, string scalar obs, string scalar touse) {
		
	// Declares a scalar to store the result
	real scalar result
	
	// Recall is a synonym for sensitivity, so it just calls that function
	result = sensitivity(pred, obs, touse)
	
	// Returns the metric
	return(result)
	
} // End of function definition for recall
				
// Defines function to compute specificity from a confusion matrix.  
// See: https://yardstick.tidymodels.org/reference/ppv.html for the formula
real scalar specificity(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Creates the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// For now, at least, we'll restrict these metrics to only the binary case
	// so this assertion will make sure that we have a binary confusion matrix
	assert(rows(conf) == 2 & cols(conf) == 2)
	
	// Computes the metric from the confusion matrix
	result = conf[1, 1] / colsum(conf[, 1])
	
	// Returns the metric
	return(result)
	
} // End of function definition for specificity

// Defines a function to compute prevalence.  
// See: https://yardstick.tidymodels.org/reference/ppv.html for the formula
real scalar prevalence(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Creates the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// For now, at least, we'll restrict these metrics to only the binary case
	// so this assertion will make sure that we have a binary confusion matrix
	assert(rows(conf) == 2 & cols(conf) == 2)
	
	// Computes the metric from the confusion matrix
	result = colsum(conf[, 2]) / sum(conf)

	// Returns the metric
	return(result)
	
} // End of function definition for prevalence

// Defines a function to compute positive predictive value.
// See: https://yardstick.tidymodels.org/reference/ppv.html for the formula
real scalar ppv(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric, sensitivity, 
	// specificity, and prevalence (used to compute the metric)
	real scalar result, sens, spec, prev
	
	// Computes sensitivity 
	sens = sensitivity(pred, obs, touse)
	
	// Computes prevalence
	prev = prevalence(pred, obs, touse)
	
	// Computes specificity
	spec = specificity(pred, obs, touse)
	
	// Computes positive predictive value
	result = (sens * prev) / ((sens * prev) + ((1 - spec) * (1 - prev)))
	
	// Returns the metric
	return(result)
	
} // End of function definition for positive predictive value

// Defines a function to compute negative predictive value.
// See: https://yardstick.tidymodels.org/reference/ppv.html for the formula
real scalar npv(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric, sensitivity, 
	// specificity, and prevalence (used to compute the metric)
	real scalar result, sens, spec, prev
	
	// Computes sensitivity 
	sens = sensitivity(pred, obs, touse)
	
	// Computes prevalence
	prev = prevalence(pred, obs, touse)
	
	// Computes specificity
	spec = specificity(pred, obs, touse)
	
	// Computes negative predictive value
	result = (spec * (1 - prev)) / (((1 - sens) * prev) + (spec * (1 - prev)))
	
	// Returns the metric
	return(result)
	
} // End of function definition for negative predictive value

// Defines a function to compute accuracy.
real scalar accuracy(string scalar pred, string scalar obs, 				 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Creates the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// For now, at least, we'll restrict these metrics to only the binary case
	// so this assertion will make sure that we have a binary confusion matrix
	assert(rows(conf) == 2 & cols(conf) == 2)
	
	// Computes the metric from the confusion matrix
	result = sum(diagonal(conf)) / sum(conf)

	// Returns the metric
	return(result)
	
} // End of function definition for accuracy

// Defines a function to compute "balanced" accuracy.  
// See https://yardstick.tidymodels.org/reference/bal_accuracy.html for more info
real scalar bal_accuracy(string scalar pred, string scalar obs, 			 ///   
					  string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric, sensitivity, 
	// specificity, and prevalence (used to compute the metric)
	real scalar result, sens, spec, prev
	
	// Computes sensitivity 
	sens = sensitivity(pred, obs, touse)
	
	// Computes specificity
	spec = specificity(pred, obs, touse)
	
	// Computes "balanced" accuracy as the average of sensitivity and specificity
	result = (sens + spec) / 2
	
	// Returns the metric
	return(result)
	
} // End of function definition for balanced accuracy

// Defines function to compute the F1 statistic
// Based on second equation here: https://www.v7labs.com/blog/f1-score-guide
real scalar f1(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares a scalar to store the resulting metric, precision, and recall
	real scalar result, prec, rec

	// Computes precision
	prec = precision(pred, obs, touse)

	// Computes recall
	rec = recall(pred, obs, touse)
	
	// Computes the f1 score 
	result = (2 * prec * rec) / (prec + rec)
	
	// Returns the metric
	return(result)
	
} // End of function definition for f1score

// Defines function to compute mean squared error from predicted and observed 
// outcomes
real scalar mse(string scalar pred, string scalar obs, string scalar touse) {
	
	// Column vector to store the squared difference of pred - obs
	real colvector sqdiff
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Computes squared differences
	sqdiff = (st_data(., obs, touse) - st_data(., pred, touse)) :^2
	
	// Computes the average of the squared differences
	result = sum(sqdiff) / rows(sqdiff)
	
	// Returns the mean squared error
	return(result)

} // End of function definition for MSE

// Defines function to compute mean absolute error from predicted and observed 
// outcomes
real scalar mae(string scalar pred, string scalar obs, string scalar touse) {
	
	// Column vector to store the absolute difference of pred - obs
	real colvector absdiff
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Computes absolute differences
	absdiff = abs(st_data(., obs, touse) - st_data(., pred, touse))
	
	// Computes the average of the squared differences
	result = sum(absdiff) / rows(absdiff)
	
	// Returns the mean absolute error
	return(result)

} // End of function definition for MAE

// Metric based on definition here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar bias(string scalar pred, string scalar obs, string scalar touse) {
	
	// Returns the sum of residuals
	return(sum(st_data(., obs, touse) - st_data(., pred, touse)))
	
} // End of function definition for bias

// Metric based on definition here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar mbe(string scalar pred, string scalar obs, string scalar touse) {
	
	// Returns the sum of residuals
	return(sum(st_data(., obs, touse) - st_data(., pred, touse)) /			 ///   
		   rows(st_data(., obs, touse)))
	 
} // End of function definition for mean bias error

// Metric based on definition here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar r2(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a scalar to store the residual sum of squares, total 
	// sum of squares, and mean of the observed outcome.
	real scalar rss, tss, muob
	
	// Computes squared differences
	rss = sum((st_data(., obs, touse) - st_data(., pred, touse)) :^2)
	
	// Computes the mean of the observed outcome
	muob = sum(st_data(., obs, touse)) / rows(st_data(., obs, touse))
	
	// Computes the total sum of squares
	tss = sum((st_data(., obs, touse) :- muob) :^2)
	
	// Returns 1 - RSS / TSS
	return(1 - (rss / tss))
	
} // End of function definition for R^2

// Creates function for root mean squared error
real scalar rmse(string scalar pred, string scalar obs, string scalar touse) {

	// Returns the square root of the mean squared error
	return(sqrt(mse(pred, obs, touse)))

} // End of function definition for RMSE

// Metric based on definition of mean absolute percentage error here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar mape(string scalar pred, string scalar obs, string scalar touse) {

	// Allocates a column vector to store the differences
	real colvector diff
	
	// Computes the residuals
	diff = st_data(., obs, touse) - st_data(., pred, touse)
	
	// Returns the sum of the absolute value of the residual divided by observed 
	// value, which is then divided by the number of observations
	return(sum(abs(diff :/ st_data(., obs, touse))) / rows(st_data(., obs, touse)))
	
} // End of function definition for mean absolute percentage error


// Metric based on definition of symmetric mean absolute percentage error here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar smape(string scalar pred, string scalar obs, string scalar touse) {

	// Allocates a column vector to store the differences
	real colvector diff, obd
	
	// Creates a column vector with the observed outcome data
	obd = st_data(., obs, touse)
	
	// Computes the residuals
	diff = obd - st_data(., pred, touse)
	
	// Returns the sum of the absolute value of the residual divided by observed 
	// value, which is then divided by the number of observations
	return(sum(abs(diff) / (0.5 * (obd + st_data(., pred, touse)))) / 	 ///   
			rows(obd))
	
} // End of function definition for mean absolute percentage error

// Defines function to compute mean squared log error from predicted and observed 
// outcomes.  Based on definition here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar msle(string scalar pred, string scalar obs, string scalar touse) {
	
	// Column vector to store the squared difference of pred - obs
	real colvector sqdiff
	
	// Declares a scalar to store the resulting metric
	real scalar result
	
	// Computes squared differences
	sqdiff = (log(st_data(., obs, touse)) - log(st_data(., pred, touse))) :^2
	
	// Computes the average of the squared differences
	result = sum(sqdiff) / rows(sqdiff)
	
	// Returns the mean squared error
	return(result)

} // End of function definition for mean squared log error

// Defines function to compute the root mean squared log error.  Based on 
// definition here:
// https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
real scalar rmsle(string scalar pred, string scalar obs, string scalar touse) {

	// Returns the square root of the mean squared log error
	return(sqrt(msle(pred, obs, touse)))
	
} // End of function definition for root mean squared log error

// End mata interpreter
end

