# IS607 Neo4j project
# Paul Garaud


# Install/load RNeo4j
if (!require(RNeo4j)) {
  devtools::install_github("nicolewhite/RNeo4j")
} else {
  require(RNeo4j)
}

# Load R data (exchange rate data)
df <- data.frame(euro.cross)

# Initialize graph object (in *currently loaded & running neo4j db*)
db.loc <- 'http://localhost:7474/db/data/'
graph.df <- startGraph(db.loc)

# Clear existing data
clear(graph.df)

# Add Nodes
currencies <- rownames(df)
currency.nodes <- list()
for (cur in currencies) {
  eval(parse(text = paste(cur, '<- createNode(graph.df, name ="', 
                          cur, '")', sep='')))
  eval(parse(text = paste('addLabel(', cur, ', "Currency")', sep='')))
}

# Add Relationships (i went a bit overboard trying to avoid loops...)
lapply(currencies, function(cur) lapply(
  currencies, function(cur2) if (df[cur, cur2] != 1) createRel(
    eval(parse(text=cur)), 'CONVERT_TO', 
    eval(parse(text=cur2)), rate=df[cur, cur2])))

# query Neo4j graph

# match (from:Currency)-[r]->(to:Currency)
# where from.name in ['ESP', 'PTE'] and to.name in ['ESP', 'PTE']
# return from.name as from, r.rate as rate, to.name as to;

# Advantages/Disadvantages of storing this data in a graph db

# Pros: This is a fairly trivial set of data to use in a graph db, so there
# aren't really any advantages besides being able to visualize the relationships
# between the curruencies. These data do really require multiple traversals and
# since it's a complete graph, multiple traversals would be pointless anyways.
# The data are not large enough to require horizontal scaling that Neo4j can
# provide either. Given that these data would be used in pairs of values for
# currency conversion purposes, and given that currencies are more or less
# finite in number, a relational database solution would have been a better
# storage option here.

# Cons: adding/modifying the data is a bit more involved than in a relational
# database. Given that the data are uniform, the rigidity of a schema works
# and its attendant advantages does not really have any downsides in this
# situation. As some have pointed out, relational databases should be the
# the default choice in a majority of use cases due to its stability, ACID
# properties, established feature set, etc. Thus, the main disadvantage of
# using a graph database for these data is simply that it is unnecessary--it
# fails to exploit the advantages of graph databases while forgoing the many
# advantages of a relational database solution.
