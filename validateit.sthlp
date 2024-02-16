{smcl}
{* *! version 0.0.2 16feb2024}{...}
{viewerjumpto "Syntax" "validateit##syntax"}{...}
{viewerjumpto "Description" "validateit##description"}{...}
{viewerjumpto "Options" "validateit##options"}{...}
{viewerjumpto "Custom Metrics and Monitors" "validateit##custom"}{...}
{viewerjumpto "Examples" "validateit##examples"}{...}
{viewerjumpto "Returned Values" "validateit##retvals"}{...}
{viewerjumpto "Additional Information" "validateit##additional"}{...}
{viewerjumpto "Contact" "validateit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:validateit} {cmd:,} {cmdab:me:tric(}{it:string asis}{cmd:)} 
{cmdab:p:red(}{it:string asis}{cmd:)} {cmdab:spl:it(}{it:varname}{cmd:)} [ 
{cmdab:o:bs(}{it:varname}{cmd:)} {cmdab:mo:nitors(}{it:string asis}{cmd:)} 
{cmdab:dis:play}]{p_end}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt me:tric}}the name of a function from {help libxv} or a user-defined function{p_end}
{synopt :{opt p:red}}variable name stuf for predicted values{p_end}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{syntab:Optional}
{synopt :{opt o:bs}}name of the dependent variable; default is {cmd obs(`e(depvar)')}{p_end}
{synopt :{opt mo:nitors}}zero or more function names from {help libxv} or user-defined functions; default is {cmd monitors()}{p_end}
{synopt :{opt dis:play}}display results in window; default is off{p_end}
{synopt :{opt k:fold}}the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd} 
{cmd:validateit} is part of the {help crossvalidate} suite of tools to implement 
cross-validation methods with Stata estimation commands. {cmd:validateit} is 
used to compute the validation metric and monitors.  For additional information 
about the measurement functions available in {help crossvalidate} please see 
help {help libxv}.

{pstd}
{cmd:validateit} makes a distinction between statistics used to monitor the 
performance and/or characteristics of the model fit to the out-of-sample, or 
held-out, set and statistics used as metrics for hyperparameter tuning.  While 
{help crossvalidate} does not currently provide any options for hyperparameter 
tuning, this distinction is important for an users who wish to implement any 
existing hyperparameter tuning algorithms that optimize a single value.  

{pstd}
{cmd:validateit} will only produce results for a test set in the context of a 
train/test split without K-Fold cross-validation.  It is possible to suppress 
using the test split with K-Fold cross-validation using the {opt:noall} option. 
Because the test set should only be used for a single evaluation of the model's 
performance, we leave it to the user to perform that final evaluation when the 
user has created a validation set for cross-validation.  Naturally, this implies 
that hyperparameter tuning should not be attempted with a train/test split, 
since it will inevitably lead to overfitting on the test set thus defeating the 
purpose of the held out set.  As the package evolves we will provide additional 
guidance to users on alternative strategies they may consider (e.g., calling 
{help splitit} to generate K-Folds then calling it again while passing the first 
{opt split} variable as an option to {opt uid} to generate a set of K-Folds 
within each K-Fold). 

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt me:tric} the name of a {help libxv} or user-defined function, with the 
function signature described in {help libxv:help libxv} used to evaluate the fit 
of the model on the held-out data.  Only a single metric can be specified.  For 
user's who may be interested in hyperparameter tuning, this would be the value 
that you would optimize with your hyperparameter tuning algorithm.

{phang}
{opt p:red} the stub name for the variable(s) that store the predicted values 
after calling {help predictit}.

{phang}
{opt spl:it} must contain the name of the variable that stores the test, 
validation, and test splits.  There will only be a single variable if the splits 
were created using {help splitit}.  

{dlgtab:Optional}

{phang}
{opt o:bs} the name of the variable containing the observed values. 

{phang}
{opt mo:nitors} the name of zero or more {help libxv} or user-defined functions, 
with the function signature described in {help libxv:help libxv} used to 
evaluate the fit of the model on the held-out data.  These should not be used 
when attempting to tune hyper parameters, but can still provide useful 
information regarding the model fit characteristics.

{phang}
{opt dis:play} an option to display the metric and monitor values in the results 
window.

{phang}
{opt k:fold} defines the number of K-Folds used for the training set.  When the 
value is > 1, this will result in metric and monitor computations for each of 
the K-Folds.  Additionally, it will also compute the metric and monitor values 
for the model fitted to all of the training data.

{phang}
{opt no:all} is an option to prevent evaluating model performance when using 
K-Fold cross-validation and also fitting the model to the full training set.

{marker custom}{...}
{title:Custom Metrics and Monitors}

{pstd}
Users may define their own validation metrics to be used by {cmd:validateit}.  
All metrics and monitors are required to use the same function signature:

{p 12 12 2}{cmd:{it:real scalar metricName(string scalar pred, string scalar obs, string scalar touse)}}{p_end}

{pstd}
The first argument passed to your function will be the name of the variable 
containing the predicted values.  The second argument passed to your function 
will be the name of the variable containing the observed outcomes.  The last 
argument in the signature is a variable that identifies the validation/test set, 
or the K-Fold with the out-of-sample predicted values, to compute the validation 
metric on.

{pstd}
In your function, you can easily define the vectors that will store the data you 
need for your computations:

{p 12 12 2}{cmd:{it:real colvector y, yhat}}{p_end}
{p 12 12 2}{cmd:{it:y = st_data(., obs, touse)}}{p_end}
{p 12 12 2}{cmd:{it:yhat = st_data(., pred, touse)}}{p_end}

{pstd}
With your custom metric function defined in Mata with the signature above, you 
can use it as a metric or monitor with {cmd:validateit} by passing the function 
name to the metric or monitors options.  {it:Note, you will need to make sure 
that the function is defined in Mata prior to using it or ensure that it is 
defined in a library that Mata will search automatically}.

{marker examples}{...}
{title:Examples}


{p 4 4 2}Without Monitors{p_end}
{p 8 4 2}validateit, me(mse) p(pred){p_end}

{p 4 4 2}With Monitors{p_end}
{p 8 4 2}validateit, me(accuracy) p(pred) mo(npv ppv baccuracy f1 sensitivity specificity){p_end}


{marker retvals}{...}
{title:Returned Values}
{pstd}
The following lists the names of the r-scalars and their contents:

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{cmd:r(metric[#])}}contains the metric value for the corresponding K-Fold{p_end}
{synopt :{cmd:r(`monitors'[#])}}one scalar for each monitor passed to the monitors option, named by the monitor function with a numeric value to identify the corresponding K-Fold{p_end}
{synopt :{cmd:r(metricall)}}contains the metric value for K-Fold CV fitted to all of the K-Folds{p_end}
{synopt :{cmd:r(`monitors'all)}}contains the monitor values for K-Fold CV fitted to all of the K-Folds{p_end}
{synoptline}

{pstd}
Note, when used with ordinary train/test or train/validate/test splits, no 
numeric value will be appended to the name of the returned scalars.  The numeric 
suffix is only used in the context of K-Fold cross-validation in order to 
provide information specific to each of the K-Folds.

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
