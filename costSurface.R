#costSurface.R
#This script calculates with cost surface using the score layer generated previously 
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(gdistance)
library(rgdal)

path.fgdb <- "G:/CUUATS/Local Accessibility and Mobility Analysis/Data/LocalAccessibilityAndMobilityAnalysis.gdb"
layerName <- "grocery_stores"


+setwd("L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood")
score <- raster("scoreALL 100.TIF")

score <- score * 2
score[score==0] <- 20

tr1 <- transition(scoretest, function(x) 1/mean(x), direction=4)
tr1C <- geoCorrection(tr1)

groceryStores <- readOGR(dsn=path.fgdb, layer=layerName)

groceryStores_cost <- accCost(tr1C, groceryStores)

writeRaster(groceryStores_cost, "groceryStore_scores.tif", format="GTiff", overwrite=TRUE)
