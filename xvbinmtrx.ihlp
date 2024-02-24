{phang}
{opt sens} is used to calculate the sensitivity of a predicted outcome variable relative to an observed outcome variable. Sensitivity can be understood as the ratio of all true posivie values in the predicted variable relative to all positive values in the observed variable. For simplicity, the largest factor level of a binary variable is considred to be the positive outcome.  That is, for a binary variable that takes the values of 0 and 1, sensitivity is calcuated using the predicted and observed values of 1.  For more details see the {browse "https://yardstick.tidymodels.org/reference/sens.html":yardstick} reference page. 


{phang}
{opt prec} is used to calculate the precision of a predicted outcome variable relative to an observed outcome variable.  Sensitivity can be understood as the ratio of all true posivie values in the predicted variable relative to all positive values in the predicted variable. For simplicity, the largest factor level of a binary variable is considred to be the positive outcome.  That is, for a binary variable that takes the values of 0 and 1, precision is calcuated using the predicted and observed values of 1.  For more details see the {browse "https://yardstick.tidymodels.org/reference/precision.html":yardstick} reference page. 



{phang}
{opt recall} is used to calculate the recall of a predicted outcome variable relative to an observed outcome variable.  Recall is a synonym for sensitivity and is calculated by calling identically.  For more details see the {browse "https://yardstick.tidymodels.org/reference/recall.html":yardstick} reference page. 


{phang}
{opt spec} is used to calculate the specificity of a predicted outcome variable relative to an observed outcome variable.  Specificity can be understood as the ratio of all true negative values in the predicted variable relative to all negative values in the observed variable. For simplicity, the smallest factor level of a binary variable is considered to be the negative outcome.  That is, for a binary variable that takes the values of 0 and 1,  specificity is calcuated using the predicted and observed values of 0.  For more details see the {browse "https://yardstick.tidymodels.org/reference/spec.html":yardstick} reference page. 


{phang}
{opt prev} is used to calculate the prevalence of an event in an observed outcome variable relative to all outcomes.  Prevalence is defined as the share of all positive outcomes in the observed variable relative the total number of observations.  For simplicity, the largest factor level of a binary variable is considered to be the positive outcome.  That is, for a binary variable that takes the values of 0 and 1,  prevalence is calcuated using the observed values of 1.  For more details see the {browse "https://yardstick.tidymodels.org/reference/spec.html":yardstick} reference page. 



{phang}
{opt ppv} is used to calcuate the positive predicted value (PPV) of a predicted outcome variable relative to an observed outcome variable. PPV can be understood as the share of predicted positives that are actually positive.  For simplicity, the largest factor level of a binary variable is considered to be the positive outcome.  That is, for a binary variable that takes the values of 0 and 1, prevalence is calcuated using the observed values of 1.  For more details see the {browse "https://yardstick.tidymodels.org/reference/ppv.html":yardstick} reference page.


{phang}
{opt npv} is used to calcuate the negative predicted value (NPV) of a predicted outcome variable relative to an observed outcome variable. NPV can be understood as the share of predicted negatives that are actually negative.  For simplicity, the smallest factor level of a binary variable is considered to be the negative outcome.  That is, for a binary variable that takes the values of 0 and 1,  specificity is calcuated using the predicted and observed values of 0.  For more details see the {browse "https://yardstick.tidymodels.org/reference/npv.html":yardstick} reference page.


{phang}
{opt acc} is used to calculate the accuracy of a predicted outcome variable relative to an observed outcome variable.  Accuracy can be understood as the share of the data predicted correctly and is the ratio of true positives plus true negatives relative to all predicted outcomes. For more details see the {browse "https://yardstick.tidymodels.org/reference/accuracy.html":yardstick} reference page.


{phang}
{opt bacc} is used to calcuate the balanced accuracy of a predicted outcome variable relative to an observed outcome variable. Balanced accuracy can be understood as the unweighted mean of sensitivity and specificity.  For more details see the {browse "https://yardstick.tidymodels.org/reference/bal_accuracy.html":yardstick} reference page.


{phang}
{opt mcc} is used to calculate Matthews correlation coefficient (MCC).  The MCC is a correlation coefficient between the observed and predicted binary variables that range from [−1, 1].  For more details see the {browse "https://yardstick.tidymodels.org/reference/mcc.html":yardstick} reference page.


{phang}
{opt f1} is used to calculate the F1 score. The F1 score is an alternate measure of a model's accuracy.  F1 score is calculated as the harmonic mean of the model precision and recall metrics.  For more details see the {browse "https://yardstick.tidymodels.org/reference/f_meas.html":yardstick} reference page.

{phang}
{opt jindex} is used to calculate Youden's J statistic (J-index). J statistic is defined as 
the sum of the model's Sensitivity and Specificity minus one and ranges from [0, 1].  For more details see the {browse "https://yardstick.tidymodels.org/reference/j_index.html":yardstick} reference page. 


{phang}
{opt binr2} is used to calculate the noniterative Edwards and Edwards estimtor of the binary R^2 (tetrachoric correlation).  For more details see the {help tetrachoric} help page. 



