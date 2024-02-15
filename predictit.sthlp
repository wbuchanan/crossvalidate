{smcl}
{* *! version 0.0.2 15feb2024}{...}
{vieweralsosee "[R] estat classification" "mansection R estat_classification"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "predictit##syntax"}{...}
{viewerjumpto "Description" "predictit##description"}{...}
{viewerjumpto "Options" "predictit##options"}{...}
{viewerjumpto "Examples" "predictit##examples"}{...}
{viewerjumpto "Additional Information" "predictit##additional"}{...}
{viewerjumpto "Contact" "predictit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:predictit} {it:"estimation command"} {cmd:,} {cmdab:ps:tub(}{it:string asis}{cmd:)} 
[{cmdab:spl:it(}{it:varname}{cmd:)} {cmdab:c:lasses(}{it:integer}{cmd:)} 
{cmdab:k:fold(}{it:integer}{cmd:)} {cmdab:thr:eshold(}{it:real}{cmd:)} 
{cmdab:mod:ifin(}{it:string asis}{cmd:)} {cmdab:kfi:fin(}{it:string asis}{cmd:)}
{cmdab:noall} {cmdab:pm:ethod(}{it:string asis}{cmd:)}]{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt ps:tub}}a new variable name for predicted values{p_end}
{syntab:Optional}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{synopt :{opt c:lasses}}is used to specify the number of classes for classification models; default is {cmd:classes(0)}.{p_end}
{synopt :{opt k:fold}}specifies the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synopt :{opt thr:eshold}}positive outcome threshold; default is {cmd:threshold(0.5)}{p_end}
{synopt :{opt mod:ifin}}a modified if expression{p_end}
{synopt :{opt kfi:fin}}a modified if expression{p_end}
{synopt :{opt noall}}suppresses prediction on entire training set for K-Fold cases{p_end}
{synopt :{opt pm:ethod}}predicted statistic from {help predict}; default is {cmd:pmethod(pr)}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:predictit} is part of the {help crossvalidate} suite of tools to 
implement crossvalidation methods with Stata estimation commands. 
{cmd:predictit} is used to generate the predicted values for validation after 
fitting the models to the data. {cmd:predictit} depends on {help cmdmod} and 
{help classify}, which are also included with {help crossvalidate}.

{pstd}
{cmd:predictit} can take the entire estimation command (options and all) as the 
first argument.  In that case, users are required to pass the split variable 
name to the {opt spl:it} option.  Internally, {help cmdmod} is used to generate 
the necessary if expression based on the estimation command to ensure that any 
user specified constraints are satisfied in the predictions as well.  

{pstd}
{cmd:predictit} will use the dataset {help char:characteristics} created by 
previous calls to {help cmdmod} to construct the necessary syntax

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt ps:tub} is used to define a new variable name/stub for the predicted values
from the validation/test set.  When K-Fold cross-validation is used, this 
option defines the name of the variable containing the predicted values from 
each of the folds and will be used as a variable stub to store the results from 
fitting the model to all of the training data. 


{dlgtab:Optional}

{phang}
{opt spl:it} must contain the name of the variable that stores the test, 
validation, and test splits.  There will only be a single variable if the splits 
were created using {help splitit}.  Additionally, if you are passing an 
estimation command string as the first argument to this command, you must 
pass the split variable name to this option.

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

{phang}
{opt mod:ifin} is the if expression to use for the predictions on the individual 
K-Folds.  As a reminder, an 80/20 train/test split, is a special case of K-Fold 
cross-validation with a single K-Fold.  This option can be used in lieu of 
passing the estimation command string.  If an estimation command string is also 
passed, the value passed to this parameter will be overwritten by the value 
generated by the internal call to {help cmdmod}.  If {help fitit} was called 
prior to this command, you can pass {cmd:`macval(e(predifin))'} to this 
parameter to provide the modified if expression for predictions.

{phang}
{opt kfi:fin} is the if expression used to generate predictions on the entire 
training set when using K-Fold cross-validation.  This is typically used at the 
conclusion of hyperparameter tuning to provide an assessment of the model fit 
when fitted to all of the K-Folds simultaneously, prior to evaluating the 
performance on a test set.  

{phang}
{opt no:all} is an option to prevent predicting the outcome for a model fitted 
to the entire training set when using K-Fold cross-validation.  If this option 
is used, {opt kfi:fin} will have no effect since the relevant predictions will 
not be generated.

{phang}
{opt pm:ethod} is passed internally to Stata's {help predict} command to 
generate the predicted values of the outcome for the out-of-sample data. The 
default value used by {cmd:predictit} depends on the value passed to the 
{opt c:lasses} option.  When option {opt c:lasses} is set to 0 the prediction 
method will default to {opt xb}; in all other instances, the prediction method 
will default to {opt pr}.


{marker examples}{...}
{title:Examples}

{p 4 4 2}Update these to reflect predictit{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata webuse lbw, clear}{p_end}
{p 4 4 2}Create a variable to identify the sample to fit the data to{p_end}
{p 8 4 2}{stata g byte touse = runiformint(1, 6)}{p_end}
{p 4 4 2}Fit a model to the data{p_end}
{p 8 4 2}{stata fitit "logit low age smoke", spl(touse) kf(5) res(lmod))}{p_end}
{p 4 4 2}Generate predictions for the five training folds{p_end}
{p 8 4 2}{stata predictit, ps(pred) c(2) k(5) mod(`macval(r(predifin))')}{p_end}
{p 4 4 2}Generate predicted values for the model fitted to the entire training set and the individual K-Folds{p_end}
{p 8 4 2}{stata predictit, ps(pred) c(2) k(5) mod(`macval(r(predifin))') kfi(`macval(r(kfpredifin))')}{p_end}
{p 4 4 2}Alternative syntax for the previous two examples{p_end}
{p 8 4 2}{stata predictit "logit low age smoke", ps(pred) c(2) spl(touse) kf(5) noall}{p_end}
{p 8 4 2}{stata predictit "logit low age smoke", ps(pred) c(2) spl(touse) kf(5)}{p_end}


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
