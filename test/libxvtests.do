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

// This stores all of the returned results from estat classification in Mata 
// variables with names that correspond to our test metrics when possible and 
// also rescales the values to be proportions
p_1n = st_numscalar("r(P_1n)") * 0.01
p_0p = st_numscalar("r(P_0p)") * 0.01

// Stata's negative predictive value metric
stnpv = st_numscalar("r(P_0n)") * 0.01

// Stata's positive predictive value metric
stppv = st_numscalar("r(P_1p)") * 0.01

p_n1 = st_numscalar("r(P_n1)") * 0.01
p_p0 = st_numscalar("r(P_p0)") * 0.01

// Stata's specificity metric
stspec = st_numscalar("r(P_n0)") * 0.01

// Stata's sensitivity metric
stsens = st_numscalar("r(P_p1)") * 0.01

// Stata's accuracy metric
stacc = st_numscalar("r(P_corr)") * 0.01

// Get the twoway tabulation that the estat classification command leaves behind
ctab = st_matrix("r(ctable)")

//**** Now we compute all of our classification metrics

// Get the value of sensitivity
sens = sensitivity("pred", "low", "touse")

// Get the value for precision
prec = precision("pred", "low", "touse")

// Gets the value for "recall" (remember this is a synonym for sensitivity)
rcall = recall("pred", "low", "touse")

// Get the value of specificity
spec = specificity("pred", "low", "touse")

// Get the value of prevalence
prev = prevalence("pred", "low", "touse")

// Get the value of positive predictive value
pospv = ppv("pred", "low", "touse")

// Get the value of negative predictive value
negpv = npv("pred", "low", "touse")

// Get the value of accuracy
acc = accuracy("pred", "low", "touse")

// Get the value of the balanced accuracy statistic
bacc = baccuracy("pred", "low", "touse")

// Get the value of the f1 statistic
f1stat = f1("pred", "low", "touse")

// Recall function calls sensitivity under the hood and is just a synonym so it 
// should return the exact same result 
asserteq(sens, rcall)

// Create a variable to store the rounding factor to standardize things in the 
// tests below
rf = 0.0001

// Now we'll test the metrics based on Stata's computations whenever we can
// We can try a tolerance of 1e-4 to see if that will generally work.  If not, 
// we can move to 1e-5 or 1e-6.


// Test equality of sensitivity metrics
asserteq(round(stsens, rf), round(sens, rf))

// Test equality of Precision metrics
// asserteq(round(, rf), round(prec, rf))

// Test equality of specificity metrics
asserteq(round(stspec, rf), round(spec, rf))

// Test equality of Prevalence metrics
asserteq(round(ctab[3, 1], rf), round(prev, rf))

// Test equality of PPV metrics
asserteq(round(stppv, rf), round(pospv, rf))

// Test equality of NPV metrics
asserteq(round(stnpv, rf), round(negpv, rf))

// Test equality of Accuracy metrics
asserteq(round(stacc, rf), round(acc, rf))

// Test equality of "Balanced" Accuracy metrics
asserteq(round(((stsens + stspec) / 2), rf), round(bacc, rf))

// Test equality of F1 metrics
// asserteq(round(, rf), round(f1stat, rf))


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

