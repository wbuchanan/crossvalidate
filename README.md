![Stata Crossvalidation](crossvalidate-hex.png)
# crossvalidation
The crossvalidate package includes several commands and a Mata library that 
provide a range of possible cross-validation techniques that can be used with 
any Stata estimation command returning results in `e()`.  For the majority of 
users and use cases, the prefix commands (see `xv` and `xvloo`) should handle 
your needs.  If, however, you need to implement something a bit different from 
generic use cases, the package also includes lower level commands that can save 
you time from having to code the entire cross-validation process.  These 
commands are named after the four-steps found in all cross-validation work:
`splitit`, `fitit`, `predictit`, and `validateit`.  There are also a few utility 
commands that take care of the metaprogramming tasks needed to allow these 
commands to be applied to the correct fold/split of the data.

Lastly, we implemented the majority of validation metrics that can be found in 
the R package [yardstick](https://yardstick.tidymodels.org/index.html) in our 
Mata library so you don't have to.  However, if you want to implement your own 
validation metric that is possible and easy to do (see information below which 
specifies the function signature to use for your Mata function that will 
implement your metric) and easy to use with the existing tools (i.e., pass the 
name of your function as an argument to the `metric` or `monitors` options of 
either the prefix commands or `validateit` and it will handle the rest).

## Examples:

```
// Load example dataset
sysuse auto.dta, clear

// Simple train/test (TT) split
xv 0.8, pstub(ttpred) metric(mse): reg price mpg length

// Simple train/validation/test (TVT) split
xv 0.6 0.2, pstub(tvtpred) metric(mse) monitors(mape smape): reg price mpg length

// Leave-One-Out cross valiation with a train/test split
xvloo 0.8, pstub(ttloopred) metric(mse): reg price mpg length

// LOO TVT split
xvloo 0.6 0.2, pstub(tvtloopred) metric(mse): reg price mpg length

// K-Fold TT split
xv 0.8, pstub(ttkfpred) metric(mae) kfold(5): reg price mpg length if !mi(rep78)

// K-Fold TVT split
xv 0.6 0.2, pstub(tvtkfpred) metric(mbe) kfold(3): reg price mpg length, vce(rob)

// Clustered K-Fold TT Split
xv 0.8, pstub(ttkfclpred) metric(phl) uid(rep78) kfold(4): reg price mpg length, vce(rob)

```

## TODO
- [x] Test whether the `noall` option is present when using a training 
proportion of 1 and k > 1 folds.  Will need to pass the `noall` option for the 
user or throw an error message requiring them to do it.
- [x] Add additional examples to the xv help file and xvloo helpfile.
- [x] Add information about the split proportions to xv and xvloo.
- [x] Remove requirement for pstub and if pstub or split are provided have that 
trigger the retain option automatically for users
- [x] Add some additional clarification about the retain option.
- [ ] Standardize language in help files
- [x] Finish writing test cases for Mata functions
- [ ] Finish writing test cases for ADO commands
- [ ] Update the syntax information in the README to match the current state of 
the commands

# libxv

## Metrics/Monitors

### Method Signature
The program will allow users to define their own metrics/monitors that are not 
contained in libcrossvalidate.  In order to do this, users must implement a 
specific method/function signature:

`real scalar metric(string scalar pred, string scalar obs, string scalar touse, | transmorphic matrix opts)`

The function must return a real valued scalar and take three arguments.  The 
three arguments are used to access the data that would be used to compute the 
metrics/monitors and to provide a method to pass optional arguments to the 
underlying functions if supported.

### Data access
Within the function body, we recommend using the following pattern to access 
the data needed to compute any metrics/monitors:

`real colvector yhat, y`

`yhat = st_data(., pred, touse)`

`y = st_data(., obs, touse)`

The programs in the cross validate package will handle the construction of the 
variables and passing them to the function name that users pass to the programs. 

### Building the library
Once we are ready to build the Mata library we should do the following:

`
// Clear everything from memory
clear all

// Define all of the Mata functions in memory
do crossvalidate.mata

// Build the library with all of the functions defined in crossvalidate.mata
lmbuild libxv

// If the library is already built, use this instead:
lmbuild libxv, replace 
`

## Testing/QA
- [x] Test function getifin
- [x] Test function getnoifin
- [x] Test function cvparse
- [x] Test function getarg
- [x] Test function to create the confusion matrix for classification 
- [x] Test function for Binary Sensitivity
- [x] Test function for Binary Precision
- [x] Test function for Binary Recall
- [x] Test function for Binary Specificity
- [x] Test function for Binary Prevalence
- [x] Test function for Binary Positive Predictive Value
- [x] Test function for Binary Negative Predictive Value
- [x] Test function for Binary Accuracy
- [x] Test function for Binary Balanced Accuracy
- [x] Test function for Binary F1
- [x] Test function for Youden's J statistic (J-index)
- [x] Test function for Matthew's Correlation Coefficient
- [x] Test function for Binary R^2
- [x] Test function for Multinomial Sensitivity
- [x] Test function for Multinomial Precision
- [x] Test function for Multinomial Recall
- [x] Test function for Multinomial Specificity
- [x] Test function for Multinomial Prevalence
- [x] Test function for Multinomial Positive Predictive Value
- [x] Test function for Multinomial Negative Predictive Value
- [x] Test function for Multinomial Accuracy
- [x] Test function for Multinomial Balanced Accuracy
- [x] Test function for Multinomial F1
- [x] Test function for Multinomial Detection Prevalence
- [x] Test function for Multinomial J-Index
- [x] Test function for Multinomial Kappa coefficient
- [x] Test function for Multinomial Matthew's Correlation Coefficient
- [ ] Test function for Ordinal R^2
- [x] Test function for Mean Squared Error
- [x] Test function for Mean Absolute Error
- [x] Test function for Bias
- [x] Test function for MBE
- [x] Test function for R^2 (Pearson Correlation Coefficient)
- [x] Test function for Root Mean Squared Error
- [x] Test function for Mean Absolute Percentage Error
- [x] Test function for Symmetric Mean Absolute Percentage Error
- [x] Test function for Mean-Squared Log Error
- [x] Test function for Root Mean-Squared Log Error
- [x] Test function for Ratio of Performance to Deviation
- [x] Test function for Index of ideality of correlation
- [x] Test function for Concordance Correlation Coefficient
- [x] Test function for Pseudo-Huber Loss
- [x] Test function for Poisson Log Loss
- [x] Test function for Huber Loss
- [x] Test function for Ratio of Performance to Interquartile Range
- [x] Test function for Traditional R^2
 
# Main Commands 

## splitit
`splitit # [#] [if] [in] [, Uid(varlist) TPoint(string asis) KFold(integer 0) RETain(string asis)]`

### Syntax and options
* \# [\#] - At least one numeric value in [0, 1].  A single value is used for 
train/test splits.  Two values are used for train/validate/test splits.  The sum
of the two values must be <= 1.
* <ins>u</ins>id(_varlist_) - A user specified varlist used to identify units 
when splitting the data.  When this is populated all records associated with the 
unit identifier will be added to the train/validate/test split.  If a time point 
is also specified, the time point threshold should retain only cases up to the 
specified time.
* <ins>tp</ins>oint(_string asis_) - A user specified time value that will be used 
to split the data into train/validation/test sets.  Requires the data to be 
-xt/tsset-.  If a panel variable is defined in -xtset- it will be used to ensure the 
split includes entire records prior to the time period used for the split.  If 
-uid- is also specified, it must include the panel variable.
* <ins>kf</ins>old(_integer 0_) - An optional parameter to trigger the use of 
K-Fold crossvalidation.  The number of folds specified will be used to generate 
the splits.  
* <ins>ret</ins>ain(_string asis_) - An optional parameter to specify the name 
to use for the split identifiers.  If a user specified value is passed to this 
parameter it will prevent the wrapper programs from dropping the variable with 
the splits at the end of execution.  This would allow users to test multiple 
models with the same training set, for example.

### Decisions
- [x] Should the kfold option cause the splitting to generate K-Folds in the 
validation set?  _Changed so the validation and test sets do not have any folds._
- [x] Are we handling time-series/panel train/test splits in the best/most common way? _This is tricky since most of the literature I've seen related to this is done in the context of forecasting.  So, now the data will be split, and an additional variable will be created to indicate the records that should be used to test subsequent forecasting (e.g., the timepoints > `tpoint')._
- [x] Change the type for tpoint to string asis so we can test for no value instead of -999 to avoid any potential clashes with dates and to allow users to specify values like `td(01jan2024)`. _updated to allow arbitrary values to be passed.  need to include an additional validation test on the tpoint input along the lines of "(t[dcC].*)|([\d\.]+)" to allow all potential date, datetime, and numeric representations of time to be passed._
- [x] Update handling for xt cases to check : char \_dta[iis] and : char \_dta[tis] 
for the panel and time variables instead of handling an error from a call to `xtset`. _the program now gets the xt/ts set information from these characteristics instead of capturing a call to xtset._

