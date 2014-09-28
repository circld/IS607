# IS607 Week 5 Assignment
# Paul Garaud

#### Question 1 ####
# Three questions to answer using this data

# 1. Which dish is preferred overall?
# 2. Do preferences differ between these two cities?
# 3. Do preferences differ by age, regardless of city?

#### Question 2 ####
df <- data.frame(rbind(c('Yes', 80100, 143000, 99400, 150400),
                       c('No', 35900, 214800, 43000, 207000)))
names(df) <- c('answer', 'e.16-24', 'e.25+', 'g.16-24', 'g.25+')

#### Question 3 ####
require(tidyr)
df.tidy <- gather(df, col, value, -1, convert = TRUE)
df.tidy <- separate(data = df.tidy, col = col, into = c('city', 'age'), sep = '[.]', convert = TRUE)
levels(df.tidy$city) <- c('Edinburgh', 'Glasgow')
df.tidy$value <- as.numeric(df.tidy$value)

#### Question 4 ####
require(plyr)

# 1 - Overall, Cullen skink is *not* preferred to Partan bree
dish.aggregate <- ddply(.data = df.tidy, .variables = .(answer), summarize,
                        total.votes = sum(value))

# 2 - It appears that Glaswegians seem to like the two dishes almost equally, 
# whereas Edinburghers prefer Partan bree
prefs.by.city <- ddply(.data = df.tidy, .variables = .(city),
                      mutate, total.votes = sum(value))
prefs.by.city <- ddply(.data = prefs.by.city, .variables = .(answer, city),
                       summarize, prop.votes = sum(value) / total.votes)
# why are there duplicates? 'summarize' should create new df grouped at answer-city level??
prefs.by.city <- unique(prefs.by.city[order(prefs.by.city$city), ])

# 3 - Young people generally strongly favor Cullen skink, regardless of city,
# and older people generally are a bit less strongly in favor of Partan bree,
# proportionally more older people in Edinburgh prefer Partan bree than those
# in Glasgow.
prefs.city.age <- ddply(.data = df.tidy, .variables = .(city, age),
                        mutate, total.votes = sum(value))
prefs.city.age <- ddply(.data = prefs.city.age, .variables = .(answer, city, age),
                        summarize, prop = sum(value) / total.votes)
o <- order(with(prefs.city.age, city, age))
prefs.city.age <- prefs.city.age[o & prefs.city.age$answer == 'Yes', ]

#### Question 5 ####
# Would you ask diff questions/change the way df is structured?
# I think having the dataset in the tidy format made the data transformations
# rather straightforward, and allowed the questions to be answered easily.
# In terms of questions, the data is quite limited so there are really only
# a few different combinations of columns to use, limiting the number of
# questions to ask. I didn't think of any other questions while working through
# the analysis.