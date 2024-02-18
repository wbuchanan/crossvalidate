
/*
Purpose: Use Logit example from logit help file to test functions

Notes: 
	[x] confusion() - return a confusion matrix from the predicted/observed value variables
	[x] sensitivity() - sensitivity, specificicty, prevalence, ppv, and npv
	[x] precision() - computes precision from a confusion matrix
	[x] recall() - compute recall, a synonym for sensitivity
	[x] specificity() - computes specificity from a confusion matrix
	[x] prevalence() - computes prevalence
	[x] ppv() - computes positive predictive value
	[x] npv() - computes negative predictive value
	[x] accuracy() - computes accuracy
	[x] bal_accuracy() - computes "balanced" accuracy
	[x] f1() - computes the F1 statistic
	[x] mse() - computes the mean squared error
	[x] mae() - mean absolute error from pred. and observed outcomes
	[x] bias() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[x] mbe() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[?] r2() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[x] rmse() - computes root mse 				<- IF MSE WORKS THIS ONE SHOULD TOO
	[?] mape() - mean absolute percentage error
	[?] smape()- symmetric mean absolute percentage error 
	[?] msle() - mean squared log error
	[?] rmsle() - root mean squared log error
*/

//change dir to location of the ado files
// changes the directory to C:\Users\StevenBrownell\crossvalidate
cd "~/crossvalidate"  

//Clear data
clear all

//Load mata functions
do crossvalidate.mata
 
//Load data
webuse lbw, clear

//create touse variable
gen touse = 1

//Run unrestricted logistic regression to calculate our clssification metrics
logit low age lwt i.race smoke ptl ht ui

//manually calulate predicted values
predict double pred, pr

// round predicted values - "By default, estat classification uses a cutoff of 0.5"
// NOTE: Should we think about allowing users to adjust the cutoff value?
// This is handled by the threshold parameter in classify, which also defaults 
// to a value of 0.5.
replace pred = round(pred, 1)


// NOTE: Since we rewrote the confusion() function to use stata's tabulate, 
// we are overwriting all of the rclass stored results each time we calculate 
// the confusion matrix
// I had created a separate script for these tests and will add an example for 
// how to mitigate/handle that in that script.
	//Test confusion matrix
//Caluclate the confusion matrix using our 
mata: st_matrix("Conf", confusion("pred", "low", "touse"))    

//"reshape" the confusion matrix so that it matches the estat class matrix
mat Intmed=Conf[2,2],Conf[2,1] \ Conf[1,2], Conf[1,1]

//calculates confusion matrix and several of the classification metrics 
qui: estat class

//assign confusion matrix to permanent value
mat estConf = r(ctable)[1..2,1..2]

//calulate difference between two matrices
matrix DiffMat=Intmed-estConf

//assert that the determinant of the difference matrix is 0
assert det(DiffMat)==0

//drop intermediate matrices
mat drop Intmed DiffMat



	//Test Sensitivity
//Calculate Sensitivity using our function
mata: st_local("sens", strofreal(sensitivity("pred", "low", "touse")))

//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(100*`sens',0.000001)==round(r(P_p1),0.000001)



	//Test Precision
//Calculate Precision using our function
mata: st_local("prec", strofreal(precision("pred", "low", "touse")))
di `prec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`prec',0.00001)==round(100*r(ctable)[1,1]/r(ctable)[1,3],0.00001)



	//Test Recall (aka Sensitivity)
//Calculate Recall using our function
mata: st_local("rec", strofreal(recall("pred", "low", "touse")))
di `rec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(100*`rec',0.000001)==round(r(P_p1),0.000001)



	//Test Specificity
//Calculate Specificity using our function
mata: st_local("spec", strofreal(specificity("pred", "low", "touse")))
di `spec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`spec',0.00001)==round(r(P_n0),0.00001)



	//Test Prevalence
//Calculate Prevalence using our function
mata: st_local("prev", strofreal(prevalence("pred", "low", "touse")))
di `prev'
//rerun estat class fn
qui: estat class

//view returned values
ret li all

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`prev',0.00001)==round(100*r(ctable)[3,1]/r(ctable)[3,3],0.00001)



	//Test ppv
//Calculate ppv using our function
mata: st_local("ppv", strofreal(ppv("pred", "low", "touse")))
di `ppv'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`ppv',0.00001)==round(r(P_1p),0.00001)



	//Test npv
//Calculate ppv using our function
mata: st_local("npv", strofreal(npv("pred", "low", "touse")))
di `npv'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`npv',0.00001)==round(r(P_0n),0.00001)



	//Test Accuracy
//Calculate Accuracy using our function
mata: st_local("acc", strofreal(accuracy("pred", "low", "touse")))
di `acc'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`acc',0.00001)==round(r(P_corr),0.00001)


	//Test Balanced Accuracy
//Calculate Balanced Accuracy using our function
mata: st_local("balacc", strofreal(bal_accuracy("pred", "low", "touse")))
di `balacc'
//rerun estat class fn
qui: estat class

//view returned values
ret li all

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`balacc',0.00001)==round((r(P_p1)+r(P_n0))/2,0.00001)


	//Test f1
//Calculate f1 using our function
mata: st_local("f1", strofreal(f1("pred", "low", "touse")))
di `f1'
//rerun estat class fn
qui: estat class

//manually calculate precision and save to local macro
local prec=100*r(ctable)[1,1]/r(ctable)[1,3]

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`f1',0.00001)==round((2 * `prec' * r(P_p1)) / (`prec' + r(P_p1)),0.00001)



	//Test mse
//Calculate mse using our function
mata: st_local("mse", strofreal(mse("pred", "low", "touse")))
di `mse'

//calcuate square error
g double sqerr=(low-pred)^2

//calculate mean of square error
mean sqerr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mse',0.000001)==round(r(table)[1,1],0.000001)



	//Test mae
//Calculate mse using our function
mata: st_local("mae", strofreal(mae("pred", "low", "touse")))
di `mae'

//calcuate abs error
g double abserr=abs(low-pred)

//calculate mean of square error
mean abserr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mae',0.000001)==round(r(table)[1,1],0.000001)



	//Test bias
//Calculate bias using our function
mata: st_local("bias", strofreal(bias("pred", "low", "touse")))
di `bias'

//calcuate square error
g double bias=(low-pred)

//calculate mean of square error
sum bias

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`bias',0.000001)==round(r(sum),0.000001)



	//Test mbe
//Calculate bias using our function
mata: st_local("mbe", strofreal(mbe("pred", "low", "touse")))
di `mbe'

//calculate mean of bias
sum bias

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mbe',0.000001)==round(r(mean),0.000001)



	//Test R^2
//Calculate bias using our function
mata: st_local("r2", strofreal(r2("pred", "low", "touse")))
di `r2'

//run logit fn to access stored R2 
qui: logit low age lwt i.race smoke ptl ht ui

di e(r2_p)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`r2',0.000001)==round(e(r2_p),0.000001)
**# This calcuation must be off - our R2 fn returns a negative value
//Do we need to add a pseudo R2 calculation for the MLE functions?
// https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faq-what-are-pseudo-r-squareds/



	//Test rmse
//Calculate rmse using our function
mata: st_local("rmse", strofreal(rmse("pred", "low", "touse")))
di `rmse'

//calculate mean percentage error
qui: sum sqerr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`rmse',0.00001)==round(sqrt(r(mean)),0.00001)



	
	//Test mape
//Calculate mape using our function
mata: st_local("mape", strofreal(mape("pred", "low", "touse")))
di `mape'

//calculate abs percentage error
//g double absperr=abs((low-pred)/low)

//calcuate mean of percentage error
sum absperr

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(r(mean),0.00001)
**# This Calculation also seems off



	//Test smape
//Calculate smape using our function
mata: st_local("smape", strofreal(smape("pred", "low", "touse")))
di `smape'

//calculate symmetric percentage error
g double symabsperr=abs(low-pred) / (0.5 * (low + pred))

//calcuate mean of percentage error
sum symabsperr

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(r(mean),0.00001)
**# This Calculation also seems off



	//Test msle
//Calculate msle using our function
mata: st_local("msle", strofreal(msle("pred", "low", "touse")))
di `msle'

//calculate square diff of logs
g double sqdiff=(log(low+1)-log(pred+1))^2

//calcuate mean of percentage error
sum sqdiff

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`msle',0.00001)==round(r(mean),0.00001)
**# Does this metric make sense in a binary case? the log of any of these will either not be defined, ln(0), or 0, ln(1)
// Should we make the typical log() adjustmnet?? LAso is there a difference between log() and ln()?



	//Test rmsle
//Calculate msle using our function
mata: st_local("rmsle", strofreal(rmsle("pred", "low", "touse")))
di `rmsle'

//calcuate mean of percentage error
sum sqdiff

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(sqrt(r(mean)),0.00001)




=======
/*
Purpose: Use Logit example from logit help file to test functions

Notes: 
	[x] confusion() - return a confusion matrix from the predicted/observed value variables
	[x] sensitivity() - sensitivity, specificicty, prevalence, ppv, and npv
	[x] precision() - computes precision from a confusion matrix
	[x] recall() - compute recall, a synonym for sensitivity
	[x] specificity() - computes specificity from a confusion matrix
	[x] prevalence() - computes prevalence
	[x] ppv() - computes positive predictive value
	[x] npv() - computes negative predictive value
	[x] accuracy() - computes accuracy
	[x] bal_accuracy() - computes "balanced" accuracy
	[x] f1() - computes the F1 statistic
	[x] mse() - computes the mean squared error
	[x] mae() - mean absolute error from pred. and observed outcomes
	[x] bias() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[x] mbe() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[?] r2() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
	[x] rmse() - computes root mse 				<- IF MSE WORKS THIS ONE SHOULD TOO
	[?] mape() - mean absolute percentage error
	[?] smape()- symmetric mean absolute percentage error 
	[?] msle() - mean squared log error
	[?] rmsle() - root mean squared log error
*/

//change dir to location of the ado files
cd "~/crossvalidate"  //changes the directory to C:\Users\StevenBrownell\crossvalidate

//Clear data
clear all

//Load mata functions
do crossvalidate.mata
 
//Load data
webuse lbw, clear

//create touse variable
gen touse=1

//Run unrestricted logistic regression to calculate our clssification metrics
logit low age lwt i.race smoke ptl ht ui

//manually calulate predicted values
predict double pred, pr

//round predicted values - "By default, estat classification uses a cutoff of 0.5"
**# NOTE: Should we think about allowing users to adjust the cutoff value?
replace pred=round(pred, 1)


**# NOTE: Since we rewrote the confusion() function to use stata's tabulate, we are overwriting all of the rclass stored results each time we calculate the ocnfusion matrix
	//Test confusion matrix
//Caluclate the confusion matrix using our 
mata: st_matrix("Conf", confusion("pred", "low", "touse"))    

//"reshape" the confusion matrix so that it matches the estat class matrix
mat Intmed=Conf[2,2],Conf[2,1] \ Conf[1,2], Conf[1,1]

//calculates confusion matrix and several of the classification metrics 
qui: estat class

//assign confusion matrix to permanent value
mat estConf = r(ctable)[1..2,1..2]

//calulate difference between two matrices
matrix DiffMat=Intmed-estConf

//assert that the determinant of the difference matrix is 0
assert det(DiffMat)==0

//drop intermediate matrices
mat drop Intmed DiffMat



	//Test Sensitivity
//Calculate Sensitivity using our function
mata: st_local("sens", strofreal(sensitivity("pred", "low", "touse")))

//rerun estat class fn
qui: estat class

//Test for Equality
**# We may wnat to consider reporting percentages with our classification tests instead of decimals/proportions.
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(100*`sens',0.000001)==round(r(P_p1),0.000001)



	//Test Precision
//Calculate Precision using our function
mata: st_local("prec", strofreal(precision("pred", "low", "touse")))
di `prec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`prec',0.00001)==round(100*r(ctable)[1,1]/r(ctable)[1,3],0.00001)



	//Test Recall (aka Sensitivity)
//Calculate Recall using our function
mata: st_local("rec", strofreal(recall("pred", "low", "touse")))
di `rec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(100*`rec',0.000001)==round(r(P_p1),0.000001)



	//Test Specificity
//Calculate Specificity using our function
mata: st_local("spec", strofreal(specificity("pred", "low", "touse")))
di `spec'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`spec',0.00001)==round(r(P_n0),0.00001)



	//Test Prevalence
//Calculate Prevalence using our function
mata: st_local("prev", strofreal(prevalence("pred", "low", "touse")))
di `prev'
//rerun estat class fn
qui: estat class

//view returned values
ret li all

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`prev',0.00001)==round(100*r(ctable)[3,1]/r(ctable)[3,3],0.00001)



	//Test ppv
//Calculate ppv using our function
mata: st_local("ppv", strofreal(ppv("pred", "low", "touse")))
di `ppv'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`ppv',0.00001)==round(r(P_1p),0.00001)



	//Test npv
//Calculate ppv using our function
mata: st_local("npv", strofreal(npv("pred", "low", "touse")))
di `npv'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`npv',0.00001)==round(r(P_0n),0.00001)



	//Test Accuracy
//Calculate Accuracy using our function
mata: st_local("acc", strofreal(accuracy("pred", "low", "touse")))
di `acc'
//rerun estat class fn
qui: estat class

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`acc',0.00001)==round(r(P_corr),0.00001)


	//Test Balanced Accuracy
//Calculate Balanced Accuracy using our function
mata: st_local("balacc", strofreal(bal_accuracy("pred", "low", "touse")))
di `balacc'
//rerun estat class fn
qui: estat class

//view returned values
ret li all

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`balacc',0.00001)==round((r(P_p1)+r(P_n0))/2,0.00001)


	//Test f1
//Calculate f1 using our function
mata: st_local("f1", strofreal(f1("pred", "low", "touse")))
di `f1'
//rerun estat class fn
qui: estat class

//manually calculate precision and save to local macro
local prec=100*r(ctable)[1,1]/r(ctable)[1,3]

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-5
assert round(100*`f1',0.00001)==round((2 * `prec' * r(P_p1)) / (`prec' + r(P_p1)),0.00001)



	//Test mse
//Calculate mse using our function
mata: st_local("mse", strofreal(mse("pred", "low", "touse")))
di `mse'

//calcuate square error
g double sqerr=(low-pred)^2

//calculate mean of square error
mean sqerr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mse',0.000001)==round(r(table)[1,1],0.000001)



	//Test mae
//Calculate mse using our function
mata: st_local("mae", strofreal(mae("pred", "low", "touse")))
di `mae'

//calcuate abs error
g double abserr=abs(low-pred)

//calculate mean of square error
mean abserr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mae',0.000001)==round(r(table)[1,1],0.000001)



	//Test bias
//Calculate bias using our function
mata: st_local("bias", strofreal(bias("pred", "low", "touse")))
di `bias'

//calcuate square error
g double bias=(low-pred)

//calculate mean of square error
sum bias

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`bias',0.000001)==round(r(sum),0.000001)



	//Test mbe
//Calculate bias using our function
mata: st_local("mbe", strofreal(mbe("pred", "low", "touse")))
di `mbe'

//calculate mean of bias
sum bias

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mbe',0.000001)==round(r(mean),0.000001)



	//Test R^2
//Calculate bias using our function
mata: st_local("r2", strofreal(r2("pred", "low", "touse")))
di `r2'

//run logit fn to access stored R2 
qui: logit low age lwt i.race smoke ptl ht ui

di e(r2_p)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`r2',0.000001)==round(e(r2_p),0.000001)
**# This calcuation must be off - our R2 fn returns a negative value
//Do we need to add a pseudo R2 calculation for the MLE functions?
// https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faq-what-are-pseudo-r-squareds/



	//Test rmse
//Calculate rmse using our function
mata: st_local("rmse", strofreal(rmse("pred", "low", "touse")))
di `rmse'

//calculate mean percentage error
qui: sum sqerr

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`rmse',0.00001)==round(sqrt(r(mean)),0.00001)



	
	//Test mape
//Calculate mape using our function
mata: st_local("mape", strofreal(mape("pred", "low", "touse")))
di `mape'

//calculate abs percentage error
//g double absperr=abs((low-pred)/low)

//calcuate mean of percentage error
sum absperr

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(r(mean),0.00001)
**# This Calculation also seems off



	//Test smape
//Calculate smape using our function
mata: st_local("smape", strofreal(smape("pred", "low", "touse")))
di `smape'

//calculate symmetric percentage error
g double symabsperr=abs(low-pred) / (0.5 * (low + pred))

//calcuate mean of percentage error
sum symabsperr

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(r(mean),0.00001)
**# This Calculation also seems off



	//Test msle
//Calculate msle using our function
mata: st_local("msle", strofreal(msle("pred", "low", "touse")))
di `msle'

//calculate square diff of logs
g double sqdiff=(log(low+1)-log(pred+1))^2

//calcuate mean of percentage error
sum sqdiff

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`msle',0.00001)==round(r(mean),0.00001)
**# Does this metric make sense in a binary case? the log of any of these will either not be defined, ln(0), or 0, ln(1)
// Should we make the typical log() adjustmnet?? LAso is there a difference between log() and ln()?



	//Test rmsle
//Calculate msle using our function
mata: st_local("rmsle", strofreal(rmsle("pred", "low", "touse")))
di `rmsle'

//calcuate mean of percentage error
sum sqdiff

di r(mean)

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mape',0.00001)==round(sqrt(r(mean)),0.00001)




