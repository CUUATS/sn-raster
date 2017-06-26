#BLTS Functions

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


bl_adj_pk_function = function(streetCL, bikePath, lpd, speed, hasParking, combPkWidth) {
  bl_adj_pk.stk = stk()
  street_list = list(lpd, speed)
  bl_adj_pk.stk = addLayer(R_rasterizeFunction(streetCL, crs, ext, res, street_list))
  
  bikePath_list = list(hasParki, combPkWidth)
  bl_adj_pk.stk = addLayer(R_rasterizeFunction(bikePath, crs, ext, res, bikePath_list))
  return(bl_adj_pk.stk)
}

Subsetting_FeatureClass = function(fc, field, params) {
  for (param in params) {
    if (params[param] == 1) {
      fc.subset = fc[fc$field == param, ]
    } else {
      temp = fc[fc$field == param, ]
      fc.subset = rbind(fc.subset, temp)
    }
    
  }
  return(fc.subset)
}


