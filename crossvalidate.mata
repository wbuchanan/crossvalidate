/*******************************************************************************
*                                                                              *
*                    Mata library for -crossvalidate- package                  *
*                                                                              *
*******************************************************************************/


**# Utilities
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

// Defines a function to parse the prefix command into it's constituent parts
void function cvparse(string scalar cv) {
	
	// Defines a string vector with the names of the potential options
	string rowvector opts 
	
	// Defines a variable to use for iterating over the options
	real scalar i, nopts
	
	// Stores the name of all the potential options across all commands
	opts = ("metric", "monitors", "uid", "tpoint", "retain", "kfold", 		 ///   
			 "state", "results", "grid", "params", "tuner", "seed", 		 ///   
			 "classes", "threshold", "pstub", "split", "display", "pred",    ///   
			 "obs", "modifin", "kfifin", "noall")
	
	// Gets the number of options so we don't need to track it manually and 
	// avoid the minor performance penalty of using cols(opts) in the loop below
	nopts = cols(opts)
	
	// Loop over the index values for each of the options 
	for(i = 1; i <= nopts; i++) {
		
		// Test for matches for each of the options
		if (ustrregexm(cv, "(" + opts[1, i] + `"(\([a-zA-Z\p{P}0-9]+\))?)"', 1)) {
			
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
		retval = ustrregexrf(subinstr(param, pname, ""), "[\(\)]", "")
	
	// If the parameter name is not supplied to the function
	} else {
		
		// Removes everything up to the opening parentheses with the regex, then 
		// removes the closing parenthesis with subinstr
		retval = ustrregexrf(ustrregexrf(param, "[a-z]+\(", ""), "\)", "")
		
	} // End ELSE Block for no parameter name supplied
	
	// If the parameter doesn't include any parentheses just return it as is
	if (ustrregexm(param, "[\(\)]") == 0) st_local("argval", param)
	
	// Returns the argument value in a local macro
	else st_local("argval", retval)
	
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

// End Mata interpreter
end

**# Binary Metrics
/*******************************************************************************
*                                                                              *
*                        Binary Classification Metrics                         *
*                                                                              *
*******************************************************************************/

// Start mata
mata: 

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
	
	// Computes the metric from the confusion matrix
	result = sum(diagonal(conf)) / sum(conf)

	// Returns the metric
	return(result)
	
} // End of function definition for accuracy

// Defines a function to compute "balanced" accuracy.  
// See https://yardstick.tidymodels.org/reference/bal_accuracy.html for more info
real scalar baccuracy(string scalar pred, string scalar obs, 				 ///   
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

// Defines J-index (Youden's J statistic)
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-j_index.R
real scalar jindex(string scalar pred, string scalar obs, string scalar touse) {

	// Return the micro averaged detection prevalence
	return(sensitivity(pred, obs, touse) + specificity(pred, obs, touse) - 1)

} // End of function definition for j-index

// Defines a binary R^2 (tetrachoric correlation)
real scalar binr2(string scalar pred, string scalar obs, string scalar touse) {

	// Call the tetrachoric command in Stata
	stata("cap: qui: tetrachoric " + pred + " " + obs + " if " + touse)

	// Returns the correlation coefficient
	return(st_numscalar("r(Rho)"))

} // End of function definition for binary R^2 

// Defines Matthews correlation coefficient
// based on: https://en.wikipedia.org/wiki/Phi_coefficient#Multiclass_case
real scalar mcc(string scalar pred, string scalar obs, string scalar touse) {
		
	// To store the confusion matrix
	real matrix conf
	
	// To store the row margins
	real colvector rowm
	
	// To store the column margins
	real rowvector colm
	
	// Scalars used in the computation
	real scalar i, num, den1, den2
	
	// Stores confusion matrix
	conf = confusion(pred, obs, touse)
	
	// If the confusion matrix isn't square return a missing value.
	if (rows(conf) != cols(conf)) return(.)
	
	// Stores the row margins
	rowm = rowsum(conf)
	
	// Stores the column margins
	colm = colsum(conf)
	
	// Stores the first term for the numerator (correct classified * n)
	num = sum(diagonal(conf)) * sum(conf)
		
	// Initializes the denominator terms
	den1 = sum(conf)^2
	den2 = den1
	
	// Loop over the dimension for the margins
	for(i = 1; i <= rows(rowm); i++) {
		
		// Starts subtracting the true * predicted cell sizes
		num = num - colm[1, i] * rowm[i, 1]
		
		// Subtracts the squared number of predicted cases for each value 
		// from the squared sample size
		den1 = den1 - rowm[i, 1]^2
		
		// Subtracts the squared number of observed cases for each value from 
		// the squared sample size
		den2 = den2 - colm[1, i]^2
		
	} // End Loop over the margins
	
	// Return the correlation coefficient
	return(num / (sqrt(den1) * sqrt(den2)))
	
} // End of function definition for Matthew's correlation coefficent

// End mata
end

**# Multinomial Metrics
/*******************************************************************************
*                                                                              *
*                     Multinomial Classification Metrics                       *
*                                                                              *
*******************************************************************************/

// Start mata
mata:

// Defines multiclass specificity
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-spec.R
real scalar mcspecificity(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares column vectors to store the total sample size in a J(x, 1, n) 
	// sized column vector, , true positive counts,
	// true positive + false positive counts, true positive + false negative 
	// counts, true negative counts, false positives, and the numerator and 
	// denominator for the metric
	real colvector n, tp, tpfp, tpfn, tn, fp, num, den
	
	// Get the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// Store the total sample size in a column vector with the sample size in 
	// each element
	n = J(rows(conf), 1, sum(conf))
	
	// Get the vector of true positives
	tp = diagonal(conf)
	
	// Get the true positive + false positive counts
	tpfp = rowsum(conf)
	
	// Get the true positive + false negative counts and transpose the result
	tpfn = colsum(conf)'
	
	// Get the count of true negatives
	tn = n - (tpfp + tpfn - tp)
	
	// Get the count of false positives
	fp = tpfp - tp
	
	// Return the micro average specificity
	return(sum(tn) / sum((tn + fp)))

} // End of function definition for multiclass specificity

// Defines multiclass sensitivity
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-sens.R
real scalar mcsensitivity(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Get the confusion matrix
	conf = confusion(pred, obs, touse)

	// Return the micro averaged sensitivity
	return(sum(diagonal(conf)) / sum(colsum(conf)))

} // End of function definition for multiclass sensitivity

// Defines multiclass recall
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-recall.R
real scalar mcrecall(string scalar pred, string scalar obs, string scalar touse) {
	
	// Return the micro averaged recall
	return(mcsensitivity(pred, obs, touse))

} // End of function definition for multiclass recall

// Defines multiclass precision
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-precision.R
real scalar mcprecision(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Get the confusion matrix
	conf = confusion(pred, obs, touse)

	// Return the micro averaged precision
	return(sum(diagonal(conf)) / sum(rowsum(conf)))

} // End of function definition for multiclass precision

// Defines multiclass positive predictive value
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-ppv.R
real scalar mcppv(string scalar pred, string scalar obs, string scalar touse) {
	
	// Return the micro averaged PPV
	// Lines 176-178 indicate that multiclass PPV should be equal to precision 
	// in all cases EXCEPT when the prevalence paramter in that function is 
	// passed an argument.  With our method signature, there isn't a way to 
	// pass that parameter.
	return(mcprecision(pred, obs, touse))

} // End of function definition for multiclass positive predictive value

// Defines multiclass negative predictive value
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-npv.R
real scalar mcnpv(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares a matrix to store the confusion matrix
	real matrix conf
	
	// Declares column vectors to store the total sample size in a J(x, 1, n) 
	// sized column vector and true positive + false negative counts
	real colvector n, tpfn

	// Declares scalars to store intermediate results
	real scalar prev, sens, spec, num, den
	
	// Get the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// Store the total sample size in a column vector with the sample size in 
	// each element
	n = J(rows(conf), 1, sum(conf))
	
	// Get the true positive + false negative counts and transpose the result
	tpfn = colsum(conf)'
	
	// Compute prevalence
	prev = sum(tpfn) / sum(n)
	
	// Compute multiclass sensitivity
	sens = mcsensitivity(pred, obs, touse)
	
	// Compute multiclass specificity
	spec = mcspecificity(pred, obs, touse)
	
	// Define the numerator for the metric
	num = spec * (1 - prev)

	// Define the denominator for the metric
	den = (1 - sens) * prev + spec * (1 - prev)
	
	// Return the micro averaged NPV
	return(num / den)

} // End of function definition for multiclass negative predictive value

// Defines multiclass F1 statistic
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-f_meas.R
real scalar mcf1(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares scalars to store intermediate results
	real scalar prec, sens
	
	// Compute prevalence
	prec = mcprecision(pred, obs, touse)
	
	// Compute multiclass sensitivity
	sens = mcsensitivity(pred, obs, touse)
	
	// Return the micro averaged NPV
	return(2 * prec * sens / prec + sens)

} // End of function definition for multiclass negative predictive value

// Defines multiclass Detection Prevalence
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-detection_prevalence.R
real scalar mcdetection(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares scalars to store intermediate results
	real matrix conf
	
	// Compute the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// Return the micro averaged detection prevalence
	return(sum(rowsum(conf)) / sum(J(rows(conf), 1, sum(conf))))

} // End of function definition for multiclass detection prevalence

// Defines multiclass J-index (Youden's J statistic)
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-j_index.R
real scalar mcjindex(string scalar pred, string scalar obs, string scalar touse) {

	// Return the micro averaged detection prevalence
	return(mcsensitivity(pred, obs, touse) + mcspecificity(pred, obs, touse) - 1)

} // End of function definition for multiclass j-index

// Defines multiclass accuracy
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-accuracy.R
real scalar mcaccuracy(string scalar pred, string scalar obs, string scalar touse) {
	
	// Return the accuracy
	return(accuracy(pred, obs, touse))
	
} // End of multiclass accuracy synonym

// Defines multiclass Balanced Accuracy
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-bal_accuracy.R
real scalar mcbalaccuracy(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares scalars to store the intermediate results
	real scalar rec, sens
		
	// Compute the recall
	rec = mcrecall(pred, obs, touse)
	
	// Compute the sensitivity
	sens = mcsensitivity(pred, obs, touse)
	
	// Return the balanced accuracy
	return((rec + sens) / 2)
	
} // End of function definition for multiclass balanced accuracy

// Defines multiclass Kappa
// similar to accuracy, but normalized by accuracy expected by random chance
// based on: https://github.com/tidymodels/yardstick/blob/main/R/class-kap.R
real scalar mckappa(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares matrix to store random chance outcome
	real matrix chnc, conf, expected
	
	// Declares scalars to store the intermediate results
	real scalar n, rsum, csum, wgts, i
	
	// Get the confusion matrix
	conf = confusion(pred, obs, touse)
	
	// Gets total sample size
	n = sum(conf)
	
	// Gets the row margins
	rsum = rowsum(conf)
	
	// Gets the column margins
	csum = colsum(conf)
	
	// Normalizes the outer product of row margins * col margins
	expected = (rsum * csum) :/ n
	
	// Generates the weighting matrix for the no-weighting case
	wgts = J(rows(conf), cols(conf), 1)
	
	// Will need to replace the diagonal with 0s for wgts
	for(i = 1; i <= rows(wgts); i++) wgts[i, i] = 0
	
	// Return the metric 
	return(1 - sum(wgts * conf) / sum(wgts * expected))
	
} // End of function definition for multiclass Kappa 

// Defines multiclass Mathews correlation coefficient
// based on: https://github.com/tidymodels/yardstick/blob/main/src/mcc-multiclass.c
real scalar mcmcc(string scalar pred, string scalar obs, string scalar touse) {
	
	// Call the other implementation
	return(mcc(pred, obs, touse))
	
} // End of function definition for multiclass MCC

// Defines a multiclass R^2 (polychoric correlation)
real scalar mcordr2(string scalar pred, string scalar obs, string scalar touse) {

	// Call the tetrachoric command in Stata
	stata("cap: qui: polychoric " + pred + " " + obs + " if " + touse)

	// Returns the correlation coefficient
	return(st_numscalar("r(rho)"))

} // End of function definition for ordinal R^2

// End mata
end

**# Continuous Metrics
/*******************************************************************************
*                                                                              *
*                          Continuous Metrics/Utilities                        *
*                                                                              *
*******************************************************************************/

// Start mata
mata:

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
// https://github.com/tidymodels/yardstick/blob/main/R/num-rsq.R
real scalar r2(string scalar pred, string scalar obs, string scalar touse) {
	
	// Returns the correlation between the predicted and observed variable
	return(corr(variance((st_data(., pred, touse), ///   
						  st_data(., obs, touse))))[2, 1])
	
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
// https://github.com/tidymodels/yardstick/blob/main/R/num-smape.R
real scalar smape(string scalar pred, string scalar obs, string scalar touse) {

	// Allocates a column vector to store the differences
	real colvector num, denom
	
	// Creates a column vector with the observed outcome data
	num = abs(st_data(., obs, touse) - st_data(., pred, touse))
	
	// Computes the residuals
	denom = (abs(st_data(., obs, touse)) + abs(st_data(., pred, touse))) :/ 2
	
	// Returns the sum of the absolute value of the residual divided by the 
	// average of the sum of absolute observed and predicted values, divided by 
	// the number of observations
	return(sum(num :/ denom) / rows(denom))
	
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
	sqdiff = (log(st_data(., obs, touse) :+ 1) - log(st_data(., pred, touse)  :+ 1)) :^2
	
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

// Defines function for the ratio of performance to deviation
// based on: https://github.com/tidymodels/yardstick/blob/main/R/num-rpd.R
real scalar rpd(string scalar pred, string scalar obs, string scalar touse) {
	
	// Returns the ratio of the SD of predicted to the RMSE
	return(sqrt(variance(st_data(., pred, touse))) / rmse(pred, obs, touse))

} // End of function definition for RPD

// Defines function for the Index of ideality of correlation
// based on: https://github.com/tidymodels/yardstick/blob/main/R/num-iic.R
real scalar iic(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares some columnvectors
	real colvector neg, pos, delta
	
	// Declares scalars needed
	real scalar muneg, mupos, adj

	// Gets the difference in observed vs predict values
	delta = st_data(., obs, touse) - st_data(., pred, touse)
	
	// Selects only the differences that are negative
	neg = select(delta, delta :< 0)
	
	// Selects only the differences that are positive
	pos = select(delta, delta :>= 0)
	
	// Computes the absolute mean of the negative values
	muneg = sum(abs(neg)) / rows(neg)
	
	// Computes the absolute mean of the positive values
	mupos = sum(abs(pos)) / rows(pos)
	
	// Computes the adjustment factor for the correlation
	adj = min((muneg, mupos)) / max((muneg, mupos))
	
	// Returns the adjusted correlation
	return(r2(pred, obs, touse) * adj)

} // End of function definition for IIC

// Defines function for the Concordance Correlation Coefficient
// based on: https://github.com/tidymodels/yardstick/blob/main/R/num-ccc.R
real scalar ccc(string scalar pred, string scalar obs, string scalar touse) {
	
	// Declares scalars needed
	real scalar mupred, muobs, varpred, varobs, cov

	// estimate_mean in R function
	mupred = mean(st_data(., pred, touse))

	// truth_mean in R function
	muobs = mean(st_data(., obs, touse)) 

	// estimate_variance in R function
	varpred = variance(st_data(., pred, touse))[1, 1]

	// truth_variance in R function
	varobs = variance(st_data(., obs, touse))[1, 1]

	// Gets the covariance between the predicted and observed values
	cov = variance((st_data(., pred, touse), st_data(., obs, touse)))[2, 1]

	// Computes and returns the coefficient
	return(2 * cov / varobs + varpred + (muobs - mupred)^2)
	
} // End of function definition for CCC



// End mata interpreter
end

