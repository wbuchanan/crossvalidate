# Specifications for crossvalidation package


## What should it do?
* Allow users to define a train/test or train/validation/test split and fit 
* models to the data defined by the splits

## How will it be accomplished?
* A few prefix commands, ala brewproof, that handle the splitting, fitting, and 
* computing of metrics that should be reported.

## Known challenges
- [x] Parsing and defining the API for the prefix command consistently
- [ ] Returning results in ereturn in a reasonable way
- [x] Handling if/in conditions in the estiamtion command
- [ ] Allowing arbitrary validation/test metrics
- [ ] Consideration for how this could be used for hyperparameter tuning in the future
- [ ] Determine how multiclass predictions will be handled

## Example:
`ttsplit 0.8, metric(mse): reg price mpg length if foreign != 1`

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
- [ ] splitter - a program that handles defining the splits of the dataset for the 
main end user facing commands also needs to handle potential persistence of group membership (e.g., folds or train/validation/test splits)
- [ ] fitter - a program that handles fitting the statistical model to the data, also needs to handle storage of results
- [ ] validate - a program that will handled the validation portion of the training loop (e.g., computing monitors and/or test metrics and returning those values as well)
- [ ] classify - a program that can return the predicted class from classification based models (e.g., logit, ologit, mlogit, etc...)


## Mata Stuff
- [x] `getifin` function to handle parsing if/in expressions in the estimation command
- [x] `repifin` function to handle replacing user if/in w/exp that includes training set
- [x] `cvparse` function to handle parsing the options for the prefix commands
- [x] `getarg` function to handle retrieving the argument value from options
- [ ] metric specification 
- [ ] monitor specification

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

