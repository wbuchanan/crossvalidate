{smcl}
{* *! version 0.0.2 08feb2024}{...}
{viewerjumpto "Syntax" "cmdmod##syntax"}{...}
{viewerjumpto "Description" "cmdmod##description"}{...}
{viewerjumpto "Options" "cmdmod##options"}{...}
{viewerjumpto "Examples" "cmdmod##examples"}{...}
{viewerjumpto "Returned Values" "cmdmod##retvals"}{...}
{viewerjumpto "Additional Information" "cmdmod##additional"}{...}
{viewerjumpto "Contact" "cmdmod##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:cmdmod} {it:"estimation command"} {cmd:,} {cmdab:spl:it(}{it:varname}{cmd:)} [
{cmdab:k:fold(}{it:integer}{cmd:)} ]{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt spl:it}}name of the variable that identifies the training split(s){p_end}
{syntab:Optional}
{synopt :{opt k:fold}}specifies the number of folds in the training set; default is {cmd:kfold(1)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd} 
{cmd:cmdmod} is part of the {help crossvalidate} suite of tools to implement 
cross-validation methods with Stata estimation commands. {cmd:cmdmod} is used 
internally by the {help fitit} and {help predictit} commands for metaprogramming 
tasks.  Specifically, {cmd:cmdmod} is used to modify the user supplied 
estimation command to include the necessary if expression to fit the data to 
the appropriate training set or K-Fold.  It is also used to ensure that 
predictions are made on the appropriate out-of-sample portion of the data set.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt spl:it} must contain the name of the variable that stores the test, 
validation, and test splits.  There will only be a single variable if the splits 
were created using {help splitit}.  

{dlgtab:Optional}

{phang}
{opt k:fold} defines the number of K-Folds used for the training set.  In other 
places, we reference using K-Fold cross-validation in the more common form, 
where the training set consists of multiple subsets of data.  However, standard 
train/test and train/validation/test splits are simply a special case of K-Fold 
cross-validation where there is only a single fold.  


{marker examples}{...}
{title:Examples}

{p 4 4 2}Binary Classification Example{p_end}

{p 4 4 2}Non-K-Fold Example{p_end}
{p 8 4 2}{stata cmdmod "ivreg price (mpg i.foreign)", spl(spvar)}{p_end}
{p 4 4 2}K-Fold Example{p_end}
{p 8 4 2}{stata cmdmod "ivreg price (mpg i.foreign)", spl(spvar) kf(5)}{p_end}


{marker retvals}{...}
{title:Returned Values}
{p 4 4 8}The following lists the names of the r-macros and their contents.{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{cmd:r(modcmd)}}the modified command for test/train or test/validate/train splits{p_end}
{synopt :{cmd:r(predifin)}}the if expression to use when predicting on validation/test split.{p_end}
{synopt :{cmd:r(kfmodcmd)}}the modified command for K-Fold splits{p_end}
{synopt :{cmd:r(kfpredifin)}}the if expression to use when predicting on the K-Fold hold out set.{p_end}
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
