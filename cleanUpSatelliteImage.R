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

#set study crs
crsStudy <- crs(UA)

#create file names
inB4Name <- paste("LC08_L1TP_023032_20160912_20170221_01_T1_B4",".TIF", sep="")
inB5Name <- paste("LC08_L1TP_023032_20160912_20170221_01_T1_B5",".TIF", sep="")

#read satellite image and set satellite crs
b4 <- raster(inB4Name)
crsSate <- crs(b4)


#transform boundary to satellite crs
UA.tr <- spTransform(UA, crsSate)
#UA_tr.r <- raster(ext=extent(UA.tr))
#UA_tr.r <- rasterize(UA.tr, UA_tr.r)
#Set Extent for Test Area

b4 <- raster(inB4Name)
b4crop <- crop(b4, extent(UA.tr))
b4crop.tr <- projectRaster(b4crop, crs=crsStudy)
b4agr <- b4crop.rtchan

b5 <- raster(inB5Name)
b5crop <- crop(b5, extent(UA.tr))
b5crop.tr <- projectRaster(b5crop, crs=crsStudy)


#plot
plot(b4crop.tr, main = "B4")
plot(b5crop.tr, main = "B5")

#plot RGB
#stk <- stack(b4crop.tr,b3crop.tr,b2crop.tr)
#plotRGB(stk, r=1, g=2, b=3, stretch='hist')

#write raster

writeRaster(b4crop.tr, "B4crop.tr_20160912.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b5crop.tr, "B5crop.tr_20160912.tif",format = "GTiff", overwrite=TRUE)


