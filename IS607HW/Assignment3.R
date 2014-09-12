# Assignment 3
# Paul Garaud

#### Q1 ####
count.NA <- function(x) {
  if (length(x) <= 1) stop('This is not a valid vector.')
  return(sum(sapply(x, is.na)))
}

#### Q2 ####
column.NA <- function(df) {
  return(apply(is.na(df), 2, sum))
}

#### Q3 ####
# calc.summary() is the function the question is asking for

# helper functions
calc.atomic <- function(x) {
  min <- max <- sum <- n <- NULL
  for (i in x) {
    if (class(min) == 'NULL') {
      min <- max <- sum <- i
    } else {
      sum <- sum + i
      if (i < min) min <- i
      if (i > max) max <- i
    }
  }
  return(c(min = min, max = max, sum = sum))
}

calc.SD <- function(y, mean) {
  sum <- NULL
  for (j in y) {
    if (class(sum) == 'NULL') {
      sum <- j
    } else {
      sum <- sum + (j - mean)**2
    }
  }
  return(sqrt(sum / length(y)))
}

calc.quarts <- function(z) {
  n <- length(z)
  sorted <- sort(z)
  index1 <- ceiling(n / 4)
  index2 <- ceiling(n / 2)
  index3 <- ceiling(3 * n / 4)
  return(c(q1 = sorted[index1], q3 = sorted[index3], median = sorted[index2]))
}

# Q3 function
calc.summary <- function(vect) {
  atomic <- calc.atomic(vect)
  mean <- atomic[['sum']] / length(vect)
  SD <- calc.SD(vect, mean)
  quarts <- calc.quarts(vect)
  out <- list(min = atomic[['min']],
              max = atomic[['max']],
              mean = mean,
              first.quart = quarts[['q1']],
              median = quarts[['median']],
              third.quart = quarts[['q3']],
              Std.Dev = SD,
              NAs = count.NA(vect)
              )
  return(out)
}

#### Q4 ####
# character: # distinct vals, mode, mode #, NA (error handling)
char.summary <- function(vect) {
  # ties in most frequently occurring defaults to first value in vector
  if (length(vect) <= 1 ||
        (!is.character(vect) &&
        !is.factor(vect))) {
    stop('Argument must be a character or factor vector.')
  }
  unique.vals <- unique(vect)
  distinct <- length(unique.vals)
  mode <- NULL
  count <- 0
  for (val in unique.vals) {
    num.val <- ifelse(is.na(val), sum(is.na(vect)), length(na.omit(vect[vect == val])))
    if (num.val > count) {
      count <- num.val
      mode <- val
    }
  }
  return(list(unique = distinct,
              most.occurring = mode,
              num.times = count,
              NAs = count.NA(vect)))
}

#### Q5 ####
# logical: # TRUE, # FALSE, # TRUE / # FALSE, NAs
bool.summary <- function(vect) {
  if (length(vect) <= 1 || !is.logical(vect)) {
    stop('Argument must be a logical vector.')
  }
  vect.clean <- na.omit(vect)
  t.count <- sum(vect.clean)
  f.count <- abs(length(vect.clean) - t.count)
  tf.prop <- t.count / (t.count + f.count)
  return(list(num.true = t.count,
         num.false = f.count,
         proportion.true = tf.prop,
         NAs = count.NA(vect)))
}

#### Q6 ####
df.summary <- function(df) {
  info <- apply(df, 2, function(x) switch(class(x),
                                          'numeric' = calc.summary(x),
                                          'character' = char.summary(x),
                                          'factor' = char.summary(x),
                                          'logical' = bool.summary(x)))
  return(info)
}