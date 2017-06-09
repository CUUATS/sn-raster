#island.R
#This script detect island of score of 1 and 2
#by Edmond Lai - CUUATS Sustainable Neigborhood

library(raster)
library(rgdal)
library(rgeos)
library(sp)

#Set the path to the Score TIF file 

setwd("L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood")

score <- raster("scoreALL 100.TIF")

#Detect Island of activities
#Score 1 and 2 cluster
score[score == 3 | score == 4] <- NA
c.score12 <- clump(score, directions = 4)
plot(c.score12, main = "Island of score of 1 and 2")
writeRaster(c.score12, "score12.tif",overwrite=TRUE)
