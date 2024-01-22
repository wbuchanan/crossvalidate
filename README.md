# Specifications for crossvalidation package


## What should it do?
* Allow users to define a train/test or train/validation/test split and fit 
* models to the data defined by the splits

## How will it be accomplished?
* A few prefix commands, ala brewproof, that handle the splitting, fitting, and 
* computing of metrics that should be reported.

## Known challenges
- [x] Parsing and defining the API for the prefix command consistently
- [x] Returning results in ereturn in a reasonable way
- [x] Handling if/in conditions in the estiamtion command
- [x] Allowing arbitrary validation/test metrics
- [x] Consideration for how this could be used for hyperparameter tuning in the future
- [x] Determine how multiclass predictions will be handled

## Example:
`cvtt 0.8, metric(mse): reg price mpg length if foreign != 1`

# How to handle 
1. parse the if/in statement from the estimation command if it exists
2. generate random uniform for the subset requested 
3. tag the cases that should be used for training
4. fit the model to the training set
5. predict outcome on the test set (e.g., foreign == 0 but not test)
6. pass predicted and observed outcomes to a mata function/method that will compute the metric
7. return the results from fitting the model
8. return the metric following the model fitting
9. return the monitors following the model fitting
10. ensure results stored in appropriate e() locations

## Commands to write for this package
- [ ] cvtt - Cross-Sectional train/test split 
- [ ] cvtvt - Cross-Sectional train/validation/test split
- [ ] xtcvtt - Panel/Time-Series train/test split (need to cap xtset this)
- [ ] xtcvtvt - Panel/Time-Series train/validation/test split
- [ ] cvloo - Leave One Out cross-validation (effectively a jackknife-esque procedure)
- [ ] xtcvloo - Leave One Out for panel/time-series 
- [ ] state - a program that will handle getting and writing important information 
about the state of the software when starting up for replication purposes.  It 
should either add dataset characteristics or notes.
- [x] splitter - a program that handles defining the splits of the dataset for the 
main end user facing commands also needs to handle potential persistence of group membership (e.g., folds or train/validation/test splits)
- [ ] fitter - a program that handles fitting the statistical model to the data, also needs to handle storage of results
- [x] validate - a program that will handle the validation portion of the training loop (e.g., computing monitors and/or test metrics and returning those values as well)
- [x] classify - a program that can return the predicted class from classification based models (e.g., logit, ologit, mlogit, etc...)


## Mata Stuff
- [x] `getifin` function to handle parsing if/in expressions in the estimation command
- [x] `repifin` function to handle replacing user if/in w/exp that includes training set
- [x] `cvparse` function to handle parsing the options for the prefix commands
- [x] `getarg` function to handle retrieving the argument value from options
- [x] metric specification 
- [x] monitor specification

# Syntax
`prefixcmd` numlist(min = 1 max = 2 default = 0.8) [, options]

## Required:
* numlist in [0, 1] that identifies the proportion of the data to use for training
	- for xttsplit and ttsplit there should only be a single digit (training proportion)
	- for xtvtsplit and tvtsplit there should be two digits for the training and validation proportions
		- The sum of these two elements must be < 1
		- Consider threshold for warnings (e.g., .8 .15 might leave too little data for the test set (5%))		

## Options:
* metric (will take the name of a mata function that computes the validation/test metric)
* seed (to set the pseudo-random number generator seed before executing)
* monitors (? potentially a list of things to monitor that don't resolve in a scalar (metrics would be used for hyperparameter tuning); should this only be used for train/validation/test splits?)
* uid (used to determine whether the sample needs to split based on clusters of observations)
* tpoint (time point used to identify the splitting for panel/time series data only)
* retain (option to create a permanent variable that identifies the groups for the splits) by itself will just keep the \_splitter variable following execution, otherwise will remove it at conclusion.
* retain2 this will be a string asis parameter and if a value is passed that will be the name of the variable storing the split groups otherwise we'll use a generic name
* kfold (to use k-fold cross validation will define the number of folds to use)
* state (? potentially a way to bind additional metadata to the dataset for replication purposes; see `c(rng_current)` to determine which pseudo-random number generator is used and `c(rngstate)` for the current state of the pseudo-random number generator)
* results (to store intermediate estimation results via est sto or potentially another method)
* grid (reserved for future to support hyperparameter tuning)
* params (reserved for future to support hyperparameter tuning; these will be options passed to the estimation command that would be tuned via grid or a result set for regression based tunning methods)
* tuner (reserved for future to support hyperparameter tuning; will take name of method for the tuning)
* classes an option that signals that the number of predicted classes; 0 indicates not categorical outcome
* restitle an option to add titles to stored estimation results

## Rules
* time point only allowed for xt prefixes
* metric is a required option
* xt prefixes can only be called on xtset or tsset datasets
* uid should not be isid
* splitter.ado will use the variable name \_splitter as the default if no value is passed to the retain parameter and should be dropped before the execution of any of the cv commands finishes executing. 
* splitter assumes that the first threshold is the upper bound for the split.  In other words the random uniform will be <= threshold to define the training set.  For TVT splits, the validation set is > threshold 1 and <= threshold 2.  
* TT split can be used for KFold with the enter dataset using a value of 1
* KFold will currently create a similar number of folds in the validation set at the moment in the case of a TVT split
* xt splits will use information from xtset/tsset to identify the time variable corresponding to the time point cut off; time point threshold works the same way as the first threshold passed to the command (e.g., times that are <= tpoint will be included in the training/validation sets), but time points beyond that are excluded and are assumed to be used for testing outside of this package (e.g., forecasting)

# Metrics/Monitors

## Method Signature
The program will allow users to define their own metrics/monitors that are not 
contained in libcrossvalidate.  In order to do this, users must implement a 
specific method/function signature:

`real scalar metric(string scalar pred, string scalar obs, string scalar touse)`

The function must return a real valued scalar and take three arguments.  The 
three arguments are used to access the data that would be used to compute the 
metrics/monitors.  

## Data access
Within the function body, we recommend using the following pattern to access 
the data needed to compute any metrics/monitors:

`real colvector yhat, y`

`yhat = st_data(., pred, touse)`

`y = st_data(., obs, touse)`

The programs in the cross validate package will handle the construction of the 
variables and passing them to the function name that users pass to the programs. 

## Testing/QA
- [ ] Check that all functions are defined correctly based on the mathematical definitions
- [ ] Create unit tests for each of the metrics 
 

# Commands 

## splitter
`splitter # [#] [if] [in] [, Uid(varlist) TPoint(real -999) KFold(integer 0) RETain(string asis)]`

### Syntax and options
* \# [\#] - At least one numeric value in [0, 1].  A single value is used for 
train/test splits.  Two values are used for train/validate/test splits.  The sum
of the two values must be <= 1.
* <ins>u</ins>id(_varlist_) - A user specified varlist used to identify units 
when splitting the data.  When this is populated all records associated with the 
unit identifier will be added to the train/validate/test split.  If a time point 
is also specified, the time point threshold should retain only cases up to the 
specified time.
* <ins>tp</ins>oint(_real -999_) - A user specified time value that will be used 
to split the data into train/validation/test sets.  Requires the data to be 
-xtset-.  If a panel variable is defined in -xtset- it will be used to ensure the 
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
- [ ] Should the kfold option cause the splitting to generate K-Folds in the 
validation set?  Should this be an option?
- [ ] Are we handling time-series/panel train/test splits in the best/most common way?
- [ ] Change the type for tpoint to string asis so we can test for no value instead of -999 to avoid any potential clashes with dates and to allow users to specify values like `td(01jan2024)`.
- [ ] Update handling for xt cases to check : char \_dta[iis] and : char \_dta[tis] 
for the panel and time variables instead of handling an error from a call to `xtset`.

### Testing
Here are things that we need to test for this program:
- [ ] Standard train/test split functions correctly (e.g., requested proportions)
- [ ] Standard tt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [ ] Standard train/validation/test split functions correctly (e.g., requested proportions)
- [ ] Standard tvt-split functions correctly with uid (e.g., clusters are sampled correctly with correct proportions)
- [ ] 


## classify
`classify # [if] [in] [, THReshold(real 0.5) PStub(string asis) ]`

### Syntax and options
* \# - This is the number of classes of the outcome variable being modeled.  This 
value must be integer valued.
* <ins>thr</ins>eshold(_real 0.5_) - Specifies the threshold to use for classification 
of predicted probabilities in the case of binary outcome models.  The value of 
the threshold must be in (0, 1).
* <ins>ps</ins>tub(_string asis_) - Specifies a stub name to use to store the 
predicted classes from the model.

### Testing
Here are things that we need to test for this program:
- [ ] Binary classification works correctly with user specified or default threshold
- [ ] Multi-class classification works correctly (e.g., highest probability class is predicted)
- [ ] The prediction is returned in the variable specified by pstub
- [ ] Mutli-class probabilities are not returned, but the predicted class is returned in pstub
- [ ] Make sure numbers attached to pstub* for multiclass cases are consistent with the value being predicted


## state
`state `

### Syntax and options


### Testing



## fitter
`fitter anything(name = cmd) , PStub(string asis) [ Classes(integer 0) RESults(string asis) Kfold(integer 1) RESTItle(string asis) THReshold(passthru)`

### Syntax and options
* cmd is the estimation command the user wishes to fit to the data
* <ins>ps</ins>tub(string asis) - A variable name to use to store the predicted values following model fitting.
* <ins>c</ins>lasses(integer 0) - An option used to determine whether the model is a regression or classification task.  This is subsequently passed to the classify program.
* <ins>res</ins>ults(string asis) - A name to use to store estimation results persistently using `estimates store`.
* <ins>k</ins>fold(integer 1) - An option used to determine if the model needs to be fitted over k subsets of the data.
* <ins>resti</ins>tle(string asis) - An option to add a title to the stored estimation results.  Only used in conjunction with the `results` option.
* <ins>thr</ins>eshold(passthru) - An option that is passed to the classify program for predicting class membership in classification tasks.

### TODO
- [ ] Determine how we will handle updating and substituting the if/in statements for estimation and prediction respectively

### Testing
- [ ] Biggest test will be ensuring that the if/in statements are handled appropriately for estimation and prediction.

## validate
`validate [if] [in], MEtric(string asis) [MOnitors(string asis) Pred(string asis) Obs(string asis) DISplay`

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

### Testing
- [ ] Need to ensure that the return scalars are correctly populated
- [ ] Test that the display option works correctly and that output is easy to read
- [ ] Test that approach to calling the Mata functions works as intended


## cvtt

### Syntax and options


### Testing


## cvtvt

### Syntax and options


### Testing


## xtcvtt

### Syntax and options


### Testing


## xtcvtvt

### Syntax and options


### Testing


## cvloo

### Syntax and options


### Testing


## xtcvloo

### Syntax and options


### Testing

