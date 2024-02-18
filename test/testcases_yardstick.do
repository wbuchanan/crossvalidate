//Purpose: Test Cases of Mata Classification Functions 
/*
Notes: 
	Bi Mult Cont
	[x] [X]    confusion() - return a confusion matrix from the predicted/observed value variables
	[x] [x]    sensitivity() - sensitivity, specificicty, prevalence, ppv, and npv
	[x] [x]    precision() - computes precision from a confusion matrix
	[x] [x]    recall() - compute recall, a synonym for sensitivity
	[x] [x]    specificity() - computes specificity from a confusion matrix
	[x] [x]    prevalence() - computes prevalence / mc detection prevalence
	[x] [x]    ppv() - computes positive predictive value
	[x] [x]    npv() - computes negative predictive value
	[x] [x]    accuracy() - computes accuracy
	[x] [x]    bal_accuracy() - computes "balanced" accuracy
	[x] [x]    f1() - computes the F1 statistic
	[x] [x]    multiclass J-index
	    []     multiclass Kappa
	[x] []     multiclass MCC	
	[x]	[]  [] Binary/multiclass R^2 (polychoric correlation)/Continuous R^2
			[] mse() - computes the mean squared error
			[] mae() - mean absolute error from pred. and observed outcomes
			[] bias() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/
			[] mbe() - metric biased on definition https://developer.nvidia.com/blog/a-comprehensive-overview-of-regression-evaluation-metrics/		
			[] rmse
			[] mape
			[] smape
			[] msle			
			[] rmsle	
			[] iic
			[] ccc
			[] phl
			[] huber
			[] pll			
*/

//clear all
clear all

//Change working Directory
cd "~/crossvalidate"

//Load mata functions
do crossvalidate.mata

**# Creates binary data set
/*******************************************************************************
*																			   *
			data_powers() from yardstick/tests/testthat/helper-data.R
*																			   *
*******************************************************************************/
//drop program if it exists
capture program drop data_powers

//define program to generate test data
program define data_powers

//clear data in memory
clear 

//Create 100 observations 
set obs 100

//Generate predicted Variable
//"Relevant" values = 1
gen int pred = 1
//"Irrelevant" values = 0 
replace pred = 0 if _n>42

//Generate predicted with NA / missing values
gen int pred_na = pred
replace pred_na = . if inlist(_n, 1, 10, 20, 30, 40, 50) 

//Generate observed variable 
//"Relevant" values = 1
gen int obs = 1 
//"Irrelevant" values = 0 
replace obs = 0 if inrange(_n,31,42) | inrange(_n,73,100)

//create touse variable
gen touse = 1

//end program
end


**# Creates three class data set
/*******************************************************************************
*																			   *
		data_three_class() from yardstick/tests/testthat/helper-data.R
*																			   *
*******************************************************************************/
//drop program if it exists
capture program drop data_three_class

//define program to generate test data
program define data_three_class

//clear data in memory
clear 

//set seed
set seed 1311

//Create 100 observations 
set obs 150

//Generate observed values
//"setosa" = 0 
g int obs = 0 
//"versicolor" = 1 
replace obs = 1 if inrange(_n,51,100)
//"virginica" =2 
replace obs = 2 if _n > 100

//Generate predicted values
gen pred = runiformint(0,2)

//create touse variable
gen touse = 1

//end program 
end



**# Binary Classificating Metrics
/*******************************************************************************
*                                                                              *
*                   Binary Classification Metrics Start Here                   *
*                                                                              *
*******************************************************************************/

//call program to generate the two class data
data_powers

//Display Confusion Matrix
tab pred obs, matcell(c)

//calculate and store basic classification metrics
// manually calcuate and store sensitivity
local sns = 30/(30+30)

// manually calcuate and store prevalence
local prv = (30+30)/(28+30+12+30)

// manually calcuate and store specificity
local spc = 28/(28+12)

// manually calcuate and store precision
local prc = 30/(30+12)

// manually calcuate and store recall
local rc = 30/(30+30)



	//Confusion matrix
//call confusion matrix
mata: st_matrix("Conf", confusion("pred", "obs", "touse"))    

//calulate difference between two matrices
matrix DiffMat=c-Conf

//assert that the determinant of the difference matrix is 0
assert det(DiffMat)==0



	//Sensitivity()
//call sensitivity
mata: st_local("sens", strofreal(sens("pred", "obs", "touse")))

//Test for Equality
assert round(`sens',0.000001)==round(`sns',0.000001)



	//Precision()
//call precision test
mata: st_local("prec", strofreal(prec("pred", "obs", "touse")))

//Test for Equality
assert round(`prec',0.000001)==round(`prc',0.000001)



	//Test Recall (aka Sensitivity)
//Calculate Recall using our function
mata: st_local("rec", strofreal(recall("pred", "obs", "touse")))

//Test for Equality
assert round(`rec',0.000001)==round(`rc',0.000001)



	//Test Specificity
//Calculate Specificity using our function
mata: st_local("spec", strofreal(spec("pred", "obs", "touse")))

//Test for Equality
assert round(`spec',0.000001)==round(`spc',0.000001)



	//Test Prevalence
//Calculate Prevalence using our function
mata: st_local("prev", strofreal(prev("pred", "obs", "touse")))

//Test for Equality
assert round(`prev',0.000001)==round(`prv',0.000001)



	//Test ppv
//Calculate ppv using our function
mata: st_local("ppv", strofreal(ppv("pred", "obs", "touse")))

//Test for Equality
assert round(`ppv',0.0000001)==round((`sns' * `prv') / ((`sns' * `prv') + ((1 - `spc') * (1 - `prv'))),0.0000001)



	//Test npv
//Calculate ppv using our function
mata: st_local("npv", strofreal(npv("pred", "obs", "touse")))

//Test for Equality
assert round(`npv',0.0000001)==round((`spc' * (1 - `prv')) / (((1 - `sns') * `prv') + (`spc' * (1 - `prv'))),0.0000001)



	//Test Accuracy
//Calculate Accuracy using our function
mata: st_local("acc", strofreal(acc("pred", "obs", "touse")))

//Test for Equality
assert round(`acc',0.0000001)==round((28+30)/(28+30+12+30),0.0000001)



	//Test Balanced Accuracy
//Calculate Balanced Accuracy using our function
mata: st_local("balacc", strofreal(bacc("pred", "obs", "touse")))

//Test for Equality
assert round(`balacc',0.0000001)==round((`sns' + `spc')/2,0.0000001)



	//Test f1
//Calculate f1 using our function
mata: st_local("f1", strofreal(f1("pred", "obs", "touse")))

//Test for Equality
assert round(`f1',0.00001)==round((2 * `prc' * `rc') / (`prc' + `rc'),0.00001)



	//Test mse
//Calculate mse using our function
mata: st_local("mse", strofreal(mse("pred", "obs", "touse")))

//calcuate square error
qui g double sqerr=(obs-pred)^2

//calculate mean of square error
qui mean sqerr

//Test for Equality
assert round(`mse',0.000001)==round(r(table)[1,1],0.000001)



	//Test mae
//Calculate mse using our function
mata: st_local("mae", strofreal(mae("pred", "obs", "touse")))

//calcuate abs error
qui g double abserr=abs(obs-pred)

//calculate mean of square error
qui mean abserr

//Test for Equality
assert round(`mae',0.000001)==round(r(table)[1,1],0.000001)



	//Test bias
//Calculate bias using our function
mata: st_local("bias", strofreal(bias("pred", "obs", "touse")))

//calcuate square error
qui g double bias=(obs-pred)

//calculate mean of square error
qui sum bias

//Test for Equality
assert round(`bias',0.000001)==round(r(sum),0.000001)



	//Test mbe
//Calculate bias using our function
mata: st_local("mbe", strofreal(mbe("pred", "obs", "touse")))

//calculate mean of bias
qui sum bias

//Test for Equality
//Currently the mata function is identical to the canned fn 1.0e^-6
assert round(`mbe',0.000001)==round(r(mean),0.000001)



	//Test j-index
//Calculate f1 using our function
mata: st_local("jind", strofreal(jindex("pred", "obs", "touse")))

//Test for Equality
assert round(`jind',0.0000001)==round(`sns' + `spc' - 1,0.0000001)



	//Test Binary R^2
//Calculate tetrachoric correlation
mata: st_local("r2", strofreal(binr2("pred", "obs", "touse")))

//define alpha to calculate edwards rho estimate from https://www.stata.com/manuals/rtetrachoric.pdf
local alph = ((28 * 30) / (30 * 12))^(_pi/4)

//Test for Equality
assert round(`r2',0.0000001)==round((`alph' - 1) / (`alph' + 1),0.0000001)



	//Test MCC
//Calculate the MCC
mata: st_local("mcc", strofreal(mcc("pred", "obs", "touse")))

//Define numerator
local num = (30 + 28) * 100 - (60 * 42) - (40 * 58)

//Define denominator 1
local den1 = 100^2 - 40^2 - 60^2

//Define denominator 2
local den2 = 100^2 - 58^2 - 42^2

//Test for Equality
assert round(`mcc',0.0000001)==round(`num'/(sqrt(`den1')*sqrt(`den2')),0.0000001)

	
	
**# Multinomial Classificating Metrics
/*******************************************************************************
*                                                                              *
*                   Multinomial Classification Metrics                         *
*                                                                              *
*******************************************************************************/

//call program to generate the two class data
data_three_class

//Display Confusion Matrix
tab pred obs, matcell(c)

//calculate and store basic classification metrics
// manually calcuate and store sensitivity
local sns = (22+21+21)/(22+19+15+13+21+14+15+10+21)

// manually calcuate and store micro averaged prevalence
local prv = (56/150 + 48/150 + 46/150)/3

// manually calcuate and store specificity
local spc = (66+73+75)/(66+34+73+27+75+25)

// manually calcuate and store precision
local prc = (22+21+21)/(56+48+46)

// manually calcuate and store recall
local rc = (22+21+21)/(22+19+15+13+21+14+15+10+21)



	//Confusion matrix
//call confusion matrix
mata: st_matrix("Conf", confusion("pred", "obs", "touse"))    

//calulate difference between two matrices
matrix DiffMat=c-Conf

//assert that the determinant of the difference matrix is 0
assert det(DiffMat)==0



	//Sensitivity()
//call sensitivity
mata: st_local("sens", strofreal(mcsens("pred", "obs", "touse")))

//Test for Equality
assert round(`sens',0.000001)==round(`sns',0.000001)



	//Precision()
//call precision test
mata: st_local("prec", strofreal(mcprec("pred", "obs", "touse")))

//Test for Equality
assert round(`prec',0.000001)==round(`prc',0.000001)



	//Test Recall (aka Sensitivity)
//Calculate Recall using our function
mata: st_local("rec", strofreal(mcrecall("pred", "obs", "touse")))

//Test for Equality
assert round(`rec',0.000001)==round(`rc',0.000001)



	//Test Specificity
//Calculate Specificity using our function
mata: st_local("spec", strofreal(mcspec("pred", "obs", "touse")))

//Test for Equality
assert round(`spec',0.000001)==round(`spc',0.000001)



	//Test Detection Prevalence
//Calculate Prevalence using our function
mata: st_local("prev", strofreal(mcdetect("pred", "obs", "touse")))

//Test for Equality
assert round(`prev',0.000001)==round(`prv',0.000001)



	//Test ppv - multiclass ppv should be equal to mc precision
//Calculate ppv using our function
mata: st_local("ppv", strofreal(mcppv("pred", "obs", "touse")))

//Test for Equality
assert round(`ppv',0.0000001)==round(`prc',0.0000001)



	//Test npv
//Calculate ppv using our function
mata: st_local("npv", strofreal(mcnpv("pred", "obs", "touse")))

//Test for Equality
assert round(`npv',0.0000001)==round((`spc' * (1 - `prv')) / (((1 - `sns') * `prv') + (`spc' * (1 - `prv'))),0.0000001)



	//Test Accuracy
//Calculate Accuracy using our function
mata: st_local("acc", strofreal(mcacc("pred", "obs", "touse")))

//Test for Equality
assert round(`acc',0.0000001)==round((22+21+21)/(22+19+15+13+21+14+15+10+21),0.0000001)



	//Test Balanced Accuracy
//Calculate Balanced Accuracy using our function
mata: st_local("balacc", strofreal(mcbacc("pred", "obs", "touse")))

//Test for Equality
assert round(`balacc',0.0000001)==round((`sns' + `rc')/2,0.0000001)



	//Test f1
//Calculate f1 using our function
mata: st_local("f1", strofreal(mcf1("pred", "obs", "touse")))

//Test for Equality
assert round(`f1',0.0000001)==round((2 * `prc' * `sns') / (`prc' + `sns'),0.0000001)



	//Test j-index
//Calculate f1 using our function
mata: st_local("jind", strofreal(mcjindex("pred", "obs", "touse")))

//Test for Equality
assert round(`jind',0.0000001)==round(`sns' + `spc' - 1,0.0000001)

	

	//Test Kappa
//Calculate Kappa using our function
mata: st_local("kap", strofreal(mckappa("pred", "obs", "touse")))

//define weight matrix
mat wgt = [0, 1, 1 \ 1, 0 , 1 \ 1, 1, 0]

//define row margins 
mat row = [56, 48, 46]

//define column margins
mat col = ([50, 50, 50])'

//redefind confusion matrix
qui tab pred obs, matcell(c)

//calculate numerator
mata: st_matrix("numer", sum( st_matrix("wgt") * st_matrix("c")))

//calculate demonenator
mata: st_matrix("denom", sum( st_matrix("wgt") * (st_matrix("row") * st_matrix("col") :/ 150)) )

//Test for Equality
assert round(`kap',0.0000001)==round((1 - numer[1,1]/denom[1,1]),0.0000001)



	//Test MCC
//Calculate MCC using our function
mata: st_local("mcc", strofreal(mcmcc("pred", "obs", "touse")))
	
//Define numerator
local num = (22 + 21 + 21) * 150 - (50 * 46) - (50 * 48) - (50 * 56)

//Define denominator 1
local den1 = 150^2 - 50^2 - 50^2 - 50^2

//Define denominator 2
local den2 = 150^2 - 56^2 - 48^2 - 46^2

//Test for Equality
assert round(`mcc',0.0000001)==round(`num'/(sqrt(`den1')*sqrt(`den2')),0.0000001)	
	
	
	
	//Test multiclass R^2 (polychoric correlation)
//Calculate R^2 using our function
mata: st_local("r2", strofreal(mcordr2("pred", "obs", "touse")))

di `r2'
//Still need to find a formula for this one

//Test for Equality
//assert round(`r2',0.0000001)==round((`alph' - 1) / (`alph' + 1),0.0000001)


	
	
	
