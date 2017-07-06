# Test Script on functions

library(raster)
library(rgdal)
library(gdalUtils)
library(gdistance)
library(gdata)
library(rgeos)

workDir = "G:/CUUATS/Sustainable Neighborhoods Toolkit/Scripts"
setwd(workDir)
source('BLTS_param.R')
source('BLTS_functions.R')
source('BLTS_score.R')


# Setting up boundary
boundary = Read_featureClass(boundary.fgdb, boundary.name, crs)
streetCL = Read_featureClass(path.fgdb, streetCL.name, crs)
bikePath = Read_featureClass(path.fgdb, bikePath.name, crs)
studyExtent = Set_studyExtent(boundary)

# Cropping feature to the boundary
streetCL = Crop_featureClass(boundary, streetCL)
bikePath = Crop_featureClass(boundary, bikePath)

# Subsetting bike path to on road bike path
offRoadPath = Subsetting_featureClass(bikePath, offRoadPath_list)
onRoadPath = Subsetting_featureClass(bikePath, onRoadPath_list)

# Rasterizing feature class
bikeLane.score = bikeLane_function(streetCL, onRoadPath, lpd, speed, hasParking, combPkWidth)
plot(bikeLane.score)





















