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


#Set path to the study area geodatabase
boundary.fgdb <- "G:/Resources/Data/Boundary.gdb"
#Read Boundary for the study area
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")
UA.r <- raster(crs=crs, ext=extent)
UA.r <- rasterize(UA, UA.r)
#Set Extent for Test Area
extent<-extent(UA)

crs <- "+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"

#reproject and crop
b2 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B2.TIF")
b2proj <- projectRaster(b2, crs = crs, res = resolution)
b2proj.crop <- crop(b2proj, extent(UA))

b3 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B3.TIF", ext = extent)
b3proj <- projectRaster(b3, crs = crs, res = resolution)
b3proj.crop <- crop(b3proj, extent(UA))

b5 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B5.TIF", ext = extent)
b5proj <- projectRaster(b5, crs = crs, res = resolution)
b5proj.crop <- crop(b5proj, extent(UA))

b4 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B4.TIF", ext = extent)
b4proj <- projectRaster(b4, crs = crs, res = resolution)
b4proj.crop <- crop(b4proj, extent(UA))

b10 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B10.TIF", ext = extent)
b10proj <- projectRaster(b10, crs = crs, res = resolution)
b10proj.crop <- crop(b10proj, extent(UA))

b11 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B11.TIF", ext = extent)
b11proj <- projectRaster(b11, crs = crs, res = resolution)
b11proj.crop <- crop(b11proj, extent(UA))


#plot
plot(b2proj.crop, main = "B2")
plot(b3proj.crop, main = "B3")
plot(b4proj.crop, main = "B4")
plot(b5proj.crop, main = "B5")

#plot RGB
#stk <- stack(b4,b3,b2)
#plotRGB(stk, r=1, g=2, b=3, stretch='hist')

#write raster
writeRaster(b2proj.crop, "B2projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b3proj.crop, "B3projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b4proj.crop, "B4projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b5proj.crop, "B5projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b10proj.crop, "B10projCrop.tif", format = "GTiff", overwrite=TRUE)
writeRaster(b11proj.crop, "B11projCrop.tif", format = "GTiff", overwrite=TRUE)


