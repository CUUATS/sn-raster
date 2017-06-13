#PLTS_assessment.R
#This script is used to assessment sidewalk inventory and assignment a PLTS score to each segment
#Edmond Lai - CUUATS

start.time <- Sys.time()

#LIBRARY NEEDED FOR ANALYSIS
#####################################################################################################################
library(raster)
library(rgdal)
library(gdalUtils)
library(RColorBrewer)
library(gdistance)
library(gdata)

#1. set path to the file geodatabase containing feature classes for analysis
path.fgdb <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"

#2. temporary file directory Directory
tempDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/GeoTiff/"
setwd(tempDir)

#result directory
resultDir <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Result/"

#3. Set resolution for raster cell size, this can be changed by the user to fine tune the scale of cell size
resolution <- 100

#4. set path to the study area geodatabase
boundary.fgdb <- "G:/Resources/Data/Boundary.gdb"

#5. set path where shapefiles are stored
shape.path <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/Shapefile/"

sidewalk <- "sidewalk.shp"

#10. projection system
crs <- "+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"


#READING FEATURE CLASS LINE FILES FROM ESRI GEODATABASE (Section B)
#####################################################################################################################
#Read Boundary for the study area
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")

#Set Extent for Test Area
extent<-extent(UA)

####CREATE A RASTER LAYER OBJECT (Section C)####
#########################################################################################################################
#Section C1
#Set path to sidewalk shapefile
src_datasource <- paste(shape.path,sidewalk, sep = "")
r.sidewalk_wid <- raster(ext=extent, resolution=resolution, crs = crs)
sidewalk_wid.tif <- writeRaster(r.sidewalk_wid, filename = "sidewalk_wid.tif", format="GTiff", overwrite = TRUE)
sidewalk_wid.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "sidewalk_wid.tif", a="Width", at=TRUE, output_Raster = TRUE)
crs(sidewalk_wid.raster) <- crs
sidewalk_wid.raster <- sidewalk_wid.raster / 12

r.sidewalk_cond <- raster(ext=extent, resolution=resolution, crs = crs)
sidewalk_cond.tif <- writeRaster(r.sidewalk_cond , filename = "sidewalk_cond.tif", format="GTiff", overwrite = TRUE)
sidewalk_cond.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "sidewalk_cond.tif", a="ScoreCondi", at=TRUE, output_Raster = TRUE)
crs(sidewalk_cond.raster) <- crs


less4 <- sidewalk_wid.raster < 4
great4less5 <- sidewalk_wid.raster >=4 & sidewalk_wid.raster < 5
great5less6 <- sidewalk_wid.raster >=5 & sidewalk_wid.raster < 6
great6 <- sidewalk_wid.raster >= 6 

good <- sidewalk_cond.raster >=90
fair <- sidewalk_cond.raster < 90 & sidewalk_cond.raster >=80
poor <- sidewalk_cond.raster < 80 & sidewalk_cond.raster >=70
veryPoor <- sidewalk_cond.raster < 70

condition.raster <- raster(ext=extent, res = resolution, crs = crs)
condition.raster[] <- 0

condition.raster[less4 & good] <- 4
condition.raster[less4 & fair] <- 4
condition.raster[less4 & poor] <- 4
condition.raster[less4 & veryPoor] <- 4

condition.raster[great4less5 & good] <- 3
condition.raster[great4less5 & fair] <- 3
condition.raster[great4less5 & poor] <- 3
condition.raster[great4less5 & veryPoor] <- 4

condition.raster[great5less6 & good] <- 2
condition.raster[great5less6 & fair] <- 2
condition.raster[great5less6 & poor] <- 3
condition.raster[great5less6 & veryPoor] <- 4

condition.raster[great6 & good] <- 1
condition.raster[great6 & fair] <- 1
condition.raster[great6 & poor] <- 2
condition.raster[great6 & veryPoor] <- 3




setwd(resultDir)
filename <- paste("condition", resolution, sep = "")
writeRaster(condition.raster, filename, format="GTiff", overwrite = TRUE)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken


