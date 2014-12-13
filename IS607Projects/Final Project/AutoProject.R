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
require(zoo)
require(ggplot2)
require(caret)
require(randomForest)
require(doParallel)

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
  unite_('Month', c('Year', 'MonthNum'), sep = '-') %>% arrange(Month)
bls.data$Month <- str_c(bls.data$Month, '-01')

# limit date range
bls.data <- bls.data[bls.data$Month <= '2010-06-01', ]
bls.data$Month <- ymd(bls.data$Month)  # Month to posix

# Merge data into single dataset
data <- Reduce(function(...) merge(..., all = TRUE), 
               list(fred.data, nber.data, bls.data))

rm(bls.data, nber.data, fred.data)

# create lags for each variable
data.ts <- read.zoo(data)
for (lag in 1:3) {
  data[, c(str_c('L', lag, 'SalesM'),
           str_c('L', lag, 'RGDP'), 
           str_c('L', lag, 'Unemployment'))
       ] <- stats::lag(data.ts, -lag, na.pad = TRUE)  # avoid dplyr::lag
}

rm(data.ts)

# remove rows with NA
data <- na.omit(data)

rownames(data) <- data$Month
data <- data[, -c(1, 3, 4)]  # remove Month column (since in rownames)

#### Analysis ####

# split data into train and test samples
n <- dim(data)[1]
in.test <- seq(n - (n %/% 10 * 2), n)  # integer division
test <- data[in.test, ]
train <- data[-in.test, ]

linear <- lm(SalesM ~ ., data = train)

rm(list = c('n', 'in.test'))

# performance

MSE <- function(actual, pred) {
  error <- actual - pred
  return(sum(error**2) / length(error))
}

SE_bounds <- function(pred, se) {
  return(list(upper = pred + 1.96 * se, lower = pred - 2*se))
}

# linear regression (benchmark)
linfit <- predict(linear, newdata = test, se.fit = TRUE)
lm.pred <- data.frame(date = rownames(data), actual = data$SalesM, 
                      predicted = c(rep(NA, dim(data)[1] - length(linfit$fit)), 
                                    linfit$fit),
                      se_l = c(rep(NA, dim(data)[1] - length(linfit$fit)),
                               SE_bounds(linfit$fit, linfit$se.fit)$lower),
                      se_u = c(rep(NA, dim(data)[1] - length(linfit$fit)),
                               SE_bounds(linfit$fit, linfit$se.fit)$upper))
print(paste('Linear Model MSE:', round(MSE(test$SalesM, linfit$fit), 2)))

tick.dates <- c('1976-04-01', '1980-01-01', '1985-01-01', '1990-01-01',
                '1995-01-01', '2000-01-01', '2005-01-01', '2010-01-01')
ggplot(lm.pred, aes(x = date, y = actual)) + geom_point(alpha = .7) + 
  geom_point(aes(y = predicted), color = 'red', alpha = .7) +
  scale_x_discrete(breaks = tick.dates) + 
  geom_smooth(aes(y = predicted, ymin = se_l, ymax = se_u, group = 1), 
              , color = 'red', linetype = 0 , stat = 'identity') +
  labs(title = 'Linear model actual (black) and predicted (red) sales', x = 'Month', 
       y = 'Auto Sales (m)')


# random forests
# Explicitly register clusters to work with caret
# See: http://stackoverflow.com/questions/24786089/parrf-on-caret-not-working-for-more-than-one-core
cl <- makePSOCKcluster(4)
clusterEvalQ(cl, library(foreach))
registerDoParallel(cl)

# using 10-fold CV train/test sets
randForest <- train(SalesM ~ ., data = train, method = 'rf',
                    trControl = trainControl(method = 'cv', number = 10),
                    prox = TRUE, allowParallel = TRUE, importance = TRUE)
rf.fit <- predict(randForest, test)
print(paste('Random Forest MSE:', round(MSE(test$SalesM, rf.fit), 2)))

rf.pred <- data.frame(Month = rownames(data), actual = data$SalesM,
                      predicted = c(rep(NA, dim(data)[1] - length(rf.fit)), 
                                        rf.fit))
