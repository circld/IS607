# Week 9 Assignment
# Paul Garaud

# Part II
require('rmongodb')
require('jsonlite')
require('stringr')
require('lubridate')

# create mongo connection
mongo <- mongo.create()
mongo.is.connected(mongo)  # check connection

# db: unitedstates, collection: docs
coll <- 'unitedstates.docs'

# grab one record
mongo.find.one(mongo, coll)
# grab distinct values for a key
mongo.distinct(mongo, coll, 'abbr')

# read in data
district <- '{ "federal_district" : { "$exists" : "true" }}'
state <- '{ "state" : { "$exists" : "true" }}'
territory <- '{ "territory" : { "$exists" : "true" }}'

# validate json expressions
print(sapply(c(district, state, territory), validate))

# mongo2db
mongo2df <- function(con, coll, query) {
  raw <- mongo.find.all(con, coll, query)
  row.names(raw) <- NULL  # remove 'val' row names
  list.df <- as.data.frame(raw, stringsAsFactors = FALSE)
  names(list.df)[1] <- 'ID'
  for (name in names(list.df)) {
    # rename _id column (R doesn't like lead underscore)
    if (name == 'ID') {
      next
    }
    # convert cols from lists to respective data type vectors
    col <- str_c('list.df$', name)
    coltype <- eval(parse(text = str_c('class(', col, '[[1]])')))
    if (str_detect(name, '[dD]ate')) {
      eval(parse(text = str_c(col, ' <- mdy(', col, ')')))
    } else {
      eval(parse(text = str_c(col, '<- as.', coltype, '(', col, ')'))) 
    }
    # handle any values in JSON format
    if (eval(parse(text = str_c('class(', col, ')'))) == 'character') {
      eval(parse(text = str_c(col,
                              ' <- str_replace_all(', col, ', \'\"\', "")')))
    }
  }
  return(list.df)
}

# create dataframes
district.df <- mongo2df(mongo, coll, district)
state.df <- mongo2df(mongo, coll, state)
territory.df <- mongo2df(mongo, coll, territory)