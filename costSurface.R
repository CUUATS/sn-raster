#costSurface.R
#This script calculates with cost surface using the score layer generated previously 
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(gdistance)

setwd("L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood")
score <- raster("scoreALL 100.TIF")

score <- score * 2
score[score==0] <- 10

tr1 <- transition(scoretest, function(x) 1/mean(x), direction=4)
tr1C <- geoCorrection(tr1)

C <- c(1000000,1260000)
U <- c(1030000,1250000)

A <- accCost(tr1C, C)
B <- accCost(tr1C, U)
AB <- overlay(A,B, fun=min)

writeRaster(AB, "AB.tif", format="GTiff", overwrite=TRUE)