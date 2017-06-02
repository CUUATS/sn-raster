library(raster)
library(rgdal)
library(rgeos)

setwd("C:/Users/kml42638/Desktop/remote")


#4. set path to the study area geodatabase
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
b2proj <- projectRaster(b2, crs = crs)
b2proj.crop <- crop(b2proj, extent(UA))

b3 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B3.TIF", ext = extent)
b3proj <- projectRaster(b3, crs = crs)
b3proj.crop <- crop(b3proj, extent(UA))


b5 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B5.TIF", ext = extent)
b5proj <- projectRaster(b5, crs = crs)
b5proj.crop <- crop(b5proj, extent(UA))


b4 <- raster("LC08_L1TP_023032_20170510_20170516_01_T1_B4.TIF", ext = extent)
b4proj <- projectRaster(b4, crs = crs)
b4proj.crop <- crop(b4proj, extent(UA))

#plot
plot(b2proj.crop, main = "B2")
plot(b3proj.crop, main = "B3")
plot(b4proj.crop, main = "B4")
plot(b5proj.crop, main = "B5")

#Calculate vegetation index
NDVI = (b5proj.crop-b4proj.crop) / (b5proj.crop+b4proj.crop)
plot(NDVI, main="NDVI")
writeRaster(NDVI, "NDVI.tif", format = "GTiff", overwrite=TRUE)

#write raster
writeRaster(b2proj.crop, "B2projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b3proj.crop, "B3projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b4proj.crop, "B4projCrop.tif",format = "GTiff", overwrite=TRUE)
writeRaster(b5proj.crop, "B5projCrop.tif",format = "GTiff", overwrite=TRUE)

