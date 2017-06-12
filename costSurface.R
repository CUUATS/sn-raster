#costSurface.R
#This script calculates with cost surface using the score layer generated previously 
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(gdistance)
library(rgdal)

path.fgdb <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"
layerName <- c("grocery_stores", "park_rec", "emp_center", "service_business")
resultDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Result/"

setwd(resultDir)
score <- raster("scoreRTL_Med100.TIF")

score <- score * 2
score[score==0] <- 20

tr1 <- transition(score, function(x) 1/mean(x), direction=4)
tr1C <- geoCorrection(tr1)


for (i in 1:length(layerName)) {
  layer <- readOGR(dsn=path.fgdb, layer=layerName[i])
  layer_cost <- accCost(tr1C, layer)
  plot(layer_cost, main=layerName[i])
  file_name <- layerName[i]
  writeRaster(layer_cost, file_name, format="GTiff", overwrite=TRUE)
}

groceryStores_cost <- accCost(tr1C, groceryStores)

writeRaster(groceryStores_cost, "groceryStore_scores.tif", format="GTiff", overwrite=TRUE)
