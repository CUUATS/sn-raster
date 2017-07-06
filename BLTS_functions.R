# BLTS Functions
library(rgeos)
library(raster)

# Read feature class from file geodatabase and project to the study coordinate system
Read_featureClass  = function(path, fc_name, crs) {
  fc = readOGR(dsn=path, layer=fc_name)
  fc.tr = spTransform(fc, crs)
  return(fc.tr) ## return R dataframe object
}


# Read bounder of study and set the extent for analysis
Set_studyExtent = function(boundary) {
  return(extent(boundary))  ## return a extent
}


# Crop input spatial object and returned cropped object
Crop_featureClass = function(boundary, fc) {
  return(crop(fc, boundary))  ## return a cropped R object
}


# Rasterize vectors layers into raster layer using the R rasterization function
R_rasterizeFunction = function(object, crs, ext, res, attr) {
  object.raster = raster(ext = ext, res = res, crs = crs)
  object.raster = rasterize(object, object.raster, field = attr, fun = 'max')
  return(object.raster)  ## return a raster object
}


# Intake vector object and return the subsetted of the original object
Subsetting_featureClass = function(featureClass, attr_list) {
  index = 0
  for (attr in attr_list) {
    if (index == 0) {
      fc.final = subset(featureClass, PathType == attr)
      index = 1
    }
    else {
      fc.temp = subset(featureClass, PathType == attr)
      fc.final = rbind(fc.temp, fc.final)
    }
  }
  return(fc.final)  ## return subsetted object
}


# Bike lane function  
bikeLane_function = function(streetCL, bikePath, lpd, speed, hasParking, combPkWidth) {
  ## rasterize layers neccessary for the analysis
  bikeLane.stk = stack()
  street_list = c(lpd, speed)
  for (attr in street_list) {
    bikeLane.stk = stack(bikeLane.stk, R_rasterizeFunction(streetCL, crs, studyExtent, res, attr))
  }
  
  bikePath_list = c(hasParking, combPkWidth, parkingLaneWidth)
  for (attr1 in bikePath_list) {
    bikeLane.stk = stack(bikeLane.stk, R_rasterizeFunction(bikePath, crs, studyExtent, res, attr1))
  }
  
  ## assign name to the raster layers
  comb_list = c(street_list, bikePath_list)
  names(bikeLane.stk) = comb_list
  
  street_list = c(lpd, speed)
  bikePath_list = c(hasParking, combPkWidth, parkingLaneWidth)
  comb_list = c(street_list, bikePath_list)
  names(bikeLane.stk) = comb_list

  
  bikeScore.stk = stack(BikeLaneAdjParkingLane_Function(bikeLane.stk), 
                        BikeLaneWOAdjParkingLane_Function(bikeLane.stk))
  bikeScore.raster = overlay(bikeScore.stk, fun='max')
  
  return(bikeScore.raster)
}