ggplot(rf.pred, aes(x = Month, y = actual)) + geom_point(alpha = .7) + 
  geom_point(aes(y = predicted), color = 'red', alpha = .7) +
  scale_x_discrete(breaks = tick.dates) + 
  labs(title = 'Cross-validated Random Forest Actual (black) and predicted (red) auto sales', 
       x = 'Month', y = 'Auto Sales (m)')

# using rolling splitting for cross validation
randForest2 <- train(SalesM ~ ., data = train, method = 'rf',
                 trControl = trainControl(method = 'timeslice',
                                          initialWindow = 50,
                                          horizon = 15,
                                          fixedWindow = TRUE),
                 prox = TRUE, allowParallel = TRUE, importance = TRUE)
stopCluster(cl)
rf.fit2 <- predict(randForest2, test)
print(paste('Random Forest with time slicing MSE:',
            round(MSE(test$SalesM, rf.fit2), 2)))

rf.pred2 <- data.frame(Month = rownames(data), actual = data$SalesM,
                      predicted = c(rep(NA, dim(data)[1] - length(rf.fit2)), 
                                        rf.fit2))
ggplot(rf.pred2, aes(x = Month, y = actual)) + geom_point(alpha = .7) + 
  geom_point(aes(y = predicted), color = 'red', alpha = .7) +
  scale_x_discrete(breaks = tick.dates) + 
  labs(title = 'Time-sliced Random Forest Actual (black) and predicted (red) auto sales',
       x = 'Month', y = 'Auto Sales (m)')

# Which of these variables appear to drive auto sales?
zscore <- function(num.vect) {
  return((num.vect - mean(num.vect)) / sd(num.vect))
}
linear.scaled <- lm(SalesM ~ ., data = as.data.frame(apply(train, 2, zscore)))
rf.imp <- importance(randForest$finalModel)
rf2.imp <- importance(randForest2$finalModel)

# chart of coefficients (with SE)
lin.coef <- data.frame(summary(linear.scaled)$coefficients)[-1, ]
colnames(lin.coef) <- c('Est', 'SE', 't', 'p-val')
lin.coef$Est <- abs(lin.coef$Est)
# reorder variables for visual clarity
new.order <- c('L1SalesM', 'L2SalesM', 'L3SalesM', 
               'L1RGDP', 'L2RGDP', 'L3RGDP', 
               'L1Unemployment', 'L2Unemployment', 'L3Unemployment')
ggplot(lin.coef, aes(x = rownames(lin.coef), y = Est)) + 
  geom_pointrange(stat='identity', 
                  aes(ymax = SE_bounds(lin.coef$Est, lin.coef$SE)[[1]], 
                      ymin = SE_bounds(lin.coef$Est, lin.coef$SE)[[2]])) +
  labs(title = 'Linear model coefficients',
       x = 'Variable', y = 'Magnitude (abs. value) & precision') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_discrete(limits = new.order)

print(rf.imp[order(rf.imp[,1], decreasing = TRUE),])
print(rf2.imp[order(rf2.imp[,1], decreasing = TRUE),])

# what is the predicted volume of auto sales this month (December 2014)
# according to these models?
# Note: Stock-Watson RGDP figures not available post-2010, used assumed
# numbers below (random forest models not particularly sensitive to GDP)
new.data <- list(L1SalesM = 17.5,
                 L1RGDP = 14000,
                 L1Unemployment = 5.9,
                 L2SalesM = 16.8,
                 L2RGDP = 14000,
                 L2Unemployment = 5.8,
                 L3SalesM = 16.8,
                 L3RGDP = 14000,
                 L3Unemployment = 5.8)
writeLines('\n')
print(paste('Linear model prediction:', round(predict(linear, new.data), 2)))
print(paste('Random forest naive prediction:', round(predict(randForest, new.data), 2)))
print(paste('Random forest time slice prediction:',
            round(predict(randForest2, new.data), 2)))

# ~17m cars sold in December
# my guess--overshoots, not sure these model will reflect seasonal trends