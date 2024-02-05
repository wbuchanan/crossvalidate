{smcl}
{* *! version 0.0.1 05feb2024}{...}
{vieweralsosee "[R] predict" "mansection R predict"}{...}
{viewerjumpto "Syntax" "classify##syntax"}{...}
{viewerjumpto "Description" "classify##description"}{...}
{viewerjumpto "Options" "classify##options"}{...}
{viewerjumpto "Examples" "classify##examples"}{...}
{viewerjumpto "Additional Information" "classify##additional"}{...}
{viewerjumpto "Contact" "classify##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:classify} # [ if ] {cmd:,} {cmdab:ps:tub(}{it:string asis}{cmd:)} [
{cmdab:thr:eshold(}{it:real}{cmd:)} ]{p_end}

{p 4 4 2} {cmd:classify} requires users to specify the number of classes that are being predicted by the model as the first argument.{p_end}

{marker description}{...}
{title:Description}

{p 4 4 2} {cmd:classify} is part of the {help crossvalidate} suite of tools to implement crossvalidation methods with Stata estimation commands. {cmd:classify} is used internally by the {help fitit} command to handle conversion of predicted probabilities into integer valued class memberships.  {cmd:classify} will work with binomial and multinomial (including ordinal) classification models.  For multinomial models, the classmembership with the highest predicted probability is selected as the class predicted by the model.{p_end}

{marker options}{...}
{title:Options}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt ps:tubs}}is used to specify the variable name where the predicted class memberships will be saved.{p_end}
{synopt :{opt thr:eshold}}is used for binary classification models only to set the predicted probability threshold used to classify an affirmative case (i.e., 1).{p_end}
{synoptline}

{marker examples}{...}
{title:Examples}

{p 4 4 2}Binary Classification Example{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata webuse lbw, clear}{p_end}
{p 4 4 2}Fit a model to the data{p_end}
{p 8 4 2}{stata logit low age smoke) c}{p_end}
{p 4 4 2}Use classify to generate the predicted classes{p_end}
{p 8 8 2}{stata classify 2 if e(sample), ps(pred)}{p_end}

{p 4 4 2}Multinomial Classification Example{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata webuse sysdsn1, clear}{p_end}
{p 4 4 2}Fit a model to the data{p_end}
{p 8 4 2}{stata mlogit insure age male i.site) c}{p_end}
{p 4 4 2}Use classify to generate the predicted classes{p_end}
{p 8 8 2}{stata classify 3 if e(sample), ps(pred)}{p_end}

{p 4 4 2}Ordinal Classification Example{p_end}

{p 4 4 2}Load example data{p_end}
{p 8 4 2}{stata webuse fullauto, clear}{p_end}
{p 4 4 2}Fit a model to the data{p_end}
{p 8 4 2}{stata ologit rep77 price foreign) c}{p_end}
{p 4 4 2}Use classify to generate the predicted classes{p_end}
{p 8 8 2}{stata classify 5 if e(sample), ps(pred)}{p_end}


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
