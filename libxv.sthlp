{smcl}
{* *! version 0.0.1 17feb2024}{...}
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
{viewerjumpto "References" "libxv##references"}{...}


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
This should provide a bit of description for each of the utility functions 
what they are, what they do, the use case, etc...


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

{* * for each function there is a section below where we can define the math/implementation of that metric and provide in-text citations for reference (we can just use the yardstick package in R as short hand and then provide the link to that repository as the reference to make it a bit easier/more manageable)}
{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
{synopt :{opt sens}}Sensitivity{p_end}
{synopt :{opt prec}}Precision{p_end}
{synopt :{opt recall}}Recall{p_end}
{synopt :{opt spec}}Specificity{p_end}
{synopt :{opt prev}}Prevalence{p_end}
{synopt :{opt ppv}}Positive Predictive Value{p_end}
{synopt :{opt npv}}Negative Predictive Value{p_end}
{synopt :{opt acc}}Accuracy{p_end}
{synopt :{opt bacc}}Balanced Accuracy{p_end}
{synopt :{opt mcc}}Matthews Correlation Coefficient{p_end}
{synopt :{opt f1}}F1 Statistic{p_end}
{synopt :{opt jindex}}Youden's J Statistic{p_end}
{synopt :{opt binr2}}Tetrachoric Correlation Coefficient{p_end}
{synoptline}

{phang}
{opt sens}


{phang}
{opt prec}


{phang}
{opt recall}


{phang}
{opt spec}


{phang}
{opt prev}


{phang}
{opt ppv}


{phang}
{opt npv}


{phang}
{opt acc}


{phang}
{opt bacc}


{phang}
{opt mcc}


{phang}
{opt f1}


{phang}
{opt jindex}


{phang}
{opt binr2}


{marker multiclass}{...}
{title:Multiclass Metrics}


{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
{synopt :{opt mcsens}}Multiclass Sensitivity{p_end}
{synopt :{opt mcprec}}Multiclass Precision{p_end}
{synopt :{opt mcrecall}}Multiclass Recall{p_end}
{synopt :{opt mcspec}}Multiclass Specificity{p_end}
{synopt :{opt mcprev}}Multiclass Prevalence{p_end}
{synopt :{opt mcppv}}Multiclass Positive Predictive Value{p_end}
{synopt :{opt mcnpv}}Multiclass Negative Predictive Value{p_end}
{synopt :{opt mcacc}}Multiclass Accuracy{p_end}
{synopt :{opt mcbacc}}Multiclass Balanced Accuracy{p_end}
{synopt :{opt mcmcc}}Multiclass Matthews Correlation Coefficient{p_end}
{synopt :{opt mcf1}}Multiclass F1 Statistic{p_end}
{synopt :{opt mcjindex}}Multiclass Youden's J Statistic{p_end}
{synopt :{opt mcordr2}}Polychoric Correlation Coefficient {opt ***}{p_end}
{synopt :{opt mcdetect}}Multiclass Detection Prevalence{p_end}
{synopt :{opt mckappa}}Multiclass Kappa{p_end}
{synoptline}

{phang}
{opt mcsens}


{phang}
{opt mcprec}


{phang}
{opt mcrecall}


{phang}
{opt mcspec}


{phang}
{opt mcprev}


{phang}
{opt mcppv}


{phang}
{opt mcnpv}


{phang}
{opt mcacc}


{phang}
{opt mcbacc}


{phang}
{opt mcmcc}


{phang}
{opt mcf1}


{phang}
{opt mcjindex}


{phang}
{opt mcordr2}


{phang}
{opt mcdetect}


{phang}
{opt mckappa}



{marker regression}{...}
{title:Regression Metrics}


{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr:Name}
{synoptline}
{synopt :{opt mse}}Mean Squared Error{p_end}
{synopt :{opt rmse}}Root Mean Squared Error{p_end}
{synopt :{opt mae}}Mean Absolute Error{p_end}
{synopt :{opt bias}}Total (Bias) Error{p_end}
{synopt :{opt mbe}}Mean (Bias) Error{p_end}
{synopt :{opt r2}}Pearson Correlation Coefficient{p_end}
{synopt :{opt mape}}Mean Absolute Percentage Error{p_end}
{synopt :{opt smape}}Symmetric Mean Absolute Percentage Error{p_end}
{synopt :{opt msle}}Mean Squared Log Error{p_end}
{synopt :{opt rmsle}}Root Mean Squared Log Error{p_end}
{synopt :{opt rpd}}Ratio of Performance to Deviation{p_end}
{synopt :{opt iic}}Index of Ideality of Correlation{p_end}
{synopt :{opt ccc}}Concordance Correlation Coefficient{p_end}
{synopt :{opt huber}}Huber Loss{p_end}
{synopt :{opt phl}}Pseudo-Huber Loss{p_end}
{synopt :{opt pll}}Poisson Log Loss{p_end}
{synoptline}


{phang}
{opt mse}


{phang}
{opt rmse}


{phang}
{opt mae}


{phang}
{opt bias}


{phang}
{opt mbe}


{phang}
{opt r2}


{phang}
{opt mape}


{phang}
{opt smape}


{phang}
{opt msle}


{phang}
{opt rmsle}


{phang}
{opt rpd}


{phang}
{opt iic}


{phang}
{opt ccc}


{phang}
{opt huber}


{phang}
{opt phl}


{phang}
{opt pll}


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
{p 4 4 6}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}wbuchanan at sagcorp [dot] com{p_end}

{p 4 4 8}Steven Brownell{p_end}
{p 4 4 8}, SAG Corporation{p_end}
{p 4 4 6}{browse "https://www.sagcorp.com":SAG Corporation}{p_end}
{p 4 4 8}sbrownell at sagcorp [dot] com{p_end}


{marker references}{...}
{title:References}

{* * this is just a quick generic was to show APA format for a journal article}

{phang}
Last Name, FI. [MI.] [, [Next Author same structure]] [&] [Author Same structure]
(year).  [Article name: Subtitle]. {it:Journal Name, volume(issue), } pp. [pages]. 
[doi: #]
