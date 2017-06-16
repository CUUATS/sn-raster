#cleanUpSatelliteImage.R
#This script takes the LandSat 8 images, reproject and crop for study area, write out TIF file for other analysis
#by Edmond Lai - CUUATS Sustainable Neighborhood Project

library(raster)
library(rgdal)
library(rgeos)
library(sp)

setwd("G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/champaignLandSat8/")

#Set resolution
resolution = c(100,100)
date <- "20160804"

#Set path to the study area geodatabase
boundary.fgdb <- "G:/Resources/Data/Boundary.gdb"
#Read Boundary for the study area
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")
#set crs
crs <- crs("+init=ESRI:102671")


#create file names
inB4Name <- paste("LC08_L1TP_023032_20160912_20170221_01_T1_B4",".TIF", sep="")
inB5Name <- paste("LC08_L1TP_023032_20160912_20170221_01_T1_B5",".TIF", sep="")

#read satellite image and set satellite crs
b4 <- raster(inB4Name)

#transform boundary to satellite crs
UA.tr <- spTransform(UA, crs(b4))

#Set Extent for Test Area

b4 <- raster(inB4Name)
b4crop <- crop(b4, extent(UA.tr))
b4crop.tr <- projectRaster(b4crop, crs=crs, res=100)
b4agr <- b4crop.rtchan

b5 <- raster(inB5Name)
b5crop <- crop(b5, extent(UA.tr))
b5crop.tr <- projectRaster(b5crop, crs=crs, res=100)



#write raster

writeRaster(b4crop.tr, "B4crop.tr_20160912.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b5crop.tr, "B5crop.tr_20160912.tif",format = "GTiff", overwrite=TRUE)


