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
set obs 100

// Create an id variable
g byte id = _n

// Create a training split with a 20% test sample
splitit .8, ret(splitvar)

// Count the number of records with a value of 1 for splitvar (train sample)
count if splitvar == 1

// Test the percentage of the training set
assert 100 * (`r(N)' / `c(N)') == 80

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .8, ret(splitvar)" == 110

// Drop the split variable
drop splitvar

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
set obs 100

// Create an id variable
g byte id = _n

// Create a training split with a 20% validation and 20% test sample
splitit .6 .2, ret(splitvar)

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

// Verify that the command throws error code 110 if the split variable is already
// defined
rcof "splitit .6 .2, ret(splitvar)" == 110

// Verify that the command throws error code 100 if the user requests a train, 
// validation, test split but doesn't provide a variable name to store the result
rcof "splitit .6 .2" == 100

// Drop the split variable
drop splitvar

