#BLTS Functions
library(rgeos)
library(raster)

Read_featureClass  = function(path, fc_name, crs) {
  fc = readOGR(dsn=path, layer=fc_name)
  fc.tr = spTransform(fc, crs)
  return(fc.tr) ## return R dataframe object
}


Set_studyExtent = function(boundary) {
  return(extent(boundary))  ## return a extent
}


Crop_featureClass = function(boundary, fc) {
  return(crop(fc, boundary))  ## return a cropped R object
}


R_rasterizeFunction = function(object, crs, ext, res, attr) {
  object.raster = raster(ext = ext, res = res, crs = crs)
  object.raster = rasterize(object, object.raster, field = attr)
  return(object.raster)
}

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
  return(fc.final)
}

  
bl_adj_pk_function = function(streetCL, bikePath, lpd, speed, hasParking, combPkWidth) {
  # rasterize layers neccessary for the analysis
  bl_adj_pk.stk = stack()
  street_list = c(lpd, speed)
  for (attr in street_list) {
    bl_adj_pk.stk = stack(bl_adj_pk.stk, R_rasterizeFunction(streetCL, crs, studyExtent, res, attr))
  }
  
  bikePath_list = c(hasParking, combPkWidth)
  for (attr1 in bikePath_list) {
    bl_adj_pk.stk = stack(bl_adj_pk.stk, R_rasterizeFunction(bikePath, crs, studyExtent, res, attr1))
  }
  
  # assign name to the raster layers
  comb_list = c(street_list, bikePath_list)
  names(bl_adj_pk.stk) = comb_list
  
  
  return(bl_adj_pk.stk)
}