### Testing
Here are things that we need to test for this program:
- [x] Standard train/test split functions correctly (e.g., requested proportions)
- [x] Standard tt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] Standard train/validation/test split functions correctly (e.g., requested proportions)
- [x] Standard tvt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] K-Fold train/test split functions correctly (e.g., requested proportions)
- [x] K-Fold tt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] K-Fold train/validation/test split functions correctly (e.g., requested proportions)
- [x] K-Fold tvt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] XT/Panel train/test split functions correctly (e.g., requested proportions)
- [x] XT/Panel tt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] XT/Panel train/validation/test split functions correctly (e.g., requested proportions)
- [x] XT/Panel tvt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] XT/Panel K-Fold train/test split functions correctly (e.g., requested proportions)
- [x] XT/Panel K-Fold tt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] XT/Panel K-Fold train/validation/test split functions correctly (e.g., requested proportions)
- [x] XT/Panel K-Fold tvt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [x] Test all cases that should throw an error
- [x] Test all of the above scenarios with if expressions

## fitit
`fitit anything(name = cmd) , PStub(string asis) SPLit(passthru) [ Classes(integer 0) RESults(string asis) Kfold(integer 1) THReshold(passthru)]`

### Syntax and options
* cmd is the estimation command the user wishes to fit to the data
* <ins>ps</ins>tub(string asis) - A variable name to use to store the predicted values following model fitting.
* <ins>spl</ins>it(passthru) - specifies the name of the variable used to identify the train/validate/test or KFold splits in the dataset.
* <ins>c</ins>lasses(integer 0) - An option used to determine whether the model is a regression or classification task.  This is subsequently passed to the classify program.
* <ins>res</ins>ults(string asis) - A name to use to store estimation results persistently using `estimates store`.
* <ins>k</ins>fold(integer 1) - An option used to determine if the model needs to be fitted over k subsets of the data.
* <ins>thr</ins>eshold(passthru) - An option that is passed to the classify program for predicting class membership in classification tasks.

