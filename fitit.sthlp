{smcl}
{* *! version 0.0.3 12feb2024}{...}
{vieweralsosee "[R] estat classification" "mansection R estat_classification"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "fitit##syntax"}{...}
{viewerjumpto "Description" "fitit##description"}{...}
{viewerjumpto "Options" "fitit##options"}{...}
{viewerjumpto "Examples" "fitit##examples"}{...}
{viewerjumpto "Returned Values" "fitit##retvals"}{...}
{viewerjumpto "Additional Information" "fitit##additional"}{...}
{viewerjumpto "Contact" "fitit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:fitit} {it:"estimation command"} {cmd:,} {cmdab:spl:it(}{it:passthru}{cmd:)} 
{cmdab:res:ults(}{it:string asis}{cmd:)} [ {cmdab:k:fold(}{it:integer}{cmd:)} 
{cmd:noall} {cmdab:dis:play}]{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{synopt :{opt res:ults}}a stub for storing estimation results{p_end}
{syntab:Optional}
{synopt :{opt k:fold}}specifies the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{synopt :{opt dis:play}}display results in window; default is {cmd:off}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:fitit} is part of the {help crossvalidate} suite of tools to implement 
cross-validation methods with Stata estimation commands. {cmd:fitit} is used to 
fit the user specified model to the appropriate subset of the data in memory.  
{cmd:fitit} depends on {help cmdmod}, which is also included with 
{help crossvalidate}.

{pstd}
{cmd:fitit} takes the entire estimation command (options and all) as the first 
argument.  Internally, {help cmdmod} is used to append the appropriate condition 
to any existing if expressions to ensure that the model is fitted to the 
appropriate training set while still respecting any inclusion constraints 
specified by the end user.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt spl:it} must contain the name of the variable that stores the test, 
validation, and test splits.  There will only be a single variable if the splits 
were created using {help splitit}.  

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

{dlgtab:Optional}

{phang}
{opt k:fold} defines the number of K-Folds used for the training set.  In other 
places, we reference using K-Fold cross-validation in the more common form, 
where the training set consists of multiple subsets of data.  However, standard 
train/test and train/validation/test splits are simply a special case of K-Fold 
cross-validation where there is only a single fold.  

{phang}
{opt no:all} is an option to prevent predicting the outcome for a model fitted 
to the entire training set when using K-Fold cross-validation.  If this option 
is used, {opt kfi:fin} will have no effect since the relevant predictions will 
not be generated.

{phang}
{opt dis:play} an option to display the model fitting results in the result 
window.  If using a large number of K-Folds, it may be useful to not print all 
of the model fitting results to the result window.


{marker examples}{...}
{title:Examples}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata sysuse auto.dta, clear}{p_end}
{p 4 4 2}Expand the data to create identical K-Folds{p_end}
{p 8 4 2}{stata expand 6}{p_end}
{p 4 4 2}Create a "split" identifier{p_end}
{p 8 4 2}{stata "bys make: g byte spvar = _n"}{p_end}
{p 4 4 2}Fit a model to each of the K-Folds and all of the training set{p_end}
{p 8 4 2}{stata fitit "reg price mpg headroom", spl(spvar) res(tst) kf(5)}{p_end}
{p 4 4 2}Fit the model only the the individual K-Folds{p_end}
{p 8 4 2}{stata fitit "reg price mpg headroom", spl(spvar) res(tst) kf(5) noall}{p_end}


{marker retvals}{...}
{title:Returned Values}
{p 4 4 8}The following lists the names of the e-macros and their contents.{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
{synopt :{cmd:e(estres#)}}the name to store the estimation results on the #th fold.{p_end}
{synopt :{cmd:e(estresnames)}}the names of all the estimation results{p_end}
{synopt :{cmd:e(estresall)}}the name used to store the estimation results for the entire training set when K-Fold cross-validation is used.{p_end}
{synopt :{cmd:e(predifin)}}the if expression to use when predicting on validation/test split.{p_end}
{synopt :{cmd:e(kfpredifin)}}the if expression to use when predicting on the K-Fold hold out set.{p_end}
{synoptline}

{p 4 4 8}{cmd:fitit} also reposts the e-return values from the model fitted to the entire training set.  As a reminder, when used with {opt k:fold} > 1, the results returned by {help ereturn} will come from fitting the model to the entire training set (e.g., all of the K-Folds simultaneously).  The results from individual folds can be recovered by appending the held-out fold number to the value passed to {opt res:ults} and calling {help estimates_restore:estimates restore}.{p_end}

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
