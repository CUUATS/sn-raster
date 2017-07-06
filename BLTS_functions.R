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


# Segment function  
Segment_function = function(streetCL, bikePath, lpd, speed, hasParking, combPkWidth) {
  ## rasterize layers neccessary for the analysis
  segment.stk = stack()
  street_list = c(lpd, speed)
  for (attr in street_list) {
    segment.stk = stack(segment.stk, R_rasterizeFunction(streetCL, crs, studyExtent, res, attr))
  }
  
  bikePath_list = c(hasParking, combPkWidth, parkingLaneWidth, PathType)
  for (attr1 in bikePath_list) {
    segment.stk = stack(segment.stk, R_rasterizeFunction(bikePath, crs, studyExtent, res, attr1))
  }
  
  
  
  ## Assign name to the raster layers
  comb_list = c(street_list, bikePath_list)
  ###names(segment.stk) = comb_list
  
  comb_list = c(street_list, bikePath_list)
  names(segment.stk) = comb_list

  
  bikeScore.stk = stack(BikeLaneAdjParkingLane_Function(segment.stk), 
                        BikeLaneWOAdjParkingLane_Function(segment.stk))
  bikeScore.raster = overlay(bikeScore.stk, fun = 'max')
  bikeScore.raster[bikeScore.raster == 0] <- 5
  plot(bikeScore.raster, main="bike")
  
  mixTraffic.raster = MixCriteria_function(segment.stk)
  
  segment.stk = stack(bikeScore.raster, mixTraffic.raster)
  segment.score = overlay(segment.stk, fun = 'min')
  
  segment.score = Sharrow_function(segment.score, segment.stk)
  return(segment.score)
}




