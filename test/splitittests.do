cscript "train, validation, and/or test " adofile splitit

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

// Verify that the command throws error code 100 if the user requests a train, 
// validation, test split but doesn't provide a variable name to store the result
rcof "splitit .6 .2" == 100

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

// Verify that the command throws error code 100 if the user requests a train, 
// validation, test split but doesn't provide a variable name to store the result
rcof "splitit .6 .2, uid(id)" == 100


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

// Count the number of records with a value of 1 for splitvar (train sample)
count if newsplit == 1

// Test the percentage of the training set
assert abs((100 * (`r(N)' / `c(N)')) - 20) <= 5

// Create an indicator for the number of splitvar values per id
egen ifsplits = nvals(newsplit), by(id)

// Verify that there is only a single split value per ID (that entire clusters 
// are assigned to the same split)
assert ifsplits == 1 if !mi(ifsplits)

