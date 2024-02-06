{smcl}
{* *! version 0.0.1 05feb2024}{...}
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

{marker description}{...}
{title:Description}

{p 4 4 2}{cmd:fitit} is part of the {help crossvalidate} suite of tools to implement crossvalidation methods with Stata estimation commands. {cmd:fitit} is used to fit the user specified model to the appropriate subset of the data in memory and to generate the predicted values following model fitting.  {cmd:fitit} depends on {help cmdmod} and {help classify}, which are also included with {help crossvalidate}.
{p_end}

{p 4 4 2}{cmd:fitit} takes the entire estimation command (options and all) as the first argument.  Internally, {help cmdmod} is used to append the appropriate condition to any existing if/in expressions to ensure that the model is fitted to the appropriate training set while still respecting any inclusion constraints specified by the end user.  

{marker options}{...}
{title:Options}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt ps:tubs}}is used to specify the variable name where the predicted class memberships will be saved.{p_end}
{synopt :{opt spl:it}}is used to specify the name of the variable that identifies the training split(s).{p_end}
{synopt :{opt res:ults}}a stub used to store estimation results.{p_end}
{synopt :{opt c:lasses}}is used to specify the number of classes for classification models. {it:Default: 0}.{p_end}
{synopt :{opt k:fold}}specifies the number of folds in the training set.  A value > 1 indicates the use of K-Fold cross-validation.  {it:Default: 1}.{p_end}
{synopt :{opt thr:eshold}}is used for binary classification models only to set the predicted probability threshold used to fitit an affirmative case (i.e., 1).{p_end}
{synoptline}

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

{p 4 4 8}{cmd:fitit} also reposts the e-return values from the model fitted to the entire training set.{p_end}

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
