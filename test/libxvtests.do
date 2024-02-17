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
sensitivity = sens("pred", "low", "touse")

// Get the value for precision
precision = prec("pred", "low", "touse")

// Gets the value for "recall" (remember this is a synonym for sensitivity)
rcall = recall("pred", "low", "touse")

// Get the value of specificity
specificity = spec("pred", "low", "touse")

// Get the value of prevalence
prevalence = prev("pred", "low", "touse")

// Get the value of positive predictive value
pospv = ppv("pred", "low", "touse")

// Get the value of negative predictive value
negpv = npv("pred", "low", "touse")

// Get the value of accuracy
accuracy = acc("pred", "low", "touse")

// Get the value of the balanced accuracy statistic
baccuracy = bacc("pred", "low", "touse")

// Get the value of the f1 statistic
f1stat = f1("pred", "low", "touse")

// Recall function calls sensitivity under the hood and is just a synonym so it 
// should return the exact same result 
asserteq(sensitivity, rcall)

// Create a variable to store the rounding factor to standardize things in the 
// tests below set to 1e-6
rf = 0.000001

// Now we'll test the metrics based on Stata's computations whenever we can

// Test equality of sensitivity metrics
asserteq(round(stsens, rf), round(sensitivity, rf))

// Test equality of Precision metrics
// asserteq(round(, rf), round(prec, rf))

// Test equality of specificity metrics
asserteq(round(stspec, rf), round(specificity, rf))

// Test equality of Prevalence metrics
//asserteq(round(ctab[3, 1], rf), round(prev, rf))

// Test equality of PPV metrics
asserteq(round(stppv, rf), round(pospv, rf))

// Test equality of NPV metrics
asserteq(round(stnpv, rf), round(negpv, rf))

// Test equality of Accuracy metrics
asserteq(round(stacc, rf), round(accuracy, rf))

// Test equality of "Balanced" Accuracy metrics
asserteq(round(((stsens + stspec) / 2), rf), round(baccuracy, rf))

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

// Clear any data from memory
clear

// Create an example data set to make it easy to hand compute the metrics
input pred obs touse
1 2 1
2 1 1
3 8 1
4 7 1
5 2 1
6 6 1
7 3 1
8 10 1
9 3 1
10 2 1
end

// Get the correlation between the predicted and observed variables
qui: corr pred obs

// Start the Mata interpreter/interactive session
mata:

// Store the correlation between predicted and observed values
str2 = st_numscalar("r(rho)")

// Get our mean squared error
xvmse = mse("pred", "obs", "touse")

// Get the mean absolute error
xvmae = mae("pred", "obs", "touse")	

// Get the bias stat
xvbias = bias("pred", "obs", "touse")

// Get the mean bias stat
xvmbe = mbe("pred", "obs", "touse")

// Get the R^2
xvr2 = r2("pred", "obs", "touse")

// Get rmse with our calculation
xvrmse = rmse("pred", "obs", "touse")

// Get the mean absolute percentage error
xvmape = mape("pred", "obs", "touse")	

// Get the symmetric mean absolute percentage error
xvsmape = smape("pred", "obs", "touse")

// Get the mean squared loss error
xvmsle = msle("pred", "obs", "touse")

// Get the root mean squared loss error
xvrmsle = rmsle("pred", "obs", "touse")

// Get the RPD metric
xvrpd = rpd("pred", "obs", "touse")

// Set a rounding factor
rf = 1e-5

// These tests are currently failing.  My guess is there is probably a missing 
// adjustment for degrees of freedom that isn't accounted for in the functions 
// I put together.

// Test equality of MSE
asserteq(round(16.5, rf), round(xvmse, rf))

// Test equality of MAE
asserteq(round(3.3, rf), round(xvmae, rf))

// Test equality of bias
asserteq(round(-11, rf), round(xvbias, rf))

// Test equality of mean bias
asserteq(round(-1.1, rf), round(xvmbe, rf))

// Test equality of R2
asserteq(round(str2, rf), round(xvr2, rf))

// Test equality of RMSE
asserteq(round(sqrt(16.5), rf), round(xvrmse, rf))

// Test equality of MAPE
asserteq(round(1.15869048, rf), round(xvmape, rf))

// Test equality of SMAPE
asserteq(round(0.70005722, rf), round(xvsmape, rf))

// Test equality of MSLE
asserteq(round(.4736214869, rf), round(xvmsle, rf))

// Test equality of RMSLE
asserteq(round(.6882016324, rf), round(xvrmsle, rf))

// Test equality of RPD
asserteq(round(.7453559925, rf), round(xvrpd, rf))

// End the Mata session
end

