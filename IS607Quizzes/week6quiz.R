# week6quiz.R
# Paul Garaud

# [For your convenience], here is the provided code from Jared Lander's R for Everyone, 
# 6.7 Extract Data from Web Sites

# install.packages("XML")
require(XML)
theURL <- "http://www.jaredlander.com/2012/02/another-kind-of-super-bowl-pool/"
bowlPool <- readHTMLTable(theURL, which = 1, header = FALSE, stringsAsFactors = FALSE)
bowlPool

#### 1. ####
# What type of data structure is bowlpool?
class(bowlPool)
# data.frame

#### 2. ####
# Suppose instead you call readHTMLTable() with just the URL argument,
# against the provided URL, as shown below

theURL <- "http://www.w3schools.com/html/html_tables.asp"
hvalues <- readHTMLTable(theURL)

# What is the type of variable returned in hvalues?
class(hvalues)
# list

#### 3. ####
# Write R code that shows how many HTML tables are represented in hvalues
# since readHTMLTable was not called with the which arg, 
# all tables are returned
length(hvalues)
# 7 tables are contained in hvalues

#### 4. ####
# Modify the readHTMLTable code so that just the table with Number, 
# FirstName, LastName, # and Points is returned into a dataframe
FirstTable <- readHTMLTable(theURL, which = 1)

#### 5. ####
# Modify the returned data frame so only the Last Name and Points columns are shown.
LN.Pts <- FirstTable[, c('Last Name', 'Points')]

#### 6. ####
# Identify another interesting page on the web with HTML table values.  
# This may be somewhat tricky, because while
# HTML tables are great for web-page scrapers, many HTML designers now prefer 
# creating tables using other methods (such as <div> tags or .png files).  
new.URL <- 'http://catalog.data.gov/dataset/consumer-complaint-database'
about.dataset.table <- readHTMLTable(new.URL, which = 1)
names(about.dataset.table) <- c('InfoType', 'Info')

#### 7. ####
# How many HTML tables does that page contain?
length(readHTMLTable(new.URL))
# 1

#### 8. #### 
# Identify your web browser, and describe (in one or two sentences) 
# how you view HTML page source in your web browser.
# Chrome Version 37.0.2062.124; to view the html source, you can simply right-click on the
# webpage in question and select 'View page source'.