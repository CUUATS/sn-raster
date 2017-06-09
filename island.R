#island.R
#This script detect island of score of 1 and 2
#by Edmond Lai - CUUATS Sustainable Neigborhood


#Set the path to the Score TIF file 
wd <- "L:\Sustainable Neighborhoods Toolkit\scripts\SustainableNeighborhood\"

setwd(wd)

score <-sfsfs

#Detect Island of activities
#Score 1 and 2 cluster


score12 <- score.Comb.RLT.LTL
score12[score12 == 3 | score12 == 4] <- NA
plot(score12)
c.score12 <- clump(score12, directions = 8)
plot(c.score12, main = "Island of score of 1 and 2")
writeRaster(c.score12, "score12.tif",overwrite=TRUE)
