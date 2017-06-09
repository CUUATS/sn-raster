#surface temperature
library(raster)
library(rgdal)
library(rgeos)
library(sp)

setwd("L:/Sustainable Neighborhoods Toolkit/satelliteImage")

b10 <- raster("B10projCrop.TIF")
b11 <- raster("B11projCrop.TIF")

#Values from Metafile
rad_mult_b10 <- 3.3420E-04
rad_mult_b11 <- 3.3420E-04

rad_add_b10 <- 0.10000
rad_add_b11 <- 0.10000

#Calculate TOA from DN:
uab_band10 <- calc(b10, fun=function(x){rad_mult_b10 * x + rad_add_b10})
uab_band11 <- calc(b11, fun=function(x){rad_mult_b11 * x + rad_add_b11})

#Values from Metafile
K1_CONSTANT_BAND_10 = 774.8853
K2_CONSTANT_BAND_10 = 1321.0789
K1_CONSTANT_BAND_11 = 480.8883
K2_CONSTANT_BAND_11 = 1201.1442

#Calculate LST in Kelvin for Band 10 and Band 11
temp10_kelvin <- calc(uab_band10, fun=function(x){K2_CONSTANT_BAND_10/log(K1_CONSTANT_BAND_10/x + 1)})
temp11_kelvin <- calc(uab_band11, fun=function(x){K2_CONSTANT_BAND_11/log(K1_CONSTANT_BAND_11/x + 1)})

#Convert Kelvin to Celsius for Band 10 and 11
temp10_celsius <- calc(temp10_kelvin, fun=function(x){x - 273.15})
temp11_celsius <- calc(temp11_kelvin, fun=function(x){x - 273.15})

#plot
plot(temp10_celsius)

#Export raster images
writeRaster(temp10_celsius, "temp10_c.tif")
writeRaster(temp11_celsius, "temp11_c.tif")