### TODO
- [x] Determine how we will handle updating and substituting the if/in statements for estimation and prediction respectively
- [x] Update help file and syntax here to reflect only parameters required for model fitting
- [x] Develop tests for the command

### Testing
- [x] Biggest test will be ensuring that the if/in statements are handled appropriately for estimation


## predictit
`predictit [anything(name = cmd)], PStub(string asis) [SPLit(passthru) Classes(integer 0) Kfold(integer 1) THReshold(passthru) MODifin(string asis) KFIfin(string asis) noall]`

### Syntax and options
* cmd is the estimation command the user wishes to fit to the data
* <ins>ps</ins>tub(string asis) - A variable name to use to store the predicted values following model fitting.
* <ins>spl</ins>it(passthru) - specifies the name of the variable used to identify the train/validate/test or KFold splits in the dataset.
* <ins>c</ins>lasses(integer 0) - An option used to determine whether the model is a regression or classification task.  This is subsequently passed to the classify program.
* <ins>k</ins>fold(integer 1) - An option used to determine if the model needs to be fitted over k subsets of the data.
* <ins>thr</ins>eshold(passthru) - An option that is passed to the classify program for predicting class membership in classification tasks.
* <ins>mod</ins>ifin(string asis) - the modified if expression used to generate the out of sample predictions.
* <ins>kfi</ins>fin(string asis) - the modified if expression used to generate the out of sample predictions for the full training sample when using K-Fold cross-validation.
* noall - suppresses prediction on the entire training sample when using K-Fold cross-validation.
* <ins>pm</ins>ethod(string asis) - the method (statistic) to predict with the out-of-sample/held-out data.

