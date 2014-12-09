# What is the primary driver of auto sales, economic growth or employment?
# Auto data:
# http://research.stlouisfed.org/fred2/series/TOTALSA/downloaddata
# GDP: 
# http://www.nber.org/cycles/BCDCFiguresData100920_ver5.xlsx
# Unemployment rate:
# http://data.bls.gov/timeseries/LNS14000000

# Linear regression (benchmark)
# Random Forests (final model)

require(httr)
require(XML)
require(stringr)

# Data acquisition

# Getting Auto sales data


# Getting GDP data


# Getting BLS data directly from the BLS website
bls.url <- 'http://data.bls.gov/timeseries/LNS14000000/pdq/SurveyOutputServlet'
bls.query <- list(request_action = 'get_data',
                  reformat = 'true',
                  from_results_page = 'false',
                  years_option = 'specific_years',
                  delimiter = 'comma',
                  output_type = 'default',
                  output_view = 'data',
                  to_year = 2014,
                  from_year = 1948,
                  output_format = 'text',
                  original_output_type = 'default',
                  annualAveragesRequested = 'false',
                  include_graphs = 'false'
                  )
bls.response <- GET(bls.url, query = bls.query, encode = 'form')
bls.html <- htmlTreeParse(readBin(bls.response$content,
                                  'text'), 
                          useInternalNodes = TRUE)
bls.raw <- xpathApply(bls.html, "//div/pre", xmlValue)
bls.con <- textConnection(str_replace_all(as.character(bls.raw),
                          'Â', ''))
bls.data <- read.csv(bls.con, skip = 11)
bls.data <- bls.data[,c(-length(names(bls.data)))]  # get rid of 'X' col

rm(list = c('bls.query', 'bls.response', 'bls.html', 'bls.raw', 'bls.con'))
