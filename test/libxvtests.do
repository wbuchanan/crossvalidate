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

**# Utility Functions
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
x = `"res tpoint(td("06feb2024")) kf(5) garbage"'

// Parse the string
cvparse(x)

// Now Test the results
asserteq(st_local("results"), "res")
asserteq(st_local("tpoint"), `"tpoint(td("06feb2024"))"')
asserteq(st_local("kfold"), "kf(5)")
asserteq(st_local("garbage"), "")

// getarg - We'll use the stuff above to check how getarg works
getarg(st_local("results"))
asserteq(st_local("argval"), "")
getarg(st_local("tpoint"))
asserteq(st_local("argval"), `"td("06feb2024")"')
getarg(st_local("kfold"))
asserteq(st_local("argval"), "5")

// Check cvparse when it includes optional arguments passed to metrics/monitors
// and an invalid option
x = `"metric(mse) trash monitors(mape((1, 2)) smape rmse(("y", "N")) rmsle)"'

// Parse the string
cvparse(x)

// Now test the results
asserteq(st_local("metric"), "metric(mse)")
asserteq(st_local("trash"), "")
asserteq(st_local("monitors"), `"monitors(mape((1, 2)) smape rmse(("y", "N")) rmsle)"')

// Now check getarg in this context
getarg(st_local("metric"), "m")
asserteq(st_local("m"), "mse")
getarg(st_local("monitors"))
asserteq(st_local("argval"), `"mape((1, 2)) smape rmse(("y", "N")) rmsle"')

// confusion - for this we'll use a very simple simulated dataset created at the 
// start of this script
normfix = (25, 25 \ 24, 26)
revfix = (26, 24 \ 25, 25)

// Generate the confusion matrix with the simulated data above
x = xtab("pred", "obs", "ifin")

// Test that the confusion matrix reproduces the fixture
asserteq(normfix, x.conf)
asserteq(revfix, x.revconf)

// End the Mata session
end

**# Binary Classification Metrics
/*******************************************************************************
*                                                                              *
*                  Tests for Binary Classification Metrics                     *
*                                                                              *
*******************************************************************************/

// Clear data from memory
clear

// Set the number of observations
set obs 100

// Create a predicted variable
g byte pred = cond(_n > 42, 0, 1)

// Create a version of predicted variable with missing
g byte predna = cond(inlist(_n, 1, 10, 20, 30, 40, 50), ., pred)

// Create an observed variable
g byte obs = cond(inrange(_n, 31, 42) | inrange(_n, 73, 100), 0, 1)

// Create the sample indicator
g byte touse = 1

// Create the cross tabulation from these data
ta pred obs if touse, matcell(c)

// Start the Mata interpreter/interactive session
mata:

// Store the cross-tabulation from the Stata code above
c = st_matrix("c")

// Define fixture for sensitivity
fxsens = 30 / (30 + 30)

// Define fixture for recall
fxrecall = fxsens

// Define fixture for prevalence
fxprev = (30 + 30) / (28 + 30 + 12 + 30)

// Define fixture for specificity
fxspec = 28 / (28 + 12)

// Define fixture for precision
fxprec = 30 / (30 + 12)

// Define fixture for ppv
fxppv = (fxsens * fxprev) / ((fxsens * fxprev) + ((1 - fxspec) * (1 - fxprev)))

// Define fixture for npv
fxnpv = (fxspec * (1 - fxprev)) / (((1 - fxsens) * fxprev) + (fxspec * (1 - fxprev)))

// Define fixture for accuracy
fxacc = (28 + 30) / 100

// Define fixture for balanced accuracy
fxbacc = (fxsens + fxspec) / 2

// Define fixture for F1 stat
fxf1 = (2 * fxprec * fxrecall) / (fxprec + fxrecall)

// Define fixture for J-Index
fxjidx = fxsens + fxspec - 1

// Used to calculate edwards rho estimate from: 
// https://www.stata.com/manuals/rtetrachoric.pdf
edrho = ((28 * 30) / (30 * 12))^(`c(pi)' / 4)

// Define fixture for Binary R^2
fxbinr2 = (edrho - 1) / (edrho + 1)

// Create components of MCC
mccnum = (30 + 28) * 100 - (60 * 42) - (40 * 58)
mccd1 = 100^2 - 40^2 - 60^2
mccd2 = 100^2 - 58^2 - 42^2

// Define fixture for Matthew's Correlation Coefficient
fxmcc = mccnum / (sqrt(mccd1) * sqrt(mccd2))

// Generate the struct
ct = xtab("pred", "obs", "touse")

// Assert that our confusion matrix reproduces the one above
assert(det(c - ct.conf) == 0)

// Recall function calls sensitivity under the hood and is just a synonym so it 
// should return the exact same result 
asserteq(sens("pred", "obs", "touse"), recall("pred", "obs", "touse"))

// Create a variable to store the rounding factor to standardize things in the 
// tests below set to 1e-6
rf = 0.000001

// Now we'll test the metrics based on Stata's computations whenever we can

// Test equality of sensitivity metrics
asserteq(round(fxsens, rf), round(sens("pred", "obs", "touse"), rf))

// Test equality of Precision metrics
asserteq(round(fxprec, rf), round(prec("pred", "obs", "touse"), rf))

// Test equality of specificity metrics
asserteq(round(fxspec, rf), round(spec("pred", "obs", "touse"), rf))

// Test equality of Prevalence metrics
asserteq(round(fxprev, rf), round(prev("pred", "obs", "touse"), rf))

// Test equality of PPV metrics
asserteq(round(fxppv, rf), round(ppv("pred", "obs", "touse"), rf))

// Test equality of NPV metrics
asserteq(round(fxnpv, rf), round(npv("pred", "obs", "touse"), rf))

// Test equality of Accuracy metrics
asserteq(round(fxacc, rf), round(acc("pred", "obs", "touse"), rf))

// Test equality of "Balanced" Accuracy metrics
asserteq(round(fxbacc, rf), round(bacc("pred", "obs", "touse"), rf))

// Test equality of F1 metrics
asserteq(round(fxf1, rf), round(f1("pred", "obs", "touse"), rf))

// Test equality of J index
asserteq(round(fxjidx, rf), round(jindex("pred", "obs", "touse"), rf))

// Test equality of R^2
asserteq(round(fxbinr2, rf), round(binr2("pred", "obs", "touse"), rf))

// Test equality of Matthews Correlation Coefficient
asserteq(round(fxmcc, rf), round(mcc("pred", "obs", "touse"), rf))

// Test equality of F1 metrics with new function signature
asserteq(round(fxf1, rf), round(f1("pred", "obs", "touse", (0, 1)), rf))
asserteq(round(fxf1, rf), round(f1("pred", "obs", "touse"), rf))

// End the Mata session
end

**# Multiclass Classification Metrics
/*******************************************************************************
*                                                                              *
*                Tests for Multinomial Classification Metrics                  *
*                                                                              *
*******************************************************************************/

// Clear existing data from memory
clear

// Set the pseudorandom number generator seed
set seed 1311

// Set the number of observations
set obs 150

// Create observed values
g byte obs = cond(inrange(_n, 51, 100), 1, cond(_n > 100, 2, 0))

// Create random predicted values
g byte pred = runiformint(0, 2)

// Create the touse variable
g byte touse = 1

// Create the confusion matrix
ta pred obs if touse, matcell(c)

// Start the Mata interpreter/interactive session
mata:

// Get the confusion matrix from the data generated above
c = st_matrix("c")

// Define fixture for sensitivity
fxsens = (22 + 21 + 21) / (22 + 19 + 15 + 13 + 21 + 14 + 15 + 10 + 21)

// Define fixture for detection prevalence
fxprev = ((56 / 150) + (48 / 150) + (46 / 150)) / 3

// Define fixture for specificity
fxspec = (66 + 73 + 75) / (66 + 34 + 73 + 27 + 75 + 25)

// Define fixture for precision
fxprec = (22 + 21 + 21) / (56 + 48 + 46)

// Define fixture for recall
fxrecall = fxsens

// Define fixture for accuracy
fxacc = (22 + 21 + 21) / 150

// Define fixture for NPV
fxnpv = (fxspec * (1 - fxprev)) / (((1 - fxsens) * fxprev) + (fxspec * (1 - fxprev)))

// Define fixture for balanced accuracy
fxbacc = (fxsens + fxrecall) / 2

// Define fixture for F1 stat
fxf1 = (2 * fxprec * fxsens) / (fxprec + fxsens)

// Define fixture for J-Index
fxjidx = fxsens + fxspec - 1

// Create component pieces for the Kappa fixture
kwgt = (0, 1, 1 \ 1, 0, 1 \ 1, 1, 0)
krow = rowsum(c)
kcol = colsum(c)
knum = sum(kwgt * c)
kden = sum(kwgt * (krow * kcol):/ 150)

// Define fixture for Kappa
fxkappa = 1 - knum / kden

// Create component pieces for Matthews Correlation Coefficient
mcnum = (22 + 21 + 21) * 150 - (50 * 46) - (50 * 48) - (50 * 56)
mcd1 = 150^2 - 50^2 - 50^2 - 50^2
mcd2 = 150^2 - 56^2 - 48^2 - 46^2

// Define Fixture for MCC
fxmcc = mcnum / (sqrt(mcd1) * sqrt(mcd2))

// Compute the confusion matrix with the confusion function
ct = xtab("pred", "obs", "touse")

// Assert that these are the same confusion matrices by testing that the 
// determinant of the difference is 0
assert(det(c - ct.conf) == 0)

// Set a rounding factor to use for testing equality
rf = 1e-6

// Test equality of sensitivity
asserteq(round(fxsens, rf), round(mcsens("pred", "obs", "touse"), rf))

// Test equality of precision
asserteq(round(fxprec, rf), round(mcprec("pred", "obs", "touse"), rf))

// Test equality of recall
asserteq(round(fxrecall, rf), round(mcrecall("pred", "obs", "touse"), rf))

// Test equality of specificity
asserteq(round(fxspec, rf), round(mcspec("pred", "obs", "touse"), rf))

// Test equality of detection prevalence
asserteq(round(fxprev, rf), round(mcdetect("pred", "obs", "touse"), rf))

// Test equality of PPV
asserteq(round(fxprec, rf), round(mcppv("pred", "obs", "touse"), rf))

// Test equality of NPV
asserteq(round(fxnpv, rf), round(mcnpv("pred", "obs", "touse"), rf))

// Test equality of accuracy
asserteq(round(fxacc, rf), round(mcacc("pred", "obs", "touse"), rf))

// Test equality of balanced accuracy
asserteq(round(fxbacc, rf), round(mcbacc("pred", "obs", "touse"), rf))

// Test equality of f1 stat
asserteq(round(fxf1, rf), round(mcf1("pred", "obs", "touse"), rf))

// Test equality of J-index
asserteq(round(fxjidx, rf), round(mcjindex("pred", "obs", "touse"), rf))

// Test equality of Kappa
asserteq(round(fxkappa, rf), round(mckappa("pred", "obs", "touse"), rf))

// Test equality of Multiclass MCC
asserteq(round(fxmcc, rf), round(mcmcc("pred", "obs", "touse"), rf))

// End the Mata session
end

// This is an extra test just to be safe for MCC
clear 

// Sets the number of observations based on the left of box 3 in:
// https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0041882&type=printable
set obs 25

// Reproduces the columns of the matrix on the left of box 3 
g byte obs = cond(_n <= 13, 1,												 ///   
			 cond(inrange(_n, 14, 17), 2, cond(inrange(_n, 18, 21), 3, 4)))
			 
// Reproduces the rows from the same matrix			 
g byte pred = cond(inlist(_n, 1, 14, 18, 22), 1,							 ///   
			  cond(inlist(_n, 2, 15, 19, 23), 2,							 ///   
			  cond(inlist(_n, 3, 16, 20, 24), 3, 4)))
			  
// Creates sample inclusion indicator			  
g byte touse = 1
			  
// Call our MCC implementation
mata: asserteq(-0.088, round(mcmcc("pred", "obs", "touse"), 0.001))			  

**# Continuous Metrics
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

// Get the Index of Ideality of Correlation metric
xviic = iic("pred", "obs", "touse")

// Get the Concordance Correlation Coefficient
xvccc = ccc("pred", "obs", "touse")

// Get the pseudo-Huber loss
xvphl = phl("pred", "obs", "touse")

// Get the Huber loss
xvhuber = huber("pred", "obs", "touse")

// Get the Poisson log loss
xvpll = pll("pred", "obs", "touse")

// Get the ratio of performance to IQR
xvrpiq = rpiq("pred", "obs", "touse")

// Get the "traditional" R^2
xvr2ss = r2ss("pred", "obs", "touse")

// Set a rounding factor
rf = 1e-4

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

// Test equality of Index of Ideality of Correlation
asserteq(round(0.04737794, rf), round(xviic, rf))

// Test equality of Concordance Correlation Coefficient
// Currently failing. function returns 10.56 but should be smaller.
asserteq(round(0.08899271, rf), round(xvccc, rf))

// Test equality of pseudo-Huber loss
asserteq(round(2.57562, rf), round(xvphl, rf))

// Test equality of Huber loss
asserteq(round(2.85, rf), round(xvhuber, rf))

// Test equality of Poisson log loss
asserteq(round(3.049186, rf), round(xvpll, rf))

// Test equality of Ratio of Performance to IQR
asserteq(round(1.23091491, rf), round(xvrpiq, rf))

// Test equality of "Traditional" R^2
asserteq(round(-0.9097222, rf), round(xvr2ss, rf))

// End the Mata session
end