### TODO
- [x] Need to find a solution to call individual estimation results when \*# 
does not work (e.g., LOO cases)

### Testing
- [x] Initial Tests 
- [x] Tests for error codes
- [ ] Tests related to LOO use case


## validateit
`validateit [if] [in], MEtric(string asis) [MOnitors(string asis) Pred(string asis) Obs(string asis) DISplay`

### Syntax and options
* [if] [in] used to ensure that we are only computing the metrics/monitors on 
the validation sample.
* <ins>me</ins>tric(string asis) - specifies the name of the Mata function to 
use as the validation metric.  In the future this would be the value that would 
be optimized by any hyperparameter tuning capabilities.
* <ins>mo</ins>nitors(string asis) - this can be a list of functions used to 
evaluate the model performance on the out of sample data.   There can be any 
number of monitors since they are not involved in hyperparameter tuning.
* <ins>p</ins>red(string asis) - the name of the variable containing the 
predicted values from the model.
* <ins>o</ins>bs(string asis) - the name of the dependent variable from the model.
* <ins>dis</ins>play - an option to print the monitor and metric values to the 
console.
* noall - suppresses prediction on the entire training sample when using K-Fold cross-validation.

### Testing
- [x] Need to ensure that the return scalars are correctly populated
- [x] Test that the display option works correctly and that output is easy to read
- [x] Test that approach to calling the Mata functions works as intended

### TODO
- [x] Add an option for LOO that only computes validation metrics for the entire
training sample.

## xv

### Syntax and options


### Testing
- [ ] Handling of `in` expressions passed to estimation commands


## xvloo

### Syntax and options
Should have the exact same syntax as above, with the exception of no K-Fold 
argument.  

### TODO
- [x] Initial testing to get things running start to finish

### Testing
- [ ] Handling of `in` expressions passed to estimation commands




# Utility commands

## classify
`classify # [if], PStub(string asis) [ THReshold(real 0.5) ]`

### Syntax and options
* \# - This is the number of classes of the outcome variable being modeled.  This 
value must be integer valued.
* <ins>ps</ins>tub(_string asis_) - Specifies a stub name to use to store the 
predicted classes from the model.
* <ins>thr</ins>eshold(_real 0.5_) - Specifies the threshold to use for classification 
of predicted probabilities in the case of binary outcome models.  The value of 
the threshold must be in (0, 1).
* <ins>pm</ins>ethod(string asis) - the method (statistic) to predict with the out-of-sample/held-out data.

### Testing
Here are things that we need to test for this program:
- [x] Binary classification works correctly with user specified or default threshold
- [x] Multi-class classification works correctly (e.g., highest probability class is predicted)
- [x] The prediction is returned in the variable specified by pstub
- [x] Mutli-class probabilities are not returned, but the predicted class is returned in pstub
- [x] Make sure numbers attached to pstub* for multiclass cases are consistent with the value being predicted

## state
`state `

### Syntax and options
No options

## cmdmod
`cmdmod anything(name = cmd id = "estimation command"), SPLit(varlist min = 1 max = 1) [ KFold(integer 1) ]`

### Syntax and options
* <ins>spl</ins>it(varlist min = 1 max = 1) - specifies the name of the variable
used to identify the train/validate/test or KFold splits in the dataset that 
will be used to fit the model to the training set and that predictions will use 
the validation set.
* <ins>kf</ins>old(integer 1) - specifies the number of cross-validation folds 
used in the dataset.  The default value indicates that K-Fold cross-validation 
is not being used and the data should be treated like a train/test or 
train/validation/test split.

### Returns
* r(cmdmod) - The modified estimation command string to fit the data to the 
appropriate subset of the data for training.
* r(predifin) - An if expression used to ensure predictions are made on the 
appropriate subset of data.
* r(kfcmdmod) - Like cmdmod, but used only in K-Fold cross-validation to fit the 
model one last time to all of the training data simultaneously.
* r(kfpredifin) - Like predifin, but used only in K-Fold cross-validation to 
ensure the predictions are made only on the held out validation set.  


### Testing
- [x] See cmdmodtests.do for a certification script.
- [x] Add tests for commands that include `inlist()` and/or `inrange()` functions
- [x] Add tests for commands that include quoted string arguments

