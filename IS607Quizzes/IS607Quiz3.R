# Quiz 3
# Paul Garaud

#### Q1 ####
calc.mean <- function(numVect) {
  if (class(numVect) != 'numeric') stop('Numeric vector argument required.')
  return(mean(numVect))
}

#### Q2 ####
calc.mean2 <- function(numVect) {
  if (class(numVect) != 'numeric') stop('Numeric vector argument required.')
  return(mean(numVect, na.rm = TRUE))
}

#### Q3 ####

# helper function to derive prime factors of a number
prime.fact <- function(num) {
  
  pfactors <- c(1)
  num.mod <- num
  max.div <- floor(num / 2)
  
  # handle num = 1 & num = 3 cases
  if(num != 1 && max.div == 1) {
    return(c(pfactors, num))
  } else if (num == 1) {
    return(num)
  }
  for (div in 2:max.div) {
    while(num.mod %% div == 0) {
      pfactors <- c(pfactors, div)
      num.mod <- num.mod / div
    }
    if(num.mod < div) {
      if(num.mod != 1) pfactors <- c(pfactors, num.mod)
      break
    }
  }
  if(length(pfactors) == 1) return(c(pfactors, num))
  return(pfactors)
}

# Find Greatest Common Factor of arbitrary number of positive integers
LCF <- function(...) {
  
  # test that arguments are legal
  arg.not.num <- lapply(list(...), FUN=function(x) class(x) != 'numeric')
  if (TRUE %in% arg.not.num) stop('All arguments must be numeric.')
  # create numeric vector and list of primes for each
  inputs <- c(...)
  input.primes <- lapply(inputs, prime.fact)
  # find common primes
  temp.primes <- c()
  common.primes <- c()
  # grab all occurring primes
  for (plist in input.primes) {
    temp.primes <- c(temp.primes, c(plist))
  }
  # limit loop to unique primes
  temp.primes <- unique(temp.primes)
  
  # loop over temp.primes to test for commonality
  for (prime in temp.primes) {
    if (prime == 1) next
    freq <- 0
    is.common <- TRUE
    for (plist in input.primes) {
      if (!(prime %in% plist)) {
        is.common <- FALSE
        break
      } else if (freq == 0 || length(plist[plist == prime]) < freq) {
        freq <- length(plist[plist == prime])
      } 
    }
    if (is.common) common.primes <- c(common.primes, rep(prime, freq))
  }
  
  return(prod(common.primes))
}

#### Q4 ####
# Euclidean Algo
euclid.factors <- function(...) {
  
  # test that arguments are legal
  arg.not.num <- lapply(list(...), FUN=function(x) class(x) != 'numeric')
  if (TRUE %in% arg.not.num) stop('All arguments must be numeric.')
  # create numeric vector and list of primes for each
  inputs <- sort(c(...))
  
  # base case
  if (length(inputs) == 2) {
    bigger <- inputs[2]
    smaller <- inputs[1]
    while (bigger > 1 && smaller > 1) {
      while (bigger - smaller > 1) { 
        bigger <- bigger - smaller
      }
      if (bigger == smaller) {
        return(bigger)
      } else if (bigger - smaller == 1) {
        return(1)
      }
      temp.big <- bigger
      temp.small <- smaller
      bigger <- max(temp.big, temp.small)
      smaller <- min(temp.big, temp.small)
    }
  }
  
  # recursive call
  return(euclid.factors(inputs[1], euclid.factors(inputs[-1])))
}

#### Q5 ####
quad.func <- function(x, y) {
  return(x**2 * y + 2 * x * y - x * y**2)
}

#### Q6 ####
# set directory
base.dir <- getwd()
try(setwd(file.path(base.dir, 'IS607Quizzes')), silent = TRUE)

price.data <- read.table('week-3-price-data.csv', sep=',', header = TRUE)
make.data <- read.table('week-3-make-model-data.csv', sep=',', header = TRUE)

require(data.table)
price.dt <- data.table(price.data, key = 'ModelNumber')
make.dt <- data.table(make.data, key = 'ModelNumber')
price.make <- merge(price.dt, make.dt)
nrow(price.make)
# 27; expected 28 since 28 rows in price.dt; suggests ModelNumber in make.dt
# not in price.dt

#### Q7 ####
price.make2 <- merge(price.dt, make.dt, all = TRUE)
nrow(price.make2)  # 28

#### Q8 ####
price.make2010 <- subset(price.make2, Year == '2010')

#### Q9 ####
red.price <- subset(price.make2, Color == 'Red' & Price > 10000)

#### Q10 ####
no.MN.Color <- red.price[, c(-1, -3), with = FALSE]

#### Q11 ####
char.count <- function(x) {
  if (class(x) != 'character') {
    stop('Argument must be a character vector')
  }
  return(sapply(x, function(y) length(strsplit(y, "")[[1]])))
}

#### Q12 ####
require(stringr)
concat <- function(char.v1, char.v2) {
  if (length(char.v1) != length(char.v2)) {
    stop('Character vectors must have the same length.')
  }
  return(str_c(char.v1, char.v2, sep = ' '))
}

#### Q13 ####
# can use ignore.case(regex) in stringr functions to ignore case as well
vowel3 <- function(char.vect) {
  str_extract(char.vect, perl("(?i)[aeiou].{2}"))
}

#### Q14 ####
set.seed(333)
month <- floor(runif(10, 1, 13))
day <- floor(runif(10, 1, 31))  # who needs the 31st anyways?
year <- floor(runif(10, 2000, 2015))
date.df <- data.frame(cbind(month, day, year))

# add col with date in date format
require(lubridate)
full.dates <- str_c(month, day, year, sep='-')
date.df['date'] <- mdy(full.dates) 
class(date.df$date)  # "POSIXct" "POSIXt"

#### Q15 ####
# lubridate already imported
rand.date <- mdy('07-28-1900')
weekdays(rand.date)  # apparently 7-28-1900 was a Saturday

#### Q16 ####
# for numerical representation of month, simply month(rand.date)
as.character(month(rand.date, label = TRUE, abbr = TRUE))  # "Jul"

#### Q17 ####
start.day <- as.Date(mdy('January 1, 2005'))
end.day <- as.Date(mdy('December 31, 2014'))
interval.days <- seq.Date(from = start.day, to = end.day, by = 'day')
