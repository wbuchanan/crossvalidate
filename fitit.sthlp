{smcl}
{* *! version 0.0.1 05feb2024}{...}
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
{cmd:fitit} {cmd:estimation command} {cmd:,} {cmdab:ps:tub(}{it:string asis}{cmd:)} 
{cmdab:spl:it(}{it:passthru}{cmd:)} {cmdab:res:ults(}{it:string asis}{cmd:)} 
[{cmdab:c:lasses(}{it:integer}{cmd:)} {cmdab:k:fold(}{it:integer}{cmd:)}
{cmdab:thr:eshold(}{it:real}{cmd:)} ]{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt ps:tub}}a new variable name for predicted values{p_end}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{synopt :{opt res:ults}}a stub for storing estimation results{p_end}
{syntab:Optional}
{synopt :{opt c:lasses}}is used to specify the number of classes for classification models; default is {cmd:classes(0)}.{p_end}
{synopt :{opt k:fold}}specifies the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synopt :{opt thr:eshold}}positive outcome threshold; default is {cmd:threshold(0.5)}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}{cmd:fitit} is part of the {help crossvalidate} suite of tools to implement crossvalidation methods with Stata estimation commands. {cmd:fitit} is used to fit the user specified model to the appropriate subset of the data in memory and to generate the predicted values following model fitting.  {cmd:fitit} depends on {help cmdmod} and {help classify}, which are also included with {help crossvalidate}.
{p_end}

{p 4 4 2}{cmd:fitit} takes the entire estimation command (options and all) as the first argument.  Internally, {help cmdmod} is used to append the appropriate condition to any existing if/in expressions to ensure that the model is fitted to the appropriate training set while still respecting any inclusion constraints specified by the end user.{p_end}

{p 4 4 2}{p_end}

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
{opt c:lasses} is used to distinguish between models of non-categorical data (
{opt c:lasses(0)}), binary data ({opt c:lasses(2)}), and multinomial/ordinal 
data ({opt c:lasses(>= 3)}).  You will only need to pass an argument to this 
parameter if you are using some form of a classification model.  Internally, it 
is used to determine whether to call {help predict} (in the case of 
{opt c:lasses(0)}) or {help classify} (in all other cases).

{phang}
{opt k:fold} defines the number of K-Folds used for the training set.  In other 
places, we reference using K-Fold cross-validation in the more common form, 
where the training set consists of multiple subsets of data.  However, standard 
train/test and train/validation/test splits are simply a special case of K-Fold 
cross-validation where there is only a single fold.  

{phang}
{opt thr:eshold} defines the probability cutoff used to determine a positive 
classification for binary response models.  This value functions the same way 
as it does in the case of {help estat_classification:estat classification}.


{marker examples}{...}
{title:Examples}

{p 4 4 2}Fitting a model{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata webuse lbw, clear}{p_end}
{p 4 4 2}Create a variable to identify the sample to fit the data to{p_end}
{p 8 4 2}{stata g byte touse = 1}{p_end}
{p 4 4 2}Fit a model to the data{p_end}
{p 8 4 2}{stata fitit "logit low age smoke", ps(pred) spl(touse) c(2) res(lmod))}{p_end}


{marker retvals}{...}
{title:Returned Values}
{p 4 4 8}The following lists the names of the e-macros and their contents.{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{cmd:e(estres#)}}the name to store the estimation results on the #th fold.{p_end}
{synopt :{cmd:e(estresnames)}}the names of all the estimation results{p_end}
{synopt :{cmd:e(estresall)}}the name used to store the estimation results for the entire training set when K-Fold cross-validation is used.{p_end}
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
