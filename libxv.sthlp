{smcl}
{* *! version 0.0.4 28feb2024}{...}
{vieweralsosee "[R] predict" "mansection R predict"}{...}
{vieweralsosee "[R] estat classification" "mansection R estat_classification"}{...}
{vieweralsosee "[P] creturn" "mansection P creturn"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Overview" "libxv##overview"}{...}
{viewerjumpto "Utility Functions" "libxv##utilities"}{...}
{viewerjumpto "Classification Metrics" "libxv##classification"}{...}
{viewerjumpto "Binary Metrics" "libxv##binary"}{...}
{viewerjumpto "Multiclass Metrics" "libxv##multiclass"}{...}
{viewerjumpto "Regression Metrics" "libxv##regression"}{...}
{viewerjumpto "Custom Metrics" "libxv##custom"}{...}
{viewerjumpto "Additional Information" "libxv##additional"}{...}
{viewerjumpto "Contact" "libxv##contact"}{...}
{marker overview}{...}
{title:Overview of Libxv}

{pstd}
{cmd:libxv} is the Mata library that enables the {help xv}, {help xvloo}, and 
other commands in the {help crossvalidate} package to do what they do.  All of 
the validation/test metrics are defined as Mata {help m2_declarations:functions}.  
There are also functions that are used for the 
{browse "https://wbuchanan.github.io/stataConference2023/":metaprogramming} 
techniques that allow the user to specify their model fitting commands the same 
way they would any other time they are using Stata.  However, the bulk of this 
Mata library is comprised of validation/test metrics.  All metrics used by the 
command {help validateit} follow the same function signature:

{pstd}
real scalar {it:functionName}(string scalar pred, string scalar obs, string scalar touse)

{pstd}
This standardized function signature makes it possible for users to write and 
call their own validation metrics without having to do any of the heavy lifting 
associated with any other part of the cross-validation process.  However, it 
also imposes some restrictions on what and/or how things can be done.  For 
example, metrics for multiclass methods that would return a value for each of 
the classes being predicted cannot be handled.  Functions that might otherwise 
allow the specification of a parameter to adjust the computation are also 
unable to be accommodated.  If you find the need to use that type of a 
validation/test metric, you could still avoid having to write an entire 
cross-validation pipeline by using {help splitit} and {help fitit} to do that 
work for you.  Then, predict the values of interest and compute your metric.  If 
what we've provided in this package already meets your needs, feel free to use 
the {help xv} prefix instead to let the computer do the work.

{marker utilities}{...}
{title:Utility Functions}

{pstd}
{cmd:getifin} is a utility function used to extract {ifin} expressions from the 
estimation command used by the user.  The returned string then allows the 
commands in {help crossvalidate} to modify these expressions to ensure that the 
model is fitted on the appropriate subset of data and the predictions are made 
on the correct subset of data.

{pstd}
{cmd:getnoifin} in the case where the user does not pass an estimation command 
with {ifin} expressions, this function is used to extract the estimation command 
string up to the comma used to delimit options to the command. The returned 
string then allows the commands in {help crossvalidate} to modify the estimation 
command to include an if expression to ensure that the model is fitted on the 
appropriate subset of data and the predictions are made on the correct subset of 
data.

{pstd}
{cmd:hasoptions} is a convenience function used to determine if the estimation 
command passed by the user contains options.

{pstd}
{cmd:cvparse} is a function used by the {help xv} and {help xvloo} prefix 
commands to parse options passed to the command.  It returns valid options in 
local macros using the name of the option.  In effect, this makes all of the 
options for {help xv} and {help xvloo} operate as {it:passthru} type options 
(see {help syntax} for additional information about passthru).  

{pstd}
{cmd:getarg} is a function used the {help xv} and {help xvloo} prefix commands 
to extract the arguments passed to the options of those commands. It may also be 
used in the future to expand the existing function signature for metrics to 
allow passing optional arguments to the functions by including them as an 
argument to the metric/monitor name (e.g., mae(1), r2("wgt"), etc...).  However, 
work on this possible extension has not yet commenced.

{pstd}
{cmd:struct Crosstab} is a struct defined in {opt libxv}.  It stores the 
following results in the corresponding members:

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Member Name}
{synoptline}
{synopt :{opt conf}}The confusion matrix{p_end}
{synopt :{opt rowm}}A column vector containing the row margins from the confusion matrix{p_end}
{synopt :{opt correct}}A column vector containing the diagonal of the confusion matrix{p_end}
{synopt :{opt values}}A column vector containing the unique values of the dependent variable.{p_end}
{synopt :{opt colm}}A row vector containing the column margins from the confusion matrix{p_end}
{synopt :{opt n}}A scalar containing the total sample size.{p_end}
{synopt :{opt tp}}A scalar containing the total number of correctly predicted outcomes.{p_end}
{synopt :{opt levs}}A scalar containing the number of distict levels of the dependent variable.{p_end}
{synoptline}

{pstd}
{cmd:xtab} is a function that returns a scalar instance of the 
{cmd:Crosstab struct}.  It is used internally by the binary and multiclass 
metrics to obtain the confusion matrix and other pre-computed statistics that 
are used regularly by the metrics.

{pstd}
{cmd:isnested} is a function used to test whether variables are nested within 
one another.  It takes a {help varlist} containing the variables that are nested 
ordered from the highest to lowest level of the hierarchy and a {help varname} 
that is used to identify which observations to include in the test.  A value of 
1 is returned if the data are nested and a value of 0 is returned otherwise. 

{marker classification}{...}
{title:Classification Metrics}

{pstd}
In addition to reiterating what was said above about multiclass metrics, there 
also needs to be a discussion about methods related to probabilities only 
such as ROC/AUC type metrics and how those are not currently handled, but could 
potentially be in the future.  There should also be a mention about noting that 
some of the binary metrics that generalize naturally to the multiclass context 
are used under the hood by the multiclass functions and can be used in both 
scenarios (with the specifics being reserved to the sections below).

{marker binary}{...}
{title:Binary Metrics}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
INCLUDE help xvbintab
{synoptline}

INCLUDE help xvbinmtrx

{marker multiclass}{...}
{title:Multiclass Metrics}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
INCLUDE help xvmctab
{synoptline}
{synopt :{opt ***}  {it:Note this requires installation of {search polychoric}}}

INCLUDE help xvmcmtrx

{marker regression}{...}
{title:Regression Metrics}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
INCLUDE help xvconttab
{synoptline}

INCLUDE help xvcontmtrx

{marker custom}{...}
{title:Custom Metrics}
{* * Not sure what additional information might be useful here.}
{pstd}
Users may define their own validation metrics to be used by {cmd:validateit}.  
All metrics and monitors are required to use the same function signature:

{pstd}
real scalar {it:functionName}(string scalar pred, string scalar obs, string scalar touse)

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
