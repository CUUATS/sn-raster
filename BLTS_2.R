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


#Setting up boundary
boundary = Read_featureClass(boundary.fgdb, boundary.name, crs)
streetCL = Read_featureClass(path.fgdb, streetCL.name, crs)
bikePath = Read_featureClass(path.fgdb, bikePath.name, crs)
studyExtent = Set_studyExtent(boundary)
streetCL = Crop_featureClass(boundary, streetCL)
bikePath.onRoad = Subsetting_FeatureClass(bikePath, pathType, onRoadPath_list)



#Subsetting feature class 
Bike = readOGR(dsn = path.fgdb, layer = bikePath.name)
pathType = list(1,2,3,4,5)
for (param in pathType) {
  if (pathType[param] == 1) {
    Bike.subset = Bike[Bike[[pathType]] == param, ]
  } else {
    temp = Bike[Bike[[pathType]] == param, ]
    Bike.subset = rbind(Bike.subset, temp)
  }
  
}

plot(Bike.subset, main = "all")



























