cscript "train, validation, and/or test " adofile splitit

**# TT Splits
/*******************************************************************************
*                                                                              *
*                          Simple Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator to use to test in expressions
g byte touse = rbinomial(1, 0.5)

// Test for case where the user requests greater than unity for the training set
rcof "splitit 1.2, ret(splitvar)" == 198

// Create a training split with a 20% test sample
splitit .8, ret(splitvar)

// Check the return values
assert "`r(flavor)'" == "Simple Random Sample"
assert "`r(stype)'" == "Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "2"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 80) <= 5

// Test the command with an if expression
splitit 0.8 if touse == 1, ret(newsplit)

// Count the number of cases in the training set
count if newsplit == 1

// Test that this results in approximately 40% of the total sample
assert abs((100 * (`r(N)' / `c(N)')) - 40) <= 5

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .8, ret(splitvar)" == 110

**# TVT Splits
/*******************************************************************************
*                                                                              *
*                    Simple Train, Validate, Test Split Case                   *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a variable to use for an if expression
g byte touse = rbinomial(1, 0.5)

// Test for case where the user requests greater than unity for the training and 
// validation set
rcof "splitit .6 .6, ret(splitvar)" == 198

// Create a training split with a 20% validation and 20% test sample
splitit .6 .2, ret(splitvar)

// Check the return values
assert "`r(flavor)'" == "Simple Random Sample"
assert "`r(stype)'" == "Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == "2"
assert "`r(testing)'" == "3"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 60) <= 5

// Count the number of records in the validation split
count if splitvar == 2

// Test the percentage of the validation set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Count the number of records in the test split
count if splitvar == 3

// Test the percentage of the test set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Call the command using an if expression
splitit 0.6 0.2 if touse == 1, ret(newsplit)

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 30) <= 5

// Count the number of records in the validation split
count if newsplit == 2

// Test the percentage of the validation set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Count the number of records in the test split
count if newsplit == 3

// Test the percentage of the test set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .6 .2, ret(splitvar)" == 110

**# K-Fold TT Splits
/*******************************************************************************
*                                                                              *
*                          K-Fold Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a variable to use for if expression testing
g byte touse = rbinomial(1, 0.5)

// Create 4 fold training set with a 20% hold out test set
splitit 0.8, kf(4) ret(splitvar)

// Check the return values
assert "`r(flavor)'" == "Simple Random Sample"
assert "`r(stype)'" == "K-Fold Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3 4"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "5"

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

} // End loop over the splits

// Create 4 fold training set with a 20% hold out test set
splitit 0.8 if touse == 1, kf(4) ret(newsplit)

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

} // End loop over the splits

**# K-Fold TVT Splits
/*******************************************************************************
*                                                                              *
*                    K-Fold Train, Validate, Test Split Case                   *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a variable to test if expressions
g byte touse = rbinomial(1, 0.5)

// Create 3 fold training set with a 20% hold out validation and test sets
splitit 0.6 .2, kf(3) ret(splitvar)

// Check the return values
assert "`r(flavor)'" == "Simple Random Sample"
assert "`r(stype)'" == "K-Fold Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3"
assert "`r(validation)'" == "4"
assert "`r(testing)'" == "5"

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

} // End loop over the splits

// Create 4 fold training set with a 20% hold out test set
splitit 0.6 0.2 if touse == 1, kf(3) ret(newsplit)

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

} // End loop over the splits

**# Clustered TT Splits
/*******************************************************************************
*                                                                              *
*                       Clustered Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 2

// Create a pre/post indicator for each ID
bys id: g byte prepost = _n

// Test for case where the user requests greater than unity for the training set
rcof "splitit 1.2, uid(id) ret(splitvar)" == 198

// Create a training split with a 20% test sample
splitit .8, ret(splitvar) uid(id)

// Check the return values
assert "`r(flavor)'" == "Clustered Random Sample"
assert "`r(stype)'" == "Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "2"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 80) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .8, uid(id) ret(splitvar)" == 110

// Create a training split with a 20% test sample
splitit .8 if touse == 1, ret(newsplit) uid(id)

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 40) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# Clustered TVT Splits
/*******************************************************************************
*                                                                              *
*                 Clustered Train, Validate, Test Split Case                   *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create variable to test if expressions
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 2

// Create a pre/post indicator for each ID
bys id: g byte prepost = _n

// Test for case where the user requests greater than unity for the training and 
// validation set
rcof "splitit .6 .6, uid(id) ret(splitvar)" == 198

// Create a training split with a 20% validation and 20% test sample
splitit .6 .2, uid(id) ret(splitvar)

// Check the return values
assert "`r(flavor)'" == "Clustered Random Sample"
assert "`r(stype)'" == "Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == "2"
assert "`r(testing)'" == "3"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 60) <= 5

// Count the number of records in the validation split
count if splitvar == 2

// Test the percentage of the validation set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Count the number of records in the test split
count if splitvar == 3

// Test the percentage of the test set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1

// Create a training split with a 20% test sample
splitit .6 .2 if touse == 1, ret(newsplit) uid(id)

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 30) <= 5

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 2

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 3

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .6 .2, uid(id) ret(splitvar)" == 110

**# Clustered K-Fold TT Splits
/*******************************************************************************
*                                                                              *
*                      Clustered K-Fold Train Test Split Case                  *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create variable to test if expressions
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 2

// Create a pre/post indicator for each ID
bys id: g byte prepost = _n

// Create 4 fold training set with a 20% hold out test set
splitit 0.8, kf(4) ret(splitvar) uid(id)

// Check the return values
assert "`r(flavor)'" == "Clustered Random Sample"
assert "`r(stype)'" == "K-Fold Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3 4"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "5"

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)'))) - 20 <= 5

} // End loop over the splits

// Call the command using an if expression
splitit 0.8 if touse == 1, kf(4) ret(newsplit) uid(id)

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)'))) - 10 <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# Clustered K-Fold TVT Splits
/*******************************************************************************
*                                                                              *
*                 Clustered K-Fold Train, Validate, Test Split Case            *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create variable to test if expressions
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 2

// Create a pre/post indicator for each ID
bys id: g byte prepost = _n

// Create 3 fold training set with a 20% hold out validation and test sets
splitit 0.6 .2, kf(3) ret(splitvar) uid(id)

// Check the return values
assert "`r(flavor)'" == "Clustered Random Sample"
assert "`r(stype)'" == "K-Fold Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3"
assert "`r(validation)'" == "4"
assert "`r(testing)'" == "5"

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)'))) - 20 <= 5

} // End loop over the splits

// Call the command using an if expression
splitit 0.6 0.2 if touse == 1, kf(3) ret(newsplit) uid(id)

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i'

	// Test the percentage of each fold/split
	assert abs((100 * (`r(N)' / `c(N)'))) - 10 <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# XT/TS TT Splits
/*******************************************************************************
*                                                                              *
*                         XT/TS Train Test Split Case                          *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// Test for case where the user doesn't have the data xt or ts set
rcof `"splitit .8, tp(td("04feb2024"))"' == 459

// xtset the data
xtset id time

// Create a training split with a 20% test sample
splitit .8, ret(splitvar) tp(td("04feb2024"))

// Check the return values
assert "`r(flavor)'" == "Panel Unit Sample"
assert "`r(stype)'" == "Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "2"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   This should be 0.5 * the size of the splits defined due to the value 
******   of the time point used.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 40) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .8, uid(id) ret(splitvar)" == 110

// Create a training split with a 20% test sample
splitit .8 if touse == 1, ret(newsplit) tp(td("04feb2024"))

******   
******   This should be 0.25 * the size of the splits defined due to the value 
******   of the time point used combined with the if statement.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# XT/TS TVT Splits
/*******************************************************************************
*                                                                              *
*                   XT/TS Train, Validate, Test Split Case                     *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// Test for unspecified splitvar name
rcof `"splitit .6 .2, tp(td("04feb2024"))"' == 459

// xtset the data
xtset id time

// Create a training split with a 20% test sample
splitit .6 .2, ret(splitvar) tp(td("04feb2024"))

// Check the return values
assert "`r(flavor)'" == "Panel Unit Sample"
assert "`r(stype)'" == "Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == "2"
assert "`r(testing)'" == "3"
assert "`r(forecastset)'" == "splitvarxv4"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

******   
******   These should be 0.5 * the size of the splits defined due to the value 
******   of the time point used.
******   

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 30) <= 5

// Count the number of records with a value of 2 for splitvar (validation sample)
count if splitvar == 2

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Count the number of records with a value of 3 for splitvar (test sample)
count if splitvar == 3

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 10) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create a training split with a 20% test sample
splitit .6 .2 if touse == 1, ret(newsplit) tp(td("04feb2024"))

******   
******   These should be 0.25 * the size of the splits defined due to the value 
******   of the time point used combined with the if statement.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 15) <= 5

// Count the number of records with a value of 2 for splitvar (validation sample)
count if newsplit == 2

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 5) <= 5

// Count the number of records with a value of 3 for splitvar (test sample)
count if newsplit == 3

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 5) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# XT/TS K-Fold TT Splits
/*******************************************************************************
*                                                                              *
*                   K-Fold XT/TS Train Test Split Case                         *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// Test for case where the user doesn't have the data xt or ts set
rcof `"splitit .8, tp(td("04feb2024"))"' == 459

// xtset the data
xtset id time

// Create a training split with a 20% test sample 
// This date should retain five time periods in the training sample
splitit .8, kf(4) ret(splitvar) tp(td("06feb2024"))

// Check the return values
assert "`r(flavor)'" == "Panel Unit Sample"
assert "`r(stype)'" == "K-Fold Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3 4"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "5"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   Each split should have 20% of the respective time sample or 1/6th of  
******   the total sample.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5
	
	// Count the number of cases in the forcast sample
	count if splitvarxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create a training split with a 20% test sample on half of the data
splitit .8 if touse == 1, kf(4) ret(newsplit) tp(td("06feb2024"))

******   
******   Each split should have 10% of the respective time sample or 1/12th of  
******   the total sample due to the if expression.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5
	
	// Count the number of cases in the forcast sample
	count if newsplitxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# XT/TS K-Fold TVT Splits
/*******************************************************************************
*                                                                              *
*             K-Fold XT/TS Train, Validation, Test Split Case                  *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// xtset the data
xtset id time

// Create a training split with a 20% test sample and 20% validation sample
// This date should retain five time periods in the training sample
splitit .6 .2, kf(3) ret(splitvar) tp(td("06feb2024"))

// Check the return values
assert "`r(flavor)'" == "Panel Unit Sample"
assert "`r(stype)'" == "K-Fold Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3"
assert "`r(validation)'" == "4"
assert "`r(testing)'" == "5"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   Each split should have 20% of the respective time sample or 1/6th of  
******   the total sample.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5
	
	// Count the number of cases in the forcast sample
	count if splitvarxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create a training split with a 20% test sample on half of the data
splitit .8 if touse == 1, kf(4) ret(newsplit) tp(td("06feb2024"))

******   
******   Each split should have 10% of the respective time sample or 1/12th of  
******   the total sample due to the if expression.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5
	
	// Count the number of cases in the forcast sample
	count if newsplitxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

**# Clustered XT/TS TT Splits
/*******************************************************************************
*                                                                              *
*                 Clustered XT/TS Train Test Split Case                        *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a binary group membership indicator
g byte ingroup = rbinomial(1, 0.5)

// Create an indicator for if expression testing.  This should result in the 
// the tests with the if expressions being half the size of the unclustered test
// cases
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a new group indicator that will not have IDs nested correctly
g byte badgroups = rbinomial(1, 0.5)

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// xtset the data
xtset id time

// Test for case where the user specifies non-nested panels with clusters.
rcof `"splitit .8, uid(badgroups) tp(td("04feb2024"))"' == 459

// Create a training split with a 20% test sample
splitit .8, uid(ingroup id) ret(splitvar) tp(td("04feb2024"))

// Check the return values
assert "`r(flavor)'" == "Clustered & Panel Sample"
assert "`r(stype)'" == "Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "2"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   This should be 0.5 * the size of the splits defined due to the value 
******   of the time point used.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 40) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create an indicator for the number of splitvar values per cluster
egen clsplits = nvals(splitvar), by(ingroup)

// Verify that there are two values for each 
assert clsplits == 2 if !mi(splits)

// Create a training split with a 20% test sample
splitit .8 if touse == 1, uid(ingroup) ret(newsplit) tp(td("04feb2024"))

******   
******   This should be 0.25 * the size of the splits defined due to the value 
******   of the time point used combined with the if statement.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

// Create an indicator for the number of splitvar values per cluster
egen ifclsplits = nvals(newsplit), by(ingroup)

// Verify that there are two values for each 
assert ifclsplits == 2 if !mi(ifclsplits)


**# Clustered XT/TS TVT Splits
/*******************************************************************************
*                                                                              *
*                 Clustered XT/TS Train, Validate, Test Split Case             *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create group ID

// Create an id variable
g int id = _n

// Create a binary group membership indicator
g byte ingroup = rbinomial(1, 0.5)

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// xtset the data
xtset id time

// Create a training split with 20% test and validation samples
splitit .6 .2, uid(ingroup) ret(splitvar) tp(td("04feb2024"))

// Check the return values
assert "`r(flavor)'" == "Clustered & Panel Sample"
assert "`r(stype)'" == "Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1"
assert "`r(validation)'" == "2"
assert "`r(testing)'" == "3"
assert "`r(forecastset)'" == "splitvarxv4"

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

******   
******   These should be 0.5 * the size of the splits defined due to the value 
******   of the time point used and the clustering on half of the sample.
******   

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 30) <= 5

// Count the number of records with a value of 2 for splitvar (validation sample)
count if splitvar == 2

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 15) <= 5

// Count the number of records with a value of 3 for splitvar (test sample)
count if splitvar == 3

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 15) <= 5

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create an indicator for the number of splitvar values per cluster
egen clsplits = nvals(splitvar), by(ingroup)

// Verify that there are two values for each 
assert clsplits == 2 if !mi(splits)

// Create a training split with a 20% test sample
splitit .6 .2 if touse == 1, uid(ingroup) ret(newsplit) tp(td("04feb2024"))

******   
******   These should be 0.25 * the size of the splits defined due to the value 
******   of the time point used combined with the if statement and the cluster.
******   

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 15) <= 5

// Count the number of records with a value of 2 for splitvar (validation sample)
count if newsplit == 2

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 5) <= 5

// Count the number of records with a value of 3 for splitvar (test sample)
count if newsplit == 3

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 5) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

// Create an indicator for the number of splitvar values per cluster
egen ifclsplits = nvals(newsplit), by(ingroup)

// Verify that there are two values for each 
assert ifclsplits == 3 if !mi(ifclsplits)

**# Clustered XT/TS K-Fold TT Splits
/*******************************************************************************
*                                                                              *
*                   Clustered K-Fold XT/TS Train Test Split Case               *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a binary group membership indicator
g byte ingroup = rbinomial(1, 0.5)

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// xtset the data
xtset id time

// Create a training split with a 20% test sample 
// This date should retain five time periods in the training sample
splitit .8, kf(4) uid(ingroup) ret(splitvar) tp(td("06feb2024"))

// Check the return values
assert "`r(flavor)'" == "Clustered & Panel Sample"
assert "`r(stype)'" == "K-Fold Train/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3 4"
assert "`r(validation)'" == ""
assert "`r(testing)'" == "5"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   Each split should have 20% of the respective time sample 
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5
	
	// Count the number of cases in the forcast sample
	count if splitvarxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create an indicator for the number of splitvar values per cluster
egen clsplits = nvals(splitvar), by(ingroup)

// Verify that there are two values for each 
assert clsplits == 5 if !mi(splits)

// Create a training split with a 20% test sample on half of the data
splitit .8 if touse == 1, kf(4) ret(newsplit) tp(td("06feb2024"))

******   
******   Each split should have 10% of the respective time sample due to the if  
******   expression.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5
	
	// Count the number of cases in the forcast sample
	count if newsplitxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

// Create an indicator for the number of splitvar values per cluster
egen ifclsplits = nvals(newsplit), by(ingroup)

// Verify that there are two values for each 
assert ifclsplits == 5 if !mi(ifclsplits)

**# Clustered XT/TS K-Fold TVT Splits
/*******************************************************************************
*                                                                              *
*          Clustered K-Fold XT/TS Train, Validation, Test Split Case           *
*                                                                              *
*******************************************************************************/

// Clear all data from memory
clear

// Set the pseudorandom number seed
set seed 7779311

// Create a dataset with 100 observations
set obs 1000

// Create an id variable
g int id = _n

// Create a binary group membership indicator
g byte ingroup = rbinomial(1, 0.5)

// Create an indicator for if expression testing
g byte touse = rbinomial(1, 0.5)

// Duplicate the ids twice
expand 6

// Create a time period value based on 01feb2024
bys id: g int time = _n + 23407

// Format the time variable
format %td time

// xtset the data
xtset id time

// Create a training split with a 20% test sample and 20% validation sample
// This date should retain five time periods in the training sample
splitit .6 .2, kf(3) uid(ingroup) ret(splitvar) tp(td("06feb2024"))

// Check the return values
assert "`r(flavor)'" == "Clustered & Panel Sample"
assert "`r(stype)'" == "K-Fold Train/Validate/Test Split"
assert "`r(splitter)'" == "splitvar"
assert "`r(training)'" == "1 2 3"
assert "`r(validation)'" == "4"
assert "`r(testing)'" == "5"
assert "`r(forecastset)'" == "splitvarxv4"

******   
******   Each split should have 20% of the respective time sample or 1/6th of  
******   the total sample.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if splitvar == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5
	
	// Count the number of cases in the forcast sample
	count if splitvarxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 20) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen splits = nvals(splitvar), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert splits == 1 if !mi(splits)

