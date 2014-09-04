# Week 2 Quiz (21 Q)

# Q1
num.vect <- floor(runif(20, min = -5, max = 10))

# Q2
char.vect <- as.character(num.vect)

# Q3
fact.vect <- as.factor(num.vect)

# Q4
length(levels(fact.vect))

# Q5
trans.vect <- sapply(num.vect, FUN = function(x) {3 * x**2 - 4 * x + 1})
trans.vect2 <- 3 * num.vect**2 - 4 * num.vect + 1

# Q6 Note to self: solve(A) for inverse of A
reg.beta <- function(X, y) {
  X.X <- t(X) %*% X
  Xy <- t(X) %*% y
  return(solve(X.X) %*% Xy)
}

X <- cbind(
  rep(1, 8),
  c(5,4,6,2,3,2,7,8),
  c(8,9,4,7,4,9,6,4))
y <- c(45.2,46.9,31.0,35.3,25.0,43.1,41.0,35.1)

reg.beta(X, y)

# Q7
named <- list(a = 1, other = 'o')

# Q8
new.df <- data.frame(chars = letters[1:10],
                     fact = factor(sample(c('thing1','thing2','thing3'), 
                                          size = 10, replace = TRUE)),
                     nums = rnorm(n = 10, mean = 0, sd = 10),
                     time = as.Date(
                       floor(runif(10, 10000, 15000)), origin = '1980-01-01'),
                     stringsAsFactors = FALSE
)

# Q9
fact.var <- new.df[['fact']]
fact.var2 <- as.factor(c(as.character(fact.var), 'thing4'))

# Q10
temp <- read.table(file = './temperatures.csv', sep = ',')

# Q11
measures <- read.table(file = 'C:/Users/Paul/Desktop/measurements.txt', sep = '\t')

# Q12 (URL not actually pipe data)
pipe.data <- read.table(file = 'http://www.realeda.com/PipeDelimitedFormat.htm',
                        sep = '|')  # not actually pipe-delimited file

# Q13
twelve.bang <- 1
for (i in 12:1) {
  twelve.bang <- twelve.bang * i
}

# Q14
P <- 1500
int <- .03
for (i in 1:(6 * 12)) {
  P <- P + P * (int / 12)
}
P  <- round(P, digits = 2)

# Q15
q13.vect <- rcauchy(20)
third.sum <- sum(q13.vect[seq(from = 1, to = 20, by = 3)])

# Q16
x <- 0
for (i in 1:10) {
  x <- x + 2**i
}

# Q17
y <- 0
j <- 1
while (j <= 10) {
  y  <- y + 2**j
  j  <-  j + 1
}

# Q18
twos <- rep(2, 10)
powers.two <- twos**(1:10)
sum.powers.two <- sum(powers.two)

# Q19
seq.by.5 <- seq(from = 20, to = 50, by = 5)

# Q20
ten.examples <- rep('example', 10)

# Q21
quadratic <- function(a, b, c) {
  plus.numerator <- -b + sqrt(b**2 - 4 * a * c)
  minus.numerator <- -b - sqrt(b**2 - 4 * a * c)
  denominator <- 2 * a
  root1 <- plus.numerator / denominator
  root2 <- minus.numerator / denominator
  if (root1 == root2) {
    return(root1)
  }
  return(c(root1, root2))
}
quadratic(1, 2, 1)
quadratic(1, 1, -2)
