{smcl}
{* *! version 0.0.1 05feb2024}{...}
{viewerjumpto "Syntax" "splitit##syntax"}{...}
{viewerjumpto "Description" "splitit##description"}{...}
{viewerjumpto "Options" "splitit##options"}{...}
{viewerjumpto "Examples" "splitit##examples"}{...}
{viewerjumpto "Returned Values" "splitit##retvals"}{...}
{viewerjumpto "Additional Information" "splitit##additional"}{...}
{viewerjumpto "Contact" "splitit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:splitit} # [#] {ifin} [{cmd:,} {cmdab:u:id(}{it:varlist}{cmd:)} 
{cmdab:tp:oint(}{it:string asis}{cmd:)} {cmdab:k:fold(}{it:integer}{cmd:)} 
{cmdab:ret:ain(}{it:string asis}{cmd:)}]{p_end}

{marker description}{...}
{title:Description}

{p 4 4 2} {cmd:splitit} is part of the {help crossvalidate} suite of tools to implement crossvalidation methods with Stata estimation commands. {cmd:splitit} is used to create the train/test or train/validation/test splits in the dataset. It also 
supports K-Fold splitting of the training set.  {p_end}

{marker options}{...}
{title:Options}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt u:id}}accepts a variable list for clustered sampling/splitting.  When used with {opt tpoint} for {help xtset} data, the panel variable is required to be nested within UID.{p_end}
{synopt :{opt tp:oint}}a time point delimiting the training split from it's corresponding forecastting split.  {it:Note: you can specify time points as numeric values or using td(), tc(), or tC()}.{p_end}
{synopt :{opt k:fold}}is used to specify the number of K-Folds to create in the training set. {it:Default 1}.{p_end}
{synopt :{opt ret:ain}}is used to specify the name of a new variable that will contain the group identifiers for the splits in the data.{p_end}
{synoptline}


{p 4 4 2} {opt tpoint} should be used when forecasts following model fitting are what you intend to validate or test.  Using this option will result in an additional variable that will have the suffix {it:xv4} and will indicate the portion of the corresponding split that is after the timepoint specified to ensure that the model is not trained on the out of sample forecast sample.{p_end}

{marker examples}{...}
{title:Examples}

{p 4 4 2}Load example dataset{p_end}
{p 8 4 2}{stata sysuse auto, clear}{p_end}

{p 4 4 2}Simple Random Sampling{p_end}
{p 6 4 2}Test/Train Split{p_end}
{p 8 4 2}{stata splitit .8, ret(splitvar)}{p_end}
{p 6 4 2}Train/Validation/Test Split{p_end}
{p 8 4 2}{stata splitit .6 .2, ret(splitvar)}{p_end}

{p 4 4 2}K-Fold Simple Random Sampling{p_end}
{p 6 4 2}Test/Train Split{p_end}
{p 8 4 2}{stata splitit .8, ret(splitvar) k(5)}{p_end}
{p 6 4 2}Train/Validation/Test Split{p_end}
{p 8 4 2}{stata splitit .6 .2, ret(splitvar) k(5)}{p_end}

{p 4 4 2}Clustered Random Sampling{p_end}
{p 6 4 2}Test/Train Split{p_end}
{p 8 4 2}{stata splitit .8, ret(splitvar) uid(foreign)}{p_end}
{p 6 4 2}Train/Validation/Test Split{p_end}
{p 8 4 2}{stata splitit .6 .2, ret(splitvar) uid(foreign)}{p_end}

{p 4 4 2}K-Fold Clustered Random Sampling{p_end}
{p 6 4 2}Test/Train Split{p_end}
{p 8 4 2}{stata splitit .8, ret(splitvar) k(5) uid(foreign)}{p_end}
{p 6 4 2}Train/Validation/Test Split{p_end}
{p 8 4 2}{stata splitit .6 .2, ret(splitvar) k(5) uid(foreign)}{p_end}


{marker retvals}{...}
{title:Returned Values}
{p 4 4 8}The following lists the names of the r-macros and their contents.{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{cmd:r(stype)}}the split method{p_end}
{synopt :{cmd:r(flavor)}}the sampling method{p_end}
{synopt :{cmd:r(splitter)}}the variable containing the sample split identifiers{p_end}
{synopt :{cmd:r(forecastset)}}the variable containing the sample split identifiers for the forecast sample{p_end}
{synopt :{cmd:r(training)}}the value(s) of the splitter variable that identify the training set(s){p_end}
{synopt :{cmd:r(validation)}}the value of the splitter variable that identifies the validation set{p_end}
{synopt :{cmd:r(testing)}}the value of the splitter variable that identifies the test set{p_end}
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
