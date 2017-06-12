#island.R
#This script detect island of score of 1 and 2
#by Edmond Lai - CUUATS Sustainable Neigborhood

library(raster)
library(rgdal)
library(rgeos)
library(sp)

#Set the path to the Score TIF file 
sourceDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Result/"
resultDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Result/"
crs <- "+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"


setwd(sourceDir)
score <- raster("scoreRTL_Med100.TIF")

#Detect Island of activities
#Score 1 and 2 cluster
score[score == 3 | score == 4] <- NA
c.score12 <- clump(score, directions = 4)
plot(c.score12, main = "Island of score of 1 and 2")
crs(c.score12) <- crs
writeRaster(c.score12, "scoreIsland12.tif",overwrite=TRUE)
