require(doParallel)

test.func <- function() {
  set.seed(100)
  x = matrix(data = runif(10000), nrow = 100, ncol = 100)
  return(x %*% t(x))
}

cl <- makeCluster(detectCores())
registerDoParallel(cl)

# parallelized version
microbenchmark(foreach(i=1:100) %dopar% test.func(), unit = 's')
# non-parallelized version
microbenchmark(foreach(i=1:100) %do% test.func(), unit = 's')

stopCluster(cl)
