#From the help page: http://docs.ggplot2.org/current/geom_map.html

rm(list=ls(all=TRUE))
ids <- factor(c("1.1", "2.1", "1.2", "2.2", "1.3", "2.3"))

dsValue <- data.frame(
  CountyID = ids,
  value = c(3, 3.1, 3.1, 3.2, 3.15, 3.5)
)

dsLocation <- data.frame(
  id = rep(ids, each = 4),
  x = c(2, 1, 1.1, 2.2, 1, 0, 0.3, 1.1, 2.2, 1.1, 1.2, 2.5, 1.1, 0.3, 0.5, 1.2, 2.5, 1.2, 1.3, 2.7, 1.2, 0.5, 0.6, 1.3),
  y = c(-0.5, 0, 1, 0.5, 0, 0.5, 1.5, 1, 0.5, 1, 2.1, 1.7, 1, 1.5, 2.2, 2.1, 1.7, 2.1, 3.2, 2.8, 2.1, 2.2, 3.3, 3.2)
)

ggplot(dsValue) + geom_map(aes(map_id = CountyID), map = dsLocation, color="red") +
  expand_limits(dsLocation)
# 
# 


ggplot(dsValue, aes(fill = value)) +
  geom_map(aes(map_id = CountyID), map = dsLocation) +
  expand_limits(dsLocation)
