{phang}
{opt sens} is used to calculate the sensitivity of a predicted outcome variable 
relative to an observed outcome variable. Sensitivity is the 
ratio of all true posivie values in the predicted variable relative to all 
positive values in the observed variable. For more details see 
{browse "https://yardstick.tidymodels.org/reference/sens.html":Sensitivity}. 

{phang}
{opt prec} is used to calculate the precision of a predicted outcome variable 
relative to an observed outcome variable.  Precision is the 
ratio of all true posivie values in the predicted variable relative to all 
positive values in the predicted variable. For more details see 
{browse "https://yardstick.tidymodels.org/reference/precision.html":Precision}. 

{phang}
{opt recall} is used to calculate the recall of a predicted outcome variable 
relative to an observed outcome variable.  Recall is a synonym for sensitivity 
and is calculated by calling identically.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/recall.html":Recall}. 

{phang}
{opt spec} is used to calculate the specificity of a predicted outcome variable 
relative to an observed outcome variable.  Specificity is the 
ratio of all true negative values in the predicted variable relative to all 
negative values in the observed variable. For more details see  
{browse "https://yardstick.tidymodels.org/reference/spec.html":Specificity}. 

{phang}
{opt prev} is used to calculate the prevalence of an event in an observed 
outcome variable relative to all outcomes.  Prevalence is proportion of positive 
cases in the data.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/spec.html":Prevalence}. 

{phang}
{opt ppv} is used to calcuate the positive predicted value (PPV) of a predicted 
outcome variable relative to an observed outcome variable. PPV is the share of 
predicted positives that are actually positive.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/ppv.html":PPV}.

{phang}
{opt npv} is used to calcuate the negative predicted value (NPV) of a predicted 
outcome variable relative to an observed outcome variable. NPV is the share of 
predicted negatives that are actually negative.  In the binary context, negative 
is not positive (i.e., a value of 0 for a variable coded as 0 or 1).  
For more details see 
{browse "https://yardstick.tidymodels.org/reference/npv.html":NPV}.

{phang}
{opt acc} is used to calculate the accuracy of a predicted outcome variable 
relative to an observed outcome variable.  Accuracy is the proportion of all 
cases predicted correctly.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/accuracy.html":Accuracy}.

{phang}
{opt bacc} is used to calcuate the balanced accuracy of a predicted outcome 
variable relative to an observed outcome variable. Balanced accuracy is the 
unweighted mean of sensitivity and specificity.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/bal_accuracy.html":Balanced Accuracy}.

{phang}
{opt mcc} is used to calculate Matthews correlation coefficient (MCC).  The MCC 
is a correlation coefficient between the observed and predicted binary variables 
that range from [−1, 1].  For more details see 
{browse "https://yardstick.tidymodels.org/reference/mcc.html":MCC}.

{phang}
{opt f1} is used to calculate the F1 score. The F1 score is an alternate measure 
of a model's accuracy.  F1 score is calculated as the harmonic mean of the model 
precision and recall metrics.  For more details see 
{browse "https://yardstick.tidymodels.org/reference/f_meas.html":F1}.

{phang}
{opt jindex} is used to calculate Youden's J statistic (J-index). The J 
statistic is defined as the sum of the model's Sensitivity and Specificity minus 
one and ranges from [0, 1].  For more details see the 
{browse "https://yardstick.tidymodels.org/reference/j_index.html":Youden's J}. 

{phang}
{opt binr2} is used to calculate the noniterative Edwards estimtor of the 
tetrachoric correlation coefficient (i.e., binary R^2).  For more details see 
{help tetrachoric}. 
