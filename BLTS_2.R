# Test Script on functions

library(raster)
library(rgdal)
library(gdalUtils)
library(gdistance)
library(gdata)
library(rgeos)

  

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


#R_rasterizeFunction = function(object, crs, ext, res, attr_list) {
#  streetCL.stk = stack()
#  for (attribute in attr_list) {
#    print(attribute)
#    object.raster = raster(ext=ext, res=res, crs = crs)
#    object.raster = rasterize(object, object.raster, field=attribute)
#    streetCL.stk = addLayer(streetCL.stk, object.raster)
#  }
#  return(streetCL.stk)
#}

R_rasterizeFunction = function(object, crs, ext, res, attr) {
  object.raster = raster(ext = ext, res = res, crs = crs)
  object.raster = rasterize(object, object.raster, field = attr)
  return(object.raster)
}


BLwAdjPk_function = function() {
  
}


path.fgdb = "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"
streetCL.name = "test_CL"
boundary.fgdb = "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"
boundary.name = "test_boundary"
crs = crs("+init=ESRI:102671")
res = 100

boundary = Read_featureClass(boundary.fgdb, boundary.name, crs)
streetCL = Read_featureClass(path.fgdb, streetCL.name, crs)
studyExtent = Set_studyExtent(boundary)
streetCL = Crop_featureClass(boundary, streetCL)
streetCL_list = list('lpd', 'SPEED', )
BLwAdjPk.stk = R_rasterizeFunction(streetCL, , crs, studyExtent, res, streetCL_list)

  
plot(speed.gdal)
plot(streetCL)
plot(speed.raster[[2]])



























