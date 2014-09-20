# Week 4 Quiz
# Paul Garaud

# set up
require(ggplot2)

data(movies)
df <- movies

#### Q1 ####
df['decade'] <- sapply(df[['year']] / 10, floor)
df['decade']  <- df['decade'] * 10

# to look at numbers prior to graphing
# sum.by.decade <- aggregate(title ~ decade, data = df, FUN = length)
# names(sum.by.decade)[2] <- 'title.count'

movie.count.graph <- ggplot(data = df, aes(x = factor(decade)))
movie.count.graph + geom_bar(width = .5) + labs(list(title = 'Movie Count By Decade',
                                            x = 'Decade',
                                            y = 'Count'))

#### Q2 ####
# build rating weight by genre (ie, movie votes / genre votes)
for (genre in names(df[,18:24])) {
  genre.votes <- sum(df[df[genre] == 1, ][,'votes'])
  df[paste(genre, 'w.rating', sep='.')] <- ifelse(df[[genre]] == 1, 
                                                df$rating * df$vote / genre.votes, 0)
}

weighted.ratings <- apply(df[, 26:32], 2, sum)
require(stringr)
genres <- factor(str_replace(names(weighted.ratings), '[.].*$', ''))
ratings.by.genre <- ggplot(data = data.frame(Genre = genres, weighted.ratings),
                           aes(x = genres, y = weighted.ratings))
ratings.by.genre + geom_bar(stat='identity', width = .25) +
  labs(list(title = 'Vote-Weighted Mean Rating By Genre', x = 'Genres', 
            y = 'Mean Rating'))

# how have ratings changed over time?
require(reshape2)
melted <- melt(data = movies, id.vars = names(movies[, c(1:2, 5:6)]), 
               measure.vars = names(movies[18:24]),
               variable.name = 'genre', value.name = 'YesNo')
melted <- melted[melted$YesNo != 0, -6]
ratings.over.time <- aggregate(rating ~ genre + year, data = melted, mean)

ratings.genre.time <- ggplot(data = ratings.over.time,
                             aes(year, rating, 
                                 group = genre,
                                 color = genre))
ratings.genre.time +  scale_color_brewer(palette='BuGn') +
  stat_smooth(se=FALSE, size = 1, alpha = .5) +
  theme(panel.background = element_rect(fill = 'seashell3'),
        panel.grid.major = element_line(colour = 'peachpuff4'), 
        panel.grid.minor = element_blank())

# Action and Romance films have decreased in popularity, while 
# Documentaries and Short films have become more popular
# (Of course, the reviews for old films are done *today*, so
# really I suppose this data is saying that people today like
# Action and Romance films of old.)

#### Q3 ####
length.rating <- ggplot(data = df, aes(length, rating))
length.rating + geom_point(color = 'darkgreen', alpha = .1) + 
  scale_x_log10() + ggtitle('Movie Rating v Length')

# Uh oh, is there really a movie 83 hours long!? Apparently, not an outlier
# There doesn't appear to be a straightforward relationship b/w length
# and rating at first cut

#### Q4 ####
# We need length in melted 
melted <- merge(melted,
               df[, c('title', 'year', 'rating', 'length', 'votes')], 
               by = c('title', 'rating', 'votes', 'year'))

length.genre <- ggplot(data = melted, aes(genre, log(length), group = genre))
length.genre + geom_violin(fill = 'aquamarine', linetype = ) + ylab('ln(length)')

# We see a clear pattern in the distributions of movie lengths, once
# some helpful transformations are applied. The Animation distribution 
# appears bimodal, though clustered around short lengths. Perhaps unsurprisingly,
# Romance and Drama movies appear to have similar distributions of lengths.
# 90 minutes appears to be the sweetspot for most genres.

#### Q5 ####
# examine relationships in scatterplot matrix format
pairs(~ votes + year + rating + length, data = melted)

melted['genre'] <- factor(melted$genre)
melted <- within(melted, genre <- relevel(genre, ref = 'Drama'))

# drama is reference category for genre dummy variables
first.pass <- lm(votes ~ year + rating + length + genre, data = melted)  
summary(first.pass)

var.with.max.F <- NULL
for (var in names(melted)[c(-1, -3)]) {
  lm1 <- first.pass  # full model
  lm2 <- lm(votes ~ ., data = melted[, c(-1, -which(names(melted) == var))])
  out <- anova(lm2, lm1)
  var.with.max.F[var] <- out$F[2]
}

# It looks like length is the winner (has biggest impact on explained variance
# of votes when omitted), but rating is a close second

# What I would like to have done (but I don't have the time for it):
# 1. split data into training & validation sets
# 2. run a lasso or ridge regression, using the validation set to help me
#    select which subset of variables and regularization term
# 3. out of the selected model, look at the change in prediction accuracy
#    for leaving each variable out in turn and choose the one with the
#    largest effect on accuracy.
# IN other words, actually test impact on accuracy rather than rely on linear models