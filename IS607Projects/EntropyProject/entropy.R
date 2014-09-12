# IS607 Entropy Project R file
# Paul Garaud

data <- read.table('./IS607Projects/EntropyProject/entropy-test-file.csv',
                   header=TRUE,
                   sep=',')

#### 1. entropy() ####
entropy <- function(d) {
  if (length(d) == 1 || class(d) == 'data.frame') {
    stop('Argument must be a vector.')
  }
  d <- na.omit(d)
  n <- length(d)
  total <- 0
  for (val in unique(d)) {
    p <- length(d[d == val]) / n
    total <- total + p * log2(p)
  }
  return(-total)
}

#### 2. infogain() ####
infogain <- function(d, a) {
  # ensuring argumenst are legal, ie vectors
  if (length(d) != length(a)
      || length(d) == 1
      || !is.null(dim(d))) {
    stop('Arguments must be vectors of equal length.')
  }
  ent.d <- entropy(d)
  ent.a <- 0
  
  # subset & calc entropy for subsets
  for (val in unique(a)) {
    subset <- d[which(a == val)]
    ent.a <- ent.a + length(subset) / length(a) * entropy(subset)
  }
  
  return(ent.d - ent.a)
}

#### 3. decide() ####
decide <- function(df, target) {
  if (class(df) != 'data.frame' || class(target) != 'numeric') {
    stop('Invalid arguments.')
  }
  ent.d <- entropy(df[,target])
  ent.a <- apply(df[,-target], 2, function(x) infogain(df[, target], x))
  return(list(max.attr = which(ent.a == max(ent.a)),
              info.gain = ent.a))
}