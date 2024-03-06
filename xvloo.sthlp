{smcl}
{* *! version 0.0.5 06mar2024}{...}
{vieweralsosee "[R] predict" "mansection R predict"}{...}
{vieweralsosee "[R] estat classification" "mansection R estat_classification"}{...}
{vieweralsosee "[P] creturn" "mansection P creturn"}{...}
{vieweralsosee "crossvalidate package" "help crossvalidate"}{...}
{vieweralsosee "crossvalidate splitting" "help splitit"}{...}
{vieweralsosee "crossvalidate fitting" "help fitit"}{...}
{vieweralsosee "crossvalidate predicting" "help predictit"}{...}
{vieweralsosee "crossvalidate validating" "help validateit"}{...}
{vieweralsosee "crossvalidate libxv" "help libxv"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "xvloo##syntax"}{...}
{viewerjumpto "Description" "xvloo##description"}{...}
{viewerjumpto "Cross-Validation Phases" "xvloo##phases"}{...}
{viewerjumpto "Splitting Phase" "xvloo##split"}{...}
{viewerjumpto "Fitting Phase" "xvloo##fit"}{...}
{viewerjumpto "Predicting Phase" "xvloo##predict"}{...}
{viewerjumpto "Validating Phase" "xvloo##validate"}{...}
{viewerjumpto "Options" "xvloo##options"}{...}
{viewerjumpto "Examples" "xvloo##examples"}{...}
{viewerjumpto "Returned Values" "xv##looretvals"}{...}
{viewerjumpto "Additional Information" "xvloo##additional"}{...}
{viewerjumpto "Contact" "xvloo##contact"}{...}
{title:Leave-One-Out Cross-Validation in Stata}

{marker syntax}{...}
{title:Syntax}

{p 4 18 8}
{cmd:xvloo} {it:# [#]} {cmd:,} {cmd:pstub(}{it:string asis}{cmd:)} 
{cmd:metric(}{it:string asis}{cmd:)} 
[{cmd:seed(}{it:integer}{cmd:)}
{cmd:uid(}{it:varlist}{cmd:)} 
{cmd:tpoint(}{it:string asis}{cmd:)} 
{cmd:split(}{it:string asis}{cmd:)}
{cmd:results(}{it:string asis}{cmd:)}
{cmd:classes(}{it:integer}{cmd:)} {cmd:threshold(}{it:real}{cmd:)} 
{cmd:noall} {cmd:monitors(}{it:string asis}{cmd:)} 
{cmd:display} {cmd:retain}
{cmd:fitnm(}{it:string asis}{cmd:)} 
{cmd:valnm(}{it:string asis}{cmd:)} 
] {cmd::} {cmd:{it:estimation command}}{p_end}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Arguments}
{synopt :{opt #}}The proportion of the data set to allocate to the training set.{p_end}
{synopt :{it:{opt [#]}}}The proportion of the data set to allocate to the validation set.{p_end}
{syntab:Required}
{synopt :{opt pstub}}a new variable name for predicted values{p_end}
{synopt :{opt metric}}the name of a function from {help libxv} or a user-defined function{p_end}
{syntab:Split}
{synopt :{opt seed}}to set the pseudo-random number generator seed{p_end}
{synopt :{opt uid}}a variable list for clustered sampling/splitting{p_end}
{synopt :{opt tpoint}}a numeric, td(), tc(), or tC() value{p_end}
{synopt :{opt split}}a new variable name; default is {cmd:split(_xvsplit)}{p_end}
{syntab:Fit}
{synopt :{opt results}}a stub for storing estimation results{p_end}
{syntab:Predict}
{synopt :{opt classes}}is used to specify the number of classes for classification models; default is {cmd:classes(0)}.{p_end}
{synopt :{opt threshold}}positive outcome threshold; default is {cmd:threshold(0.5)}{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{synopt :{opt fitnm}}is used to name the collection storing the results; default is {cmd:fitnm(xvfit)}.{p_end}
{syntab:Validate}
{synopt :{opt monitors}}zero or more function names from {help libxv} or user-defined functions; default is {cmd:monitors()}{p_end}
{synopt :{opt valnm}}is used to name the collection storing the results; default is {cmd:valnm(xvval)}.{p_end}
{syntab:General}
{synopt :{opt display}}display results in window; default is off{p_end}
{synopt :{opt retain}}retains the variables and stored estimation results{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xvloo} is a prefix command from the {help crossvalidate} suite of tools to 
implement Leave-One-Out (LOO) cross-validation methods with Stata estimation 
commands. The {cmd:xvloo} prefix can be used with arbitrary estimation commands 
that return results using {help ereturn}.  It handles all four phases of 
cross-validation work: splitting the data into training, validation, and/or test 
splits (see {help splitit}); fitting the model you specify with your estimation 
command (see {help fitit}); generating out-of-sample/held-out predicted values 
(see {help predictit}); and computing validation metrics and monitors (see 
{help validateit}).  {cmd:xvloo} is a prefix that wraps the individual commands 
provided in the {help crossvalidate} suite intended to make the process of using 
cross-validation seemless and easy for Stata users.

{pstd}
{cmd:IMPORTANT:} you must specify the full name of the options used by 
{cmd:xvloo}.  If you attempt to pass an abbreviated option name, it will not be 
recognized by the command and will be ignored.  Additionally, while 
{help validateit} includes a {opt loo} option, it is unnecessary to use that 
option with this prefix.  

INCLUDE help xvphases

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt pstub} is used to define a new variable name/stub for the predicted values
from the validation/test set.  When K-Fold cross-validation is used, this 
option defines the name of the variable containing the predicted values from 
each of the folds and will be used as a variable stub to store the results from 
fitting the model to all of the training data. 

{phang}
{opt metric} the name of a {help libxv} or user-defined function, with the 
function signature described in {help libxv:help libxv} used to evaluate the fit 
of the model on the held-out data.  Only a single metric can be specified.  For 
user's who may be interested in hyperparameter tuning, this would be the value 
that you would optimize with your hyperparameter tuning algorithm.

{dlgtab:Splitting the Data}

{phang}
{opt seed} accepts integer values used to set the pseudo-random number 
generator seed value.

{phang}
{opt uid} accepts a variable list for clustered sampling/splitting.  When an 
argument is passed to this parameter entire clusters will be split into the 
respective training and validation and/or training sets.  When this option is 
used with {opt tpoint} for {help xtset} data, the panel variable must be nested 
within the clusters defined by {opt uid}.

{phang}
{hi:IMPORTANT!!!} the order of the {help varlist} passed to {opt u:id} is 
assumed to follow the hierarchy of the nesting in the data.  Ensure that the 
{help varlist} passed to this option follows the same convention as used with 
commands like {help mixed}.

{phang}
{opt tpoint} a time point delimiting the training split from it's corresponding 
forecastting split.  This can also be accomplished by passing the appropriate if 
expression in your estimation command.  Use of this option will result in an 
additional variable with the suffix {it:xv4} being created to identify the 
forecasting set associated with each split/K-Fold.  This is to ensure that 
the forecasting period data will not affect the model training.

{phang}
{opt split} is used to specify the name of a new variable that will store the 
identifiers for the splits in the data.

{dlgtab:Model Fitting}

{phang}
{opt results} is used to {help estimates_store:estimates store} the estimation 
results from each of the {opt kfold} folds in the dataset.  When used with 
K-Fold cross-validation, the estimation results returned by {help ereturn} will 
be based on fitting the model to the entire training set.  Results from each of 
the training folds can be easily recovered using the appropriate reference 
passed to the {opt results} option.  In this case, you will need to add the 
fold number as a suffix to the name you pass to the {opt results} option to 
recover the estimation results for that fold.  The fold number identifies the 
held-out fold.  So, the number 1 will recover the model that was fitted to all 
of the training folds except number 1.

{phang}
{opt fitnm} is an option to pass a name to the collection created to store the 
results.  When {cmd fitit} is executed, it will initialize a new collection 
or replace the existing collection with the same name.  If you want to retain 
the validation results from multiple executions, pass an argument to this 
option.  {it:Note:} this only affects users using Stata 17 or later.

{dlgtab:Predicting Out-of-Sample Results}

{phang}
{opt classes} is used to distinguish between models of non-categorical data (
{opt classes(0)}), binary data ({opt classes(2)}), and multinomial/ordinal 
data ({opt classes(>= 3)}).  You will only need to pass an argument to this 
parameter if you are using some form of a classification model.  Internally, it 
is used to determine whether to call {help predict} (in the case of 
{opt classes(0)}) or {help classify} (in all other cases).

{phang}
{opt threshold} defines the probability cutoff used to determine a positive 
classification for binary response models.  This value functions the same way 
as it does in the case of {help estat_classification:estat classification}.

{phang}
{opt noall} is an option to prevent fitting, predicting, and validating a model 
that is fitted to the entire training set when using K-Fold cross-validation 
with a train/test or train/validation/test split. 

{dlgtab:Validating the Model}

{phang}
{opt monitors} the name of zero or more {help libxv} or user-defined functions, 
with the function signature described in {help libxv:help libxv} used to 
evaluate the fit of the model on the held-out data.  These should not be used 
when attempting to tune hyper parameters, but can still provide useful 
information regarding the model fit characteristics.

{phang}
{opt valnm} is an option to pass a name to the collection created to store the 
results.  When {cmd validateit} is executed, it will initialize a new collection 
or replace the existing collection with the same name.  If you want to retain 
the validation results from multiple executions, pass an argument to this 
option.  {it:Note:} this only affects users using Stata 17 or later.

{dlgtab:General Options}

{phang}
{opt display} an option to display the metric and monitor values in the results 
window.

{phang}
{opt retain} is used to retain the variables created, stored estimation results, 
and dataset characteristics that are generated by {cmd:xvloo}.

{marker examples}{...}
{title:Examples}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata sysuse auto, clear}{p_end}
{p 4 4 2}80% Leave-One-Out Train/Test Split with MSE validation metric{p_end}
{p 8 4 2}{stata "xvloo .8, metric(mse) pstub(pred): reg price mpg i.foreign"}{p_end}

{marker retvals}{...}
{title:Returned Values}

{pstd}
The table below provides information about the macros, scalars, and matrices 
returned by {cmd:xv} in addition to the macros, scalars, and matrices returned 
by the estimation command you specify.  

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
{syntab:State Macros}
{synopt :{cmd:e(rng)}}the current set rng setting{p_end}
{synopt :{cmd:e(rngcurrent)}}the current RNG in effect{p_end}
{synopt :{cmd:e(rngstate)}}the current state of the runiform() generator{p_end}
{synopt :{cmd:e(rngseed)}}the seed last set for the stream RNG{p_end}
{synopt :{cmd:e(rngstream)}}the current stream of the stream RNG{p_end}
{synopt :{cmd:e(filename)}}the name of the file loaded in memory{p_end}
{synopt :{cmd:e(filedate)}}the last saved date of the file in memory{p_end}
{synopt :{cmd:e(version)}}the current Stata version{p_end}
{synopt :{cmd:e(currentdate)}}the current date{p_end}
{synopt :{cmd:e(currenttime)}}the current time{p_end}
{synopt :{cmd:e(stflavor)}}the flavor of Stata currently in use (i.e., BE, SE, MP){p_end}
{synopt :{cmd:e(processors)}}the number of processors currently set for use{p_end}
{synopt :{cmd:e(hostname)}}the name of the host machine{p_end}
{synopt :{cmd:e(machinetype)}}description of the hardware platform{p_end}
{syntab:Splitting Macros}
{synopt :{cmd:e(stype)}}the split method{p_end}
{synopt :{cmd:e(flavor)}}the sampling method{p_end}
{synopt :{cmd:e(splitter)}}the variable containing the sample split identifiers{p_end}
{synopt :{cmd:e(forecastset)}}the variable containing the sample split identifiers for the forecast sample{p_end}
{synopt :{cmd:e(training)}}the value(s) of the splitter variable that identify the training set(s){p_end}
{synopt :{cmd:e(validation)}}the value of the splitter variable that identifies the validation set{p_end}
{synopt :{cmd:e(testing)}}the value of the splitter variable that identifies the test set{p_end}
{syntab:Fitting Macros}
{synopt :{cmd:e(estres#)}}the name to store the estimation results on the #th fold.{p_end}
{synopt :{cmd:e(estresnames)}}the names of all the estimation results{p_end}
{synopt :{cmd:e(estresall)}}the name used to store the estimation results for the entire training set when K-Fold cross-validation is used.{p_end}
{synopt :{cmd:e(fitnm)}}the name used for the collection containing model fit results.{p_end}
{syntab:Validation Scalars}
{synopt :{cmd:e(metric1)}}contains the metric value for the training set{p_end}
{synopt :{cmd:e(`monitors'1)}}one scalar for each monitor passed to the monitors option, named by the monitor function for the entire training set{p_end}
{synopt :{cmd:e(metricall)}}contains the metric value for the predictions on the validation/test set{p_end}
{synopt :{cmd:e(`monitors'all)}}contains the monitor values for the predictions on the validation/test set{p_end}
{synopt :{cmd:e(valnm)}}the name used for the collection containing model validation results.{p_end}
{syntab:Matrices}
{synopt :{cmd:e(xv)}}contains all of the monitor and metric values{p_end}
{synoptline}

{marker additional}{...}
{title:Additional Information}
{p 4 4 8}If you have questions, comments, or find bugs, please submit an issue in the {browse "https://github.com/wbuchanan/crossvalidate":crossvalidate GitHub repository}.{p_end}

{marker contact}{...}
{title:Contact}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Sr. Research Scientist, SAG Corporation{p_end}
{p 4 4 8}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}wbuchanan at sagcorp [dot] com{p_end}

{p 4 4 8}Steven D. Brownell, Ph.D.{p_end}
{p 4 4 8}Economist, SAG Corporation{p_end}
{p 4 4 8}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}sbrownell at sagcorp [dot] com{p_end}
