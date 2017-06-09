#costSurface.R
#This script calculates with cost surface using the score layer generated previously 
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(gdistance)
library(rgdal)

path.fgdb <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"
layerName <- "BikeIntersections"


setwd("L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood")
score <- raster("scoreALL 100.TIF")

score <- score * 2
score[score==0] <- 20

tr1 <- transition(scoretest, function(x) 1/mean(x), direction=4)
tr1C <- geoCorrection(tr1)

int <- readOGR(dsn=path.fgdb, layer=layerName)

int_cost <- accCost(tr1C, int)

writeRaster(int_cost, "int.tif", format="GTiff", overwrite=TRUE)
