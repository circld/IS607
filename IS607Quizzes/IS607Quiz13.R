# IS607 Week 13 Quiz
# Paul Garaud

require(microbenchmark)

# function to profile: matrix multiplication (vcov)
set.seed(100)

test.func <- function() {
  x = matrix(data = runif(10000), nrow = 100, ncol = 100)
  return(x %*% t(x))
}

microbenchmark(test.func(), unit = 's')
# ~ .002 sec mean execution time