{smcl}
{* *! version 0.0.1 05feb2024}{...}
{viewerjumpto "Syntax" "validateit##syntax"}{...}
{viewerjumpto "Description" "validateit##description"}{...}
{viewerjumpto "Options" "validateit##options"}{...}
{viewerjumpto "Custom Metrics and Monitors" "validateit##custom"}{...}
{viewerjumpto "Examples" "validateit##examples"}{...}
{viewerjumpto "Returned Values" "validateit##retvals"}{...}
{viewerjumpto "Additional Information" "validateit##additional"}{...}
{viewerjumpto "Contact" "validateit##contact"}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 32 2}
{cmd:validateit} {ifin} {cmd:,} {cmdab:me:tric(}{it:string asis}{cmd:)} 
{cmdab:p:red(}{it:varname}{cmd:)} [ ]
{cmdab:o:bs(}{it:varname}{cmd:)} {cmdab:mo:nitors(}{it:string asis}{cmd:)} 
{cmdab:dis:play}]{p_end}

{marker description}{...}
{title:Description}

{p 4 4 2} {cmd:validateit} is part of the {help crossvalidate} suite of tools to implement crossvalidation methods with Stata estimation commands. {cmd:validateit} is used to compute the validation metric and monitors.  For additional information about the measurement functions available in {help crossvalidate} please see help {help libxv}. {p_end}

{marker options}{...}
{title:Options}

{synoptset 15 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{opt me:tric}}the name of a single metric.{p_end}
{synopt :{opt p:red}}the name of the variable containing the predicted values{p_end}
{synopt :{opt o:bs}}the name of the variable containing the observed values. {it:Default: `e(depvar)'}{p_end}
{synopt :{opt mo:nitors}}the name of one or more mata functions used to provide additional information about performance on the out-of-sample set.{p_end}
{synopt :{opt dis:play}}an option to display the metric and monitor values in the results window.{p_end}
{synoptline}

{marker custom}{...}
{title:Custom Metrics and Monitors}

{p 4 4 2}Users may define their own validation metrics to be used by {cmd:validateit}.  
All metrics and monitors are required to use the same function signature:{p_end}

{p 12 12 2}{cmd:{it:real scalar metricName(string scalar pred, string scalar obs, string scalar touse)}}{p_end}

{p 4 4 2}The first argument passed to your function will be the name of the variable containing the predicted values.  The second argument passed to your function will be the name of the variable containing the observed outcomes.  The last argument in the signature is a variable that identifies the validation/test set, or the K-Fold with the out-of-sample predicted values, to compute the validation metric on.{p_end}

{p 4 4 2}In your function, you can easily define the vectors that will store the data you need for your computations:{p_end}

{p 12 12 2}{cmd:{it:real colvector y, yhat}}{p_end}
{p 12 12 2}{cmd:{it:y = st_data(., obs, touse)}}{p_end}
{p 12 12 2}{cmd:{it:yhat = st_data(., pred, touse)}}{p_end}

{p 4 4 2}With your custom metric function defined in Mata with the signature above, you can use it as a metric or monitor with {cmd:validateit} by passing the function name to the metric or monitors options.  {it:Note, you will need to make sure that the function is defined in Mata prior to using it or ensure that it is defined in a library that Mata will search automatically}.{p_end}

{marker examples}{...}
{title:Examples}


{p 4 4 2}Without Monitors{p_end}
{p 8 4 2}validateit, me(mse) p(pred){p_end}

{p 4 4 2}With Monitors{p_end}
{p 8 4 2}validateit, me(accuracy) p(pred) mo(npv ppv baccuracy f1 sensitivity specificity){p_end}


{marker retvals}{...}
{title:Returned Values}
{p 4 4 8}The following lists the names of the r-scalars and their contents.{p_end}

{synoptset 25 tabbed}{...}
{synoptline}
{synopthdr}
{synoptline}
{synopt :{cmd:r(metric)}}contains the metric value{p_end}
{synopt :{cmd:r(`monitors')}}one scalar for each monitor passed to the monitors option, named by the monitor function{p_end}
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
