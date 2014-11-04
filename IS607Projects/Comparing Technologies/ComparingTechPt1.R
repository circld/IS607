# Project: Comparing Technologies
# Paul Garaud

# original data available at: 
# http://stats.oecd.org/Index.aspx?DataSetCode=BLI#

# Part 2: Bring the data into R

require(dplyr)
require(tidyr)
require(stringr)


#### Importing data ####
data.location <- file.choose()
blf.df <- tbl_df(read.table(data.location, header = TRUE, sep = ',', 
                            stringsAsFactors = FALSE))


#### Munging data ####

# will use Indicator values as col names, so need to remove whitespace
blf.df$Indicator <- str_replace_all(blf.df$Indicator, '[[:blank:]]', '.')

# observation at country-level, so better suited as 'wide' dataset
blf.wide <- blf.df %>% filter(Inequality != 'High', Inequality != 'Low') %>%
  select(-Measure, -Time, -Flags, Country, 
         Gender = Inequality, Indicator:Value) %>%
  spread(key = Indicator, value = Value) %>%
  arrange(Country) %>%
  tbl_df()

# Reassign Total to Both to better align with variable name (ie, Gender)
blf.wide[blf.wide$Gender == 'Total', 'Gender'] <- 'Both'
blf.wide$Gender <- factor(blf.wide$Gender)

#### Detailed description of dataset ####
# blf.wide contains various quality-of-life indicators by country and sex.
# For each country, there are three rows: indicator data for men, women, &
# both genders. The 24 indicator variables are all numeric and range across 
# Housing,Income, Jobs, Community, Education, Environment, Civic Engagement, 
# Health, & Life Satisfaction.
