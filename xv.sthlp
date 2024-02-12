{smcl}
{* *! version 0.0.1 09feb2024}{...}
{vieweralsosee "[R] predict" "mansection R predict"}{...}
{vieweralsosee "[R] estat classification" "mansection R estat_classification"}{...}
{vieweralsosee "[P] creturn" "mansection P creturn"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "xv##syntax"}{...}
{viewerjumpto "Description" "xv##description"}{...}
{viewerjumpto "Options" "xv##options"}{...}
{viewerjumpto "Examples" "xv##examples"}{...}
{viewerjumpto "Returned Values" "xv##retvals"}{...}
{viewerjumpto "Additional Information" "xv##additional"}{...}
{viewerjumpto "Contact" "xv##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:xv} {it:# [#]} {cmd:,} {cmdab:ps:tub(}{it:string asis}{cmd:)} 
{cmdab:me:tric(}{it:string asis}{cmd:)} 
[{cmdab:se:ed(}{it:integer}{cmd:)}
{cmdab:u:id(}{it:varlist}{cmd:)} 
{cmdab:tp:oint(}{it:string asis}{cmd:)} {cmdab:k:fold(}{it:integer}{cmd:)} 
{cmdab:ret:ain(}{it:string asis}{cmd:)}
{cmdab:res:ults(}{it:string asis}{cmd:)}
{cmdab:c:lasses(}{it:integer}{cmd:)} {cmdab:thr:eshold(}{it:real}{cmd:)} 
{cmdab:noall} {cmdab:mo:nitors(}{it:string asis}{cmd:)} 
{cmdab:dis:play}] {cmd::} {cmd:{it:estimation command}}{p_end}

{* this should be udated to use additional tabs based on the underlying phase controlled}
{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt ps:tub}}a new variable name for predicted values{p_end}
{synopt :{opt me:tric}}the name of a function from {help libxv} or a user-defined function{p_end}
{syntab:Split}
{synopt :{opt se:ed}}to set the pseudo-random number generator seed{p_end}
{synopt :{opt u:id}}a variable list for clustered sampling/splitting{p_end}
{synopt :{opt tp:oint}}a numeric, td(), tc(), or tC() value{p_end}
{synopt :{opt k:fold}}the number of K-Folds to create in the training set; default is {cmd:kfold(1)}{p_end}
{synopt :{opt ret:ain}}a new variable name; default is {cmd:retain(_xvsplit)}{p_end}
{syntab:Fit}
{synopt :{opt res:ults}}a stub for storing estimation results{p_end}
{syntab:Predict}
{synopt :{opt c:lasses}}is used to specify the number of classes for classification models; default is {cmd:classes(0)}.{p_end}
{synopt :{opt thr:eshold}}positive outcome threshold; default is {cmd:threshold(0.5)}{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{syntab:Validate}
{synopt :{opt mo:nitors}}zero or more function names from {help libxv} or user-defined functions; default is {cmd monitors()}{p_end}
{synopt :{opt dis:play}}display results in window; default is off{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:xv} is a prefix command from the {help crossvalidate} suite of tools to 
implement cross-validation methods with Stata estimation commands. The {cmd:xv} 
prefix can be used with arbitrary estimation commands that return results using 
{help ereturn}.  It handles all four phases of cross-validation work: splitting 
the data into training, validation, and/or test splits (see {help splitit}); 
fitting the model you specify with your estimation command (see {help fitit}); 
generating out-of-sample/held-out predicted values (see {help predictit}); and 
computing validation metrics and monitors (see {help validateit}).  {cmd:xv} is 
a prefix that wraps the individual commands provided in the {help crossvalidate} 
suite intended to make the process of using cross-validation seemless and easy 
for Stata users.

{pstd}
{cmd:xv} can be used to generate simple random sampling based train/test splits 
or training/validation/test splits, K-Fold simple random samples, and Clustered 
simple random sampling (panel data is a special case).  A large number of 
validation metrics are implemented in {help libxv} and users are also free to 
define their own {help mata} functions that can be used by {cmd:xv} (see 
{help libxv} for additional information).  

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt ps:tub} is used to define a new variable name/stub for the predicted values
from the validation/test set.  When K-Fold cross-validation is used, this 
option defines the name of the variable containing the predicted values from 
each of the folds and will be used as a variable stub to store the results from 
fitting the model to all of the training data. 

{phang}
{opt me:tric} the name of a {help libxv} or user-defined function, with the 
function signature described in {help libxv:help libxv} used to evaluate the fit 
of the model on the held-out data.  Only a single metric can be specified.  For 
user's who may be interested in hyperparameter tuning, this would be the value 
that you would optimize with your hyperparameter tuning algorithm.

{dlgtab:Splitting the Data}

{phang}
{opt se:ed} accepts integer values used to set the pseudo-random number 
generator seed value.

{phang}
{opt u:id} accepts a variable list for clustered sampling/splitting.  When an 
argument is passed to this parameter entire clusters will be split into the 
respective training and validation and/or training sets.  When this option is 
used with {opt tp:oint} for {help xtset} data, the panel variable must be nested 
within the clusters defined by {opt u:id}.

{phang}
{opt tpoint} a time point delimiting the training split from it's corresponding 
forecastting split.  This can also be accomplished by passing the appropriate if 
expression in your estimation command.  Use of this option will result in an 
additional variable with the suffix {it:xv4} being created to identify the 
forecasting set associated with each split/K-Fold.  This is to ensure that 
the forecasting period data will not affect the model training.

{phang}
{opt k:fold} is used to specify the number of K-Folds to create in the training 
set. 

{phang}
{opt ret:ain} is used to specify the name of a new variable that will store the 
identifiers for the splits in the data.

{dlgtab:Model Fitting}

{phang}
{opt res:ults} is used to {help estimates_store:estimates store} the estimation 
results from each of the {opt k:fold} folds in the dataset.  When used with 
K-Fold cross-validation, the estimation results returned by {help ereturn} will 
be based on fitting the model to the entire training set.  Results from each of 
the training folds can be easily recovered using the appropriate reference 
passed to the {opt res:ults} option.  In this case, you will need to add the 
fold number as a suffix to the name you pass to the {opt res:ults} option to 
recover the estimation results for that fold.  The fold number identifies the 
held-out fold.  So, the number 1 will recover the model that was fitted to all 
of the training folds except number 1.

{dlgtab:Predicting Out-of-Sample Results}

{phang}
{opt c:lasses} is used to distinguish between models of non-categorical data (
{opt c:lasses(0)}), binary data ({opt c:lasses(2)}), and multinomial/ordinal 
data ({opt c:lasses(>= 3)}).  You will only need to pass an argument to this 
parameter if you are using some form of a classification model.  Internally, it 
is used to determine whether to call {help predict} (in the case of 
{opt c:lasses(0)}) or {help classify} (in all other cases).

{phang}
{opt thr:eshold} defines the probability cutoff used to determine a positive 
classification for binary response models.  This value functions the same way 
as it does in the case of {help estat_classification:estat classification}.

{phang}
{opt no:all} is an option to prevent predicting the outcome for a model fitted 
to the entire training set when using K-Fold cross-validation.  If this option 
is used, {opt kfi:fin} will have no effect since the relevant predictions will 
not be generated.

{dlgtab:Validating the Model}

{phang}
{opt mo:nitors} the name of zero or more {help libxv} or user-defined functions, 
with the function signature described in {help libxv:help libxv} used to 
evaluate the fit of the model on the held-out data.  These should not be used 
when attempting to tune hyper parameters, but can still provide useful 
information regarding the model fit characteristics.

{phang}
{opt dis:play} an option to display the metric and monitor values in the results 
window.


{marker examples}{...}
{title:Examples}

{p 4 4 2}Update these to reflect xv{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata sysuse auto, clear}{p_end}
{p 4 4 2}Train/Test Split with MSE validation metric{p_end}
{p 8 4 2}{stata "xv .8, metric(mse) ps(pred): reg price mpg i.foreign"}{p_end}


{marker retvals}{...}
{title:Returned Values}

{pstd}
The table below provides information about the macros returned by {cmd:xv} in 
addition to the macros that are returned by the estimation command you specify.  

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
{synopt :{cmd:r(stype)}}the split method{p_end}
{synopt :{cmd:r(flavor)}}the sampling method{p_end}
{synopt :{cmd:r(splitter)}}the variable containing the sample split identifiers{p_end}
{synopt :{cmd:r(forecastset)}}the variable containing the sample split identifiers for the forecast sample{p_end}
{synopt :{cmd:r(training)}}the value(s) of the splitter variable that identify the training set(s){p_end}
{synopt :{cmd:r(validation)}}the value of the splitter variable that identifies the validation set{p_end}
{synopt :{cmd:r(testing)}}the value of the splitter variable that identifies the test set{p_end}
{syntab:Fitting Macros}
{synopt :{cmd:e(estres#)}}the name to store the estimation results on the #th fold.{p_end}
{synopt :{cmd:e(estresnames)}}the names of all the estimation results{p_end}
{synopt :{cmd:e(estresall)}}the name used to store the estimation results for the entire training set when K-Fold cross-validation is used.{p_end}
{synopt :{cmd:e(predifin)}}the if expression to use when predicting on validation/test split.{p_end}
{synopt :{cmd:e(kfpredifin)}}the if expression to use when predicting on the K-Fold hold out set.{p_end}
{syntab:Validation Macros}
{synopt :{cmd:r(metric#)}}contains the metric value for the corresponding K-Fold{p_end}
{synopt :{cmd:r(`monitors'#)}}one scalar for each monitor passed to the monitors option, named by the monitor function with a numeric value to identify the corresponding K-Fold{p_end}
{synopt :{cmd:r(metricall)}}contains the metric value for K-Fold CV fitted to all of the K-Folds{p_end}
{synopt :{cmd:r(`monitors'all)}}contains the monitor values for K-Fold CV fitted to all of the K-Folds{p_end}
{synoptline}



{marker additional}{...}
{title:Additional Information}
{p 4 4 8}If you have questions, comments, or find bugs, please submit an issue in the {browse "https://github.com/wbuchanan/crossvalidate":crossvalidate GitHub repository}.{p_end}


{marker contact}{...}
{title:Contact}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Sr. Research Scientist, SAG Corporation{p_end}
{p 4 4 6}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}wbuchanan at sagcorp [dot] com{p_end}

{p 4 4 8}Steven Brownell{p_end}
{p 4 4 8}, SAG Corporation{p_end}
{p 4 4 6}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}sbrownell at sagcorp [dot] com{p_end}