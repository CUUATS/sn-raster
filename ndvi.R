#nvdi.r
#This script calculate ndvi index from satellite image for the study area
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(rgdal)
library(rgeos)
library(sp)

sourceDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/champaignLandSat8/"
resultDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Result/"
crs <- crs("+init=ESRI:102671")
setwd(resultDir)
scoreALL <- raster("ScoreALL100.tif")


setwd("G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/champaignLandSat8/")
#import satellite image
b4 <- raster("B4crop.tr_20160912.tif")
b5 <- raster("B5crop.tr_20160912.tif")

#Calculate vegetation index
NDVI = (b5-b4) / (b5+b4)
NDVI = projectRaster(from=NDVI, to=scoreALL)
plot(NDVI, main="NDVI")

setwd(resultDir)
writeRaster(NDVI, "NDVI.tif", format = "GTiff", overwrite=TRUE)


#vegetation area
NDVI.veg <- raster(ext=extent(NDVI), res=res(NDVI), crs=crs(NDVI))
veg <- NDVI > .3
NDVI.veg[veg] <- -.5
NDVI.veg[is.na(NDVI.veg)] <- 0

scoreALL[scoreALL==0] <- NA

writeRaster(NDVI.veg, "ndviVeg.tif", format="GTiff", overwrite=TRUE)

crs(scoreALL) <- crs

canopy = scoreALL + NDVI.veg

plot(canopy)
writeRaster(canopy, "canopy.tif", format="GTiff", overwrite=TRUE)

