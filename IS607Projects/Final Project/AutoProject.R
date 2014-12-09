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
require(xlsx)
require(stringr)
require(tidyr)
require(dplyr)
require(lubridate)

#### Data acquisition ####

# Getting Auto sales data (millions of units)
fred.url <- 'http://research.stlouisfed.org/fred2/series/TOTALSA/downloaddata'
fred.query <- list('form[native_frequency]' = 'Monthly', 
                   'form[units]' = 'lin',
                    'form[frequency]' = 'Monthly', 'form[obs_start_date]' = "1976-01-01",
                    'form[obs_end_date]' = "2014-11-01", 'form[file_format]' = 'txt',
                    'form[aggregation]' = 'Average',
                    sep = '&')
fred.response <- POST(fred.url, body = fred.query)
fred.con <- textConnection(content(fred.response, 'text'))
fred.data <- read.table(fred.con, header = TRUE, sep = "", skip = 10, 
                        stringsAsFactors = FALSE)

rm(list = c('fred.query', 'fred.response', 'fred.con'))

# Getting GDP data (download file + read in using xlsx package)
nber.url <- 'http://www.nber.org/cycles/BCDCFiguresData100920_ver5.xlsx'
nber.dir <- choose.dir(caption = 'Select directory in which to save NBER data.')
nber.loc <- str_c(nber.dir, '\\NBER_data.xlsx')
download.file(nber.url, nber.loc, mode = 'wb')
nber.data <- read.xlsx(nber.loc, sheetIndex = 2, startRow = 2)

rm(list = c('nber.dir', 'nber.loc'))


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
                  from_year = 1976,
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

#### Data Munging ####

# only have complete series in all datasets for 1/1/1976 - 6/1/2010, inclusive
# FRED
fred.data <- fred.data[fred.data$DATE <= '2010-06-01', ]
names(fred.data) <- c('Month', 'SalesM')
fred.data$Month <- ymd(fred.data$Month)  # Month to posix

# NBER
nber.data <- nber.data[nber.data$Month.Year >= '1976-01-01' &
                         nber.data$Month.Year <= '2010-06-01',
                       c(1, 3)]
names(nber.data) <- c('Month', 'RGDP')
nber.data$Month <- ymd(nber.data$Month)  # Month to posix

# BLS
# Create single Month column
names(bls.data) <- c('Year', '01', '02', '03', '04', '05', '06', '07', '08',
                     '09', '10', '11', '12')
bls.data <- bls.data %>% gather(MonthNum, Unemployment, -Year) %>%
  unite_('Month', c('Year', 'MonthNum'), sep = '-')
bls.data$Month <- str_c(bls.data$Month, '-01')
by.month <- order(bls.data$Month)
bls.data <- bls.data[by.month, ]
rm(by.month)

# limit date range
bls.data <- bls.data[bls.data$Month <= '2010-06-01', ]
bls.data$Month <- ymd(bls.data$Month)  # Month to posix

# Merge data into single dataset
data <- Reduce(function(...) merge(..., all = TRUE), 
               list(fred.data, nber.data, bls.data))

rm(bls.data, nber.data, fred.data)

# Reshape dataset to include lagged variables













