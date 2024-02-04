cscript "xv Mata Library tests" 

// Make sure everything in Mata's reserved memory is cleared
mata: mata clear

// Load the functions into memory
run crossvalidate.mata

// Set the pseudorandom number generator seed
set seed 7779311

// Create a quick test data set for the confusion matrix function
set obs 100

// Set the first 50 observations to 1 and the rest to 0
g byte pred = _n <= 50

// Set the middle 50 observations to 1 and the rest to 0
g byte obs = inrange(_n, 25, 75)

// Create the variable that will define the sample to use
g byte ifin = 1

/*******************************************************************************
*                                                                              *
*                        Tests for Utility Functions                           *
*                                                                              *
*******************************************************************************/

// Start the Mata interpreter/interactive session
mata:

// Since getifin and getnoifin are effectively handled with integration tests w/
// cmdmod, we won't create unit tests here for now.

// cvparse - we'll only check a couple options, but will also check/test the 
// flexibility of the parsing/assignment to the correct local:

// If we decide to make results an optional on, or optional on w/an argument
x = "results"

// Parse the string
cvparse(x)

// And look at the results
asserteq(st_local("results"), x)

// Do the same thing now, but with an optional name
x = "results(somename)"

// Parse the string
cvparse(x)

// And get the value
asserteq(st_local("results"), x)

// Now we'll include an instance with a few options and something that isn't a 
// valid option
x = `"results tpoint(td("06feb2024")) kfold(5) garbage"'

// Parse the string
cvparse(x)

// Now Test the results
asserteq(st_local("results"), "results")
asserteq(st_local("tpoint"), `"tpoint(td("06feb2024"))"')
asserteq(st_local("kfold"), "kfold(5)")
asserteq(st_local("garbage"), "")

// getarg - We'll use the stuff above to check how getarg works
getarg(st_local("results"))
asserteq(st_local("argval"), "results")
getarg(st_local("tpoint"))
asserteq(st_local("argval"), `"td("06feb2024")"')
getarg(st_local("kfold"))
asserteq(st_local("argval"), "5")

// confusion - for this we'll use a very simple simulated dataset created at the 
// start of this script
fixture = (25, 25 \ 24, 26)

// Generate the confusion matrix with the simulated data above
x = confusion("pred", "obs", "ifin")

// Test that the confusion matrix reproduces the fixture
asserteq(fixture, x)

// End the Mata session
end

/*******************************************************************************
*                                                                              *
*                  Tests for Binary Classification Metrics                     *
*                                                                              *
*******************************************************************************/

// Load an example data set from the Stata manuals
webuse lbw, clear

// Create the indicator for sample selection
g byte touse = 1

// Fit the example model to those data
logit low age lwt i.race smoke ptl ht ui

// Create the predicted probabilities
predict double pred, pr

// Replace this with the binary values
replace pred = cond(pred >= 0.5, 1, 0)

// Then use Stata's built-in classification metrics
estat classification

// Start the Mata interpreter/interactive session
mata:

// Get the value of sensitivity
sens = sensitivity("pred", "low", "touse")

// Get the value of specificity
spec = specificity("pred", "low", "touse")

// These tests are currently failing.  My guess is that is is a numerical 
// precision issue.  I'm going to try reaching out to some folks to get a better 
// idea about how to handle that type of issue in Mata.  But this should still 
// illustrate the basic pattern for creating the test cases for the different 
// metric functions.
asserteq(st_numscalar("r(P_p1)"), (100 * sens))
asserteq(st_numscalar("r(P_n0)"), (100 * spec))


// End the Mata session
end


/*******************************************************************************
*                                                                              *
*                Tests for Multinomial Classification Metrics                  *
*                                                                              *
*******************************************************************************/

// Start the Mata interpreter/interactive session
mata:


// End the Mata session
end


/*******************************************************************************
*                                                                              *
*                     Tests for Continuous Model Metrics                       *
*                                                                              *
*******************************************************************************/

// Start the Mata interpreter/interactive session
mata:


// End the Mata session
end

