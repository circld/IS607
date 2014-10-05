# Week 6 Assignment - Scraping Indeed.com
# Paul Garaud

# Example usage:
# df <- get.jobs(keywords = c('financial', 'analyst'), zip = 10001)
# df <- get.jobs(keywords = 'financial analystt', zip = 10001)


# Exclude sponsored results

get.jobs <- function(keywords, zip = NULL, sponsored = FALSE) {

  require(rvest)
  require(stringr)
  require(tidyr)
  
  # handle single string or char vector for keywords
  terms <- str_c(sapply(str_split(keywords, ' '), 
                  function(x) str_c(x, collapse = '+')),
                 collapse = '+')
  
  website <- 'http://www.indeed.com/jobs'
  website <- str_c(website, '?q=', terms)
  
  # include zip in query string
  if (!is.null(zip)) {
    website <- str_c(website, '&l=', zip)
  }

  root <- website %>% html()
  
  # exclude sponsored results
  if (!sponsored) {
    root.rows <- root %>% html_nodes('.row') %>% html_text()
    exclude <- which(str_detect(root.rows, 'Sponsored by'))
  }
  
  job.title <- root %>% html_nodes('.jobtitle') %>%
    html_text() %>% str_replace_all('(\\n|( ){2})*', '')
  
  company <- root %>% html_nodes('.company') %>%
    html_text()
  
  location <- root %>% html_nodes('.location') %>%
    html_text() %>% str_replace_all('\\n', '')
  
  posted <- root %>% html_nodes('.date') %>%
    html_text() %>% str_replace_all('s? ago', '') %>% 
    str_replace_all('30[+]', '31')

  blurb <- root %>% html_nodes('.summary') %>%
    html_text() %>% str_replace_all('\\n', '')
  
  df <- data.frame(job.title = job.title,
                   company = company,
                   location = location,
                   posted = posted,
                   blurb = blurb,
                   stringsAsFactors = FALSE)
  
  df <- df %>% separate(col = posted, into = c('posted', 'unit'), sep = ' ')
  df$posted <- as.integer(df$posted)
  
  if (!sponsored) {
    return(df[-exclude, ])
  }
  
  return(df)
} 

