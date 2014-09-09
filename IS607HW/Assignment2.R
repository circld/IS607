# IS607 Assignment 2
# Paul Garaud

#### Question 1 ####
# a
queue <- c(James = 'James', 
           Mary = 'Mary',
           Steve = 'Steve',
           Alex = 'Alex', 
           Patricia = 'Patricia')

# b - Harold arrives
queue <- c(queue, Harold = 'Harold')

# c - James checks out
queue <- queue[-1]
# alternatively

# d - no Pam in the queue, but will assume you meant that Patricia has moved
#     ahead of Steve
queue <- queue[c('Mary', 'Patricia', 'Steve', 'Alex', 'Harold')]

# e - Harold has left
queue <- queue[queue != 'Harold']

# f - Alex has left
queue <- queue[queue != 'Alex']

# g - Identify Patricia's position
which(queue == 'Patricia')
# 2

# h - Count the number of people still in queue
length(queue)
# 3

#### Question 2 ####
quadratic <- function(a, b, c) {
  discriminant <- b**2 - 4 * a * c
  if (discriminant < 0) {
    stop('No real number solutions.')
  }
  if (a == 0) {
    stop('Not a valid quadratic expression.')
  }
  plus.numerator <- -b + sqrt(discriminant)
  minus.numerator <- -b - sqrt(discriminant)
  denominator <- 2 * a
  root1 <- plus.numerator / denominator
  root2 <- minus.numerator / denominator
  if (root1 == root2) {
    return(root1)
  }
  return(c(root1, root2))
}
quadratic(1, 2, 1)
# -1
quadratic(1, 1, -2)
# 1 -2
quadratic(1, 0, 1)
# Error in quadratic(1, 0, 1) : No real number solutions.

#### Question 3 ####
sum((1:1000 %% 3 != 0 & 1:1000 %% 7 != 0 & 1:1000 %% 11 != 0))
# 520 numbers in 1-1000 not divisible by 3, 7, or 11

#### Question 4 ####
pythag.triple <- function(f=NULL, g=NULL, h=NULL) {
  sides <- c(f, g, h)
  print(sides)
  if (length(sides) < 3) {
    stop('Three arguments required.')
  }
  if (f < 0 || g < 0 || h < 0) {
    stop('Triangle sides must be positive numbers.')
  }
  hypotenuse <- max(sides)
  other.sides <- sides[sides != hypotenuse]
  return(sum(other.sides**2) == hypotenuse**2)
}
