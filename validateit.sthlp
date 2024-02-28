{smcl}
{* *! version 0.0.8 28feb2024}{...}
{viewerjumpto "Syntax" "validateit##syntax"}{...}
{viewerjumpto "Description" "validateit##description"}{...}
{viewerjumpto "Options" "validateit##options"}{...}
{viewerjumpto "Custom Metrics and Monitors" "validateit##custom"}{...}
{viewerjumpto "Built-In Metrics and Monitors" "validateit##builtin"}{...}
{viewerjumpto "Examples" "validateit##examples"}{...}
{viewerjumpto "Returned Values" "validateit##retvals"}{...}
{viewerjumpto "Additional Information" "validateit##additional"}{...}
{viewerjumpto "Contact" "validateit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:validateit} {cmd:,} {cmdab:me:tric(}{it:string asis}{cmd:)} 
{cmdab:ps:tub(}{it:string asis}{cmd:)} {cmdab:spl:it(}{it:varname}{cmd:)} [ 
{cmdab:o:bs(}{it:varname}{cmd:)} {cmdab:mo:nitors(}{it:string asis}{cmd:)} 
{cmdab:dis:play} {cmdab:k:fold(}{it:integer}{cmd:)} {cmdab:noall} {cmd:loo} 
{cmdab:na:me(}{it:string asis}{cmd:)}]{p_end}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt me:tric}}the name of a function from {help libxv} or a user-defined function{p_end}
{synopt :{opt ps:tub}}variable name stub for predicted values{p_end}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{syntab:Optional}
{synopt :{opt o:bs}}name of the dependent variable; default is {cmd:obs(`e(depvar)')}{p_end}
{synopt :{opt mo:nitors}}zero or more function names from {help libxv} or user-defined functions; default is {cmd:monitors()}{p_end}
{synopt :{opt dis:play}}display results in window; default is {cmd:off}{p_end}
{synopt :{opt k:fold}}the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{synopt :{opt loo}}is used only for Leave-One-Out cross-validation{p_end}
{synopt :{opt na:me}}is used to name the collection storing the results; default is {cmd:name(xvval)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

INCLUDE help xvphase-validate

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
{opt ps:tub} the stub name for the variable(s) that store the predicted values 
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
{opt noall} is an option to prevent evaluating model performance when using 
K-Fold cross-validation and also fitting the model to the full training set.

{phang}
{opt loo} is an option used to alter the underlying logic used to compute the 
validation metrics/monitors.  Since Leave-One-Out cross-validation is a special 
case of K-Fold CV the model fitting and predictions are generated in a manner 
consistent with all other K-Fold cases.  However, with only a single unit in 
each K-Fold in the LOO case computing validation metrics requires different 
treatment.  In the LOO case the validation metric/monitors are computed using 
the predicted and observed values for all of the training set units in aggregate.

{phang}
{opt na:me} is an option to pass a name to the collection created to store the 
results.  When {cmd validateit} is executed, it will initialize a new collection 
or replace the existing collection with the same name.  If you want to retain 
the validation results from multiple executions, pass an argument to this 
option.  {it:Note:} this only affects users using Stata 17 or later.


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

{marker builtin}{...}
{title:Built-In Metrics and Monitors}

{pstd}
The table below lists all of the validation measures that can be used as metrics 
or monitors with {cmd:validateit}.  The values in the name column below indicate 
what to specify in the {opt me:tric} and {opt mo:nitors} options to use the 
corresponding measures.  For additional information about each of the measures 
and references, please see {help libxv}.

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
INCLUDE help xvbintab
INCLUDE help xvmctab
INCLUDE help xvconttab
{synoptline}
{synopt :{opt ***}  {it:Note this requires installation of {search polychoric}}}

{marker binmtrx}
{title:Binary Metric Details}

INCLUDE help xvbinmtrx

{marker mcmtrx}
{title:Multiclass Metric Details}

INCLUDE help xvmcmtrx

{marker contmtrx}
{title:Continuous Metric Details}

INCLUDE help xvcontmtrx

{marker examples}{...}
{title:Examples}

{p 4 4 2}Without Monitors{p_end}
{p 8 4 2}validateit, me(mse) ps(pred) spl(splitvar){p_end}

{p 4 4 2}With Monitors{p_end}
{p 8 4 2}validateit, me(acc) ps(pred) spl(splitvar) mo(npv ppv bacc f1 sens spec){p_end}


{marker retvals}{...}
{title:Returned Values}

{pstd}
The following are returned by {cmd:validateit}:

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Scalars}
{synopt :{cmd:r(metric[#])}}contains the metric value for the corresponding K-Fold{p_end}
{synopt :{cmd:r(`monitors'[#])}}one scalar for each monitor passed to the monitors option, named by the monitor function with a numeric value to identify the corresponding K-Fold{p_end}
{synopt :{cmd:r(metricall)}}contains the metric value for K-Fold CV fitted to all of the K-Folds{p_end}
{synopt :{cmd:r(`monitors'all)}}contains the monitor values for K-Fold CV fitted to all of the K-Folds{p_end}
{syntab:Matrices}
{synopt :{cmd:r(xv)}}contains all of the monitor and metric values{p_end}
{synoptline}

{pstd}
Note, when used with ordinary train/test or train/validate/test splits, no 
numeric value will be appended to the name of the returned scalars.  The numeric 
suffix is only used in the contexts of K-Fold and Leave-One-Out cross-validation.
  In the case of K-Fold cross-validation, the numeric suffix indicates the fold 
identifier; the number identifies which fold is the held-out set among the 
K-folds in the training set.  In the case of Leave-One-Out cross-validation, a 
value of 1 indicates that the metrics are computed using the held out cases from 
the training split.
  
{marker additional}{...}
{title:Additional Information}
{pstd}
The {cmdab dis:play} option in validateit is enabled by 
{help collect_preview:collect preview}.  In addition to providing a convient way 
for us to structure the display in a useful way, it also makes it easy for you - 
the user - to export the validation results into any of several formats.  The 
results from {help validateit} are all stored in the collection named 
{cmd:xvval}.  For more information on how to export these results into the 
format of your choosing, please see {help collect_export:collect export}.

{pstd}
If you have questions, comments, or find bugs, please submit an issue in the 
{browse "https://github.com/wbuchanan/crossvalidate":crossvalidate GitHub repository}.


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