// Create an indicator for the number of splitvar values per cluster
egen clsplits = nvals(splitvar), by(ingroup)

// Verify that there are two values for each 
assert clsplits == 5 if !mi(splits)

// Create a training split with a 20% test sample on half of the data
splitit .8 if touse == 1, kf(4) uid(ingroup) ret(newsplit) tp(td("06feb2024"))

******   
******   Each split should have 10% of the respective time sample or 1/12th of  
******   the total sample due to the if expression.
******   

// Loop over the values of the split var
forv i = 1/5 {

	// Count the number of cases in each split
	count if newsplit == `i' & time <= td("06feb2024")

	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases prior to the tpoint
	count if time <= td("06feb2024")
	
	// Test the percentage of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5
	
	// Count the number of cases in the forcast sample
	count if newsplitxv4 == `i' & time > td("06feb2024")
	
	// Store the split sample size
	loc splitn `r(N)'
	
	// Count the number of cases after the tpoint
	count if time > td("06feb2024")
	
	// Test the percentage of the forecast sample of each fold/split
	assert abs((100 * (`splitn' / `r(N)')) - 10) <= 5

} // End loop over the splits

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

// Create an indicator for the number of splitvar values per cluster
egen ifclsplits = nvals(newsplit), by(ingroup)

// Verify that there are two values for each 
assert ifclsplits == 5 if !mi(ifclsplits)
