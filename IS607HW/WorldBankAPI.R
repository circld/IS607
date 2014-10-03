# Data science context: API program
# Paul Garaud

# Example usage
# df <- get.data(c('DE', 'FR', 'CHN'), 'SP.POP.TOTL', date='2000:2009')
# df <- get.data(c('DE', 'FR', 'CHN'), 'DPANUSSPF', MRV=5, frequency='M')

require(XML)
require(stringr)

# API base url (for country requests)
wb.url <- 'http://api.worldbank.org/en/countries/'

# First crack: simplest working case
get.data <- function(ctry, data, ...){
  query.url <- build.url(ctry, data, ...)
  df <- xmlToDataFrame(readLines(query.url, warn = FALSE))
}


# Helper function

# Combine parameters into URL string
build.url <- function(ctry, var, ...) {
  params <- list(...)
  param.names <- names(params)
  for (name in param.names) {
    params[[name]] <- str_c(name, '=', params[[name]])
  }
  out <- str_c(wb.url,
               str_c(ctry, collapse = ';'),
               '/indicators/', var, '?',
               str_c(as.character(params), collapse = '&'),
               '&format=xml')
}
