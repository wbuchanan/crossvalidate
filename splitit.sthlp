{smcl}
{* *! version 0.0.2 08feb2024}{...}
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

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt u:id}}a variable list for clustered sampling/splitting{p_end}
{synopt :{opt tp:oint}}a numeric, td(), tc(), or tC() value{p_end}
{synopt :{opt k:fold}}the number of K-Folds to create in the training set; default is {cmd:kfold(1)}{p_end}
{synopt :{opt ret:ain}}a new variable name; default is {cmd:retain(_xvsplit)}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:splitit} is part of the {help crossvalidate} suite of tools to implement 
cross-validation methods with Stata estimation commands. {cmd:splitit} is used 
to create the train/test or train/validation/test splits in the dataset. It also 
supports K-Fold splitting of the training set.  Depending on the options 
specified by the user, {cmd:splitit} will split randomly across all observations
, using panel variables or time variables with panel data, using clusters, or 
a combination of clustered and panel sampling strategies. In all cases, the 
sampling is based on pseudo-random number generators implemented in Stata.


{marker options}{...}
{title:Options}

{phang}
{opt u:id} accepts a variable list for clustered sampling/splitting.  When an 
argument is passed to this parameter entire clusters will be split into the 
respective training and validation and/or training sets.  When this option is 
used with {opt tp:oint} for {help xtset} data, the panel variable must be nested 
within the clusters defined by {opt u:id}.


{phang}
{opt tpoint} a time point delimiting the training split from it's corresponding 
forecastting split.  This can also be accomplished by passing the appropriate if 
expression in your estimation command.  Use of this option will result in an 
additional variable with the suffix {it:xv4} being created to identify the 
forecasting set associated with each split/K-Fold.  This is to ensure that 
the forecasting period data will not affect the model training.

{phang}
{opt k:fold} is used to specify the number of K-Folds to create in the training 
set. 

{phang}
{opt ret:ain} is used to specify the name of a new variable that will store the 
identifiers for the splits in the data.


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