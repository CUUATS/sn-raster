#Project: Sustainable Neighborhood Toolkit - BLTS Analysis
#Description: This script reads shapefiles containing target attributes.  Rasterizing the vector files into
#raster files using gdalUtils.  Perform BLTS analysis based on the documentation ODOT report
#Author: Edmond Lai - CUUATS
#Last Work on by: Edmond Lai
#Date Last Worked on: 5/24/2017
#Last Worked on: 
#Shortest Route Calculation

#Need to complete:
#Writing comments


start.time <- Sys.time()

#LIBRARY NEEDED FOR ANALYSIS
#####################################################################################################################
library(raster)
library(rgdal)
library(gdalUtils)
library(RColorBrewer)
library(gdistance)
library(gdata)

#USER INPUT (Section A)
#*************************************************************************************************************************#
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

#6. set name for the bike shapefile
onRoadPath <- "onRoadPath.shp"
offRoadPath <- "offRoadPath.shp"

bike.name <- "bikeLane.shp"

#8. set name for St CL shapefile
StreetCL.name <- "Street_w_Int_Clip.shp"

#9. set path to intersection
Int.name <- "Intersections_all.shp"

#crs
crs <- crs("+init=ESRI:102671")

#11. set no path value (In Progress)
npv <- 5


#*************************************************************************************************************************#

#READING FEATURE CLASS LINE FILES FROM ESRI GEODATABASE (Section B)
#####################################################################################################################
#Read Boundary for the study area
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")
#Set Extent for Test Area
UA.pr <- spTransform(UA, crs)
studyExtent = extent(UA.pr)
extent.raster <- raster(ext = studyExtent, resolution=resolution, crs=crs)
extent.raster <- rasterize(UA.pr, extent.raster)
studyExtent = extent(extent.raster)


####CREATE A RASTER LAYER OBJECT (Section C)####
#########################################################################################################################
#Section C1
#Set path to Bike Lane shapefile
src_datasource <- paste(shape.path,onRoadPath, sep = "")
r.onRoadPath <- raster(ext=studyExtent, resolution = resolution, crs = crs)
onRoadPath.tif <- writeRaster(r.onRoadPath, filename = "onRoadPath.tif", format="GTiff", overwrite=TRUE)
onRoadPath.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "onRoadPath.tif", a="PathType", at=TRUE, output_Raster = TRUE)


#Off Road
src_datasource <- paste(shape.path,offRoadPath, sep = "")
r.offRoadPath <- raster(ext=studyExtent, resolution = resolution, crs = crs)
offRoadPath.tif <- writeRaster(r.offRoadPath, filename = "offRoadPath.tif", format="GTiff", overwrite=TRUE)
offRoadPath.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "offRoadPath.tif", a="PathType", at=TRUE, output_Raster = TRUE)


#Rasterize Bike Path Width
r.rdWidth <- raster(ext=studyExtent, resolution = resolution, crs = crs)
roadWidth.tif <- writeRaster(r.rdWidth, filename = "roadWidth.tif", format = "GTiff", overwrite = TRUE)
roadWidth.raster <- gdal_rasterize(src_datasource, dst_filename = "roadWidth.tif", a="Width",at=TRUE,output_Raster = TRUE)


###Rasterize Parking Lane Width
r.pkWidth <- raster(ext=studyExtent, resolution = resolution, crs = crs)
pkWidth.tif <- writeRaster(r.pkWidth, filename = "parkingWidth.tif", format="GTiff", overwrite=TRUE)
parkingWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "parkingWidth.tif", a="pkLaneWidt",at=TRUE,output_Raster = TRUE)


###Create Combined Parking and Bike Lane Width
r.bikeParkWidth <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bikeParkWidth.tif <- writeRaster(r.bikeParkWidth, filename = "bikeParkWidth.tif", format="GTiff", overwrite=TRUE)
bikeParkWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeParkWidth.tif", a="Comb_ParkB",at=TRUE,output_Raster = TRUE)


###Create Bike Lane with Adjacent Parking Lane Criteria
r.bikeCrit <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bikeCrit.tif <- writeRaster(r.bikeCrit, filename = "bikeCrit.tif", format="GTiff", overwrite=TRUE)
bikeCrit.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeCrit.tif", a="hasParki_1",at=TRUE,output_Raster = TRUE)



#StreetCL layer
Street <- readOGR(dsn=path.fgdb, layer = "Street_w_Int_Clip")
maxsp.raster <- raster(ext=studyExtent, resolution = resolution, crs = crs)
maxsp.raster <- rasterize(Street, maxsp.raster, field="SPEED", fun='max')
crs(maxsp.raster) <- crs

#Create total Lane Raster
lanePerDir.raster <- raster(ext=studyExtent, resolution = resolution, crs = crs)
lanePerDir.raster <- rasterize(Street, lanePerDir.raster, field="lpd", fun='max')
crs(lanePerDir.raster) <- crs


#FUNCTIONS TO BE USED IN THE BLTS SCORE ANALYSIS
#####################################################################################################################
#Assign score of Off Street Biking to a score of 1

#Section C2
#Physically Seperated Bike Lane 
#Input is in BikePed Layer, all the off street facilities are assigned a score of 1, all other type of biking facilities
#are removed from this layer.  Result is the all off road biking facilities and a GeoTiff is exported for later analysis.
scoreBike <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreBike[] <- npv

osft1 <- offRoadPath.raster == 1
osft2 <- offRoadPath.raster == 2
osft3 <- offRoadPath.raster == 3
osft4 <- offRoadPath.raster == 4
osft5 <- offRoadPath.raster == 5

scoreBike[osft1 | osft2 | osft3 | osft4 | osft5] <- 1


#####################################################################################################################
####Create new layer for each criteria (Section C3)#
#Bike Criteria (Does the bike lane has adj parking? 1 - yes, 0 - no)
ly <- bikeCrit.raster == 1
ln <- bikeCrit.raster == 0 

#Lane per direction (for Biking facilities)
lpd1 <- lanePerDir.raster == 1 | lanePerDir.raster == 0
lpd2 <- lanePerDir.raster >= 2

#Prevailing Speed or Posted Speed
sp25 <- maxsp.raster <=25
sp30 <- maxsp.raster ==30
sp35 <- maxsp.raster ==35
sp40 <- maxsp.raster >=40
spless30 <- maxsp.raster <= 30
spgreat35 <- maxsp.raster >= 35

#Lane plus parking width
bpw15 <- bikeParkWidth.raster >= 15
bpw14 <- bikeParkWidth.raster >= 14 & bikeParkWidth.raster < 15
bpw13 <- bikeParkWidth.raster <= 13
bpw2 <- bikeParkWidth.raster <= 14.5

#Bike Lane width
bwgreat7 <- roadWidth.raster >= 7
bwb57 <- roadWidth.raster > 5.5 & roadWidth.raster < 7
bw5.5 <- roadWidth.raster <= 5.5
bwless7 <- roadWidth.raster < 7

#Lane per direction (for mixed use traffic)
lane0 <- lanePerDir.raster == 0
lane1 <- lanePerDir.raster == 1
lane2 <- lanePerDir.raster == 2
lane3 <- lanePerDir.raster >= 3




#####################################################################################################################
###Exhibit 14-3 Bike Lane with Adjaent Parking Lane Criteria (Section C4)
#Create a Score Layer
#Create all bike facilities
#allBike <- is.na(facility.raster) == FALSE

#Bike Lane with Adjacent Parking Lane Criteria
#Bike Path Type
bikelane <- onRoadPath.raster == 6 | onRoadPath.raster == 9

#Set the default score for all biking facilities
scoreBike[bikelane & ly & lpd1 & sp25 & bpw15] <- 1
scoreBike[bikelane & ly & lpd1 & sp30 & bpw15] <- 1
scoreBike[bikelane & ly & lpd1 & sp35 & bpw15] <- 2
scoreBike[bikelane & ly & lpd1 & sp40 & bpw15] <- 2

scoreBike[bikelane & ly & lpd1 & sp25 & bpw14] <- 2
scoreBike[bikelane & ly & lpd1 & sp30 & bpw14] <- 2
scoreBike[bikelane & ly & lpd1 & sp35 & bpw14] <- 3
scoreBike[bikelane & ly & lpd1 & sp40 & bpw14] <- 4

scoreBike[bikelane & ly & lpd1 & sp25 & bpw13] <- 3
scoreBike[bikelane & ly & lpd1 & sp30 & bpw13] <- 3
scoreBike[bikelane & ly & lpd1 & sp35 & bpw13] <- 3
scoreBike[bikelane & ly & lpd1 & sp40 & bpw13] <- 4

scoreBike[bikelane & ly & lpd2 & sp25 & bpw15] <- 2
scoreBike[bikelane & ly & lpd2 & sp30 & bpw15] <- 2
scoreBike[bikelane & ly & lpd2 & sp35 & bpw15] <- 3
scoreBike[bikelane & ly & lpd2 & sp40 & bpw15] <- 3

scoreBike[bikelane & ly & lpd2 & sp25 & bpw2] <- 3
scoreBike[bikelane & ly & lpd2 & sp30 & bpw2] <- 3
scoreBike[bikelane & ly & lpd2 & sp35 & bpw2] <- 3
scoreBike[bikelane & ly & lpd2 & sp40 & bpw2] <- 4

#####################################################################################################################
###Exhibit 14-4 Bike Lane without Adjacent Parking Lane Criteria

scoreBike[bikelane & ln & lpd1 & spless30 & bwgreat7] <- 1
scoreBike[bikelane & ln & lpd1 & sp35 & bwgreat7] <- 2
scoreBike[bikelane & ln & lpd1 & sp40 & bwgreat7] <- 3

scoreBike[bikelane & ln & lpd1 & spless30 & bwb57] <- 1
scoreBike[bikelane & ln & lpd1 & sp35 & bwb57] <- 3
scoreBike[bikelane & ln & lpd1 & sp40 & bwb57] <- 4

scoreBike[bikelane & ln & lpd1 & spless30 & bw5.5] <- 2
scoreBike[bikelane & ln & lpd1 & sp35 & bw5.5] <- 3
scoreBike[bikelane & ln & lpd1 & sp40 & bw5.5] <- 4

scoreBike[bikelane & ln & lpd2 & spless30 & bwgreat7] <- 1
scoreBike[bikelane & ln & lpd2 & sp35 & bwgreat7] <- 2
scoreBike[bikelane & ln & lpd2 & sp40 & bwgreat7] <- 3

scoreBike[bikelane & ln & lpd2 & spless30 & bwless7] <- 3
scoreBike[bikelane & ln & lpd2 & sp35 & bwless7] <- 3
scoreBike[bikelane & ln & lpd2 & sp40 & bwless7] <- 4

#####################################################################################################################
### Exhibit 14-5 Urban/Suburban Mixed Traffic Criteria (Section C5)
scoreMix <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreMix[] <- npv

scoreMix[sp25 & lane0] <- 1
scoreMix[sp30 & lane0] <- 2
scoreMix[spgreat35 & lane0] <- 3

scoreMix[sp25 & lane1] <- 2
scoreMix[sp30 & lane1] <- 3
scoreMix[spgreat35 & lane1] <- 4

scoreMix[sp25 & lane2] <- 3
scoreMix[sp30 & lane2] <- 4
scoreMix[spgreat35 & lane2] <- 4

scoreMix[sp25 & lane3] <- 4
scoreMix[sp30 & lane3] <- 4
scoreMix[spgreat35 & lane3] <- 4


#Lower the BLTS score by one if sharrow is present (Section C6)

#No bike Lane but has sharrow
sharrow <- onRoadPath.raster == 8
sharrow[sharrow != 1] <- 0
sharrow[is.na(sharrow)] <- 0
sharrow[sharrow == 1] <- -1



scoreMix <- scoreMix + sharrow
scoreMix[scoreMix == 0] <- 1


#####################################################################################################################
##Calculate Combine Score for bike facilities and mix used traffic (Section C7)
scoreComb <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreComb[] <- npv
stk <- stack(scoreMix,scoreBike)
scoreComb <- overlay(stk, fun=min)

#####################################################################################################################
####Right Turn Lane Criteria (Section D)####
#Rasterizing Attributes needed for the Intersection Approach

#Rasterize Right Turn Lane Configuration (Section D1)
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.RTL_Conf_N <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Conf_N.tif <- writeRaster(r.RTL_Conf_N, filename = "RTL_Conf_N", format="GTiff", overwrite=TRUE)
RTL_Conf_N.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_N.tif", a="RTL_Conf_N",at=TRUE,output_Raster = TRUE)


r.RTL_Conf_S <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Conf_S.tif <- writeRaster(r.RTL_Conf_S, filename = "RTL_Conf_S", format="GTiff", overwrite=TRUE)
RTL_Conf_S.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_S.tif", a="RTL_Conf_S",at=TRUE,output_Raster = TRUE)


r.RTL_Conf_E <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Conf_E.tif <- writeRaster(r.RTL_Conf_E, filename = "RTL_Conf_E", format="GTiff", overwrite=TRUE)
RTL_Conf_E.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_E.tif", a="RTL_Conf_E",at=TRUE,output_Raster = TRUE)


r.RTL_Conf_W <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Conf_W.tif <- writeRaster(r.RTL_Conf_W, filename = "RTL_Conf_W", format="GTiff", overwrite=TRUE)
RTL_Conf_W.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_W.tif", a="RTL_Conf_W",at=TRUE,output_Raster = TRUE)

#####################################################################################################################
#Rasterize Bike Lane Approach
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.bike_AA_N <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bike_AA_N.tif <- writeRaster(r.bike_AA_N, filename = "bike_AA_N", format="GTiff", overwrite=TRUE)
bike_AA_N.raster <- gdal_rasterize(src_datasource, dst_filename = "bike_AA_N.tif", a="bike_AA_N",at=TRUE,output_Raster = TRUE)


src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.bike_AA_S <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bike_AA_S.tif <- writeRaster(r.bike_AA_S, filename = "bike_AA_S", format="GTiff", overwrite=TRUE)
bike_AA_S.raster <- gdal_rasterize(src_datasource, dst_filename = "bike_AA_S.tif", a="bike_AA_S",at=TRUE,output_Raster = TRUE)


src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.bike_AA_E <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bike_AA_E.tif <- writeRaster(r.bike_AA_E, filename = "bike_AA_E", format="GTiff", overwrite=TRUE)
bike_AA_E.raster <- gdal_rasterize(src_datasource, dst_filename = "bike_AA_E.tif", a="bike_AA_E",at=TRUE,output_Raster = TRUE)


src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.bike_AA_W <- raster(ext=studyExtent, resolution = resolution, crs = crs)
bike_AA_W.tif <- writeRaster(r.bike_AA_W, filename = "bike_AA_W", format="GTiff", overwrite=TRUE)
bike_AA_W.raster <- gdal_rasterize(src_datasource, dst_filename = "bike_AA_W.tif", a="bike_AA_W",at=TRUE,output_Raster = TRUE)


#Rasterize Right Turn Lane Length
r.RTL_Len_N <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Len_N.tif <- writeRaster(r.RTL_Len_N, filename = "RTL_Len_N", format="GTiff", overwrite=TRUE)
RTL_Len_N.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Len_N.tif", a="RTL_Len_N",at=TRUE,output_Raster = TRUE)

r.RTL_Len_S <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Len_S.tif <- writeRaster(r.RTL_Len_S, filename = "RTL_Len_S", format="GTiff", overwrite=TRUE)
RTL_Len_S.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Len_S.tif", a="RTL_Len_S",at=TRUE,output_Raster = TRUE)


r.RTL_Len_E <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Len_E.tif <- writeRaster(r.RTL_Len_E, filename = "RTL_Len_E", format="GTiff", overwrite=TRUE)
RTL_Len_E.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Len_E.tif", a="RTL_Len_E",at=TRUE,output_Raster = TRUE)


r.RTL_Len_W <- raster(ext=studyExtent, resolution = resolution, crs = crs)
RTL_Len_W.tif <- writeRaster(r.RTL_Len_W, filename = "RTL_Len_W", format="GTiff", overwrite=TRUE)
RTL_Len_W.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Len_W.tif", a="RTL_Len_W",at=TRUE,output_Raster = TRUE)




#####################################################################################################################
#Create empty raster to store the score
scoreRTL <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreRTL[] <- 0

scoreRTL.temp <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreRTL.temp[] <- 0
#####################################################################################################################


#Loop through the RTL Configuration for N, S, E, W and assign score for each direction of the intersection (Section D3)
#Combine the layers into rasterStack
conf_Dir <- stack(RTL_Conf_N.raster, RTL_Conf_S.raster,RTL_Conf_E.raster,RTL_Conf_W.raster)
names(conf_Dir) <- c("North", "South", "East", "West")

len_Dir <- stack(RTL_Len_N.raster, RTL_Len_S.raster, RTL_Len_E.raster, RTL_Len_W.raster)
names(len_Dir) <- c("North", "South", "East", "West")

bike_AA_Dir <- stack(bike_AA_N.raster, bike_AA_S.raster, bike_AA_E.raster, bike_AA_W.raster)
names(bike_AA_Dir) <- c("North", "South", "East", "West")

for (i in 1:nlayers(conf_Dir)) {
  scoreRTL.temp[] <- 0
  RTL_Conf_S <- conf_Dir[[i]] == 1
  RTL_Conf_DE_S <- conf_Dir[[i]] == 2 | conf_Dir[[i]] == 1
  title = names(conf_Dir[[i]])
  
  RTL_Length_less150 <- len_Dir[[i]] <=150 & len_Dir[[i]] > 0
  RTL_Length_great150 <- len_Dir[[i]] > 150
  RTL_Length_any <- len_Dir[[i]] > 0
  
  RTL_Appro_Str <- bike_AA_Dir[[i]] == 1
  RTL_Appro_Lef <- bike_AA_Dir[[i]] == 2 | bike_AA_Dir[[i]] == 3
  RTL_Appro_Any <- bike_AA_Dir[[i]] == 1 | bike_AA_Dir[[i]] == 2 | bike_AA_Dir[[i]] == 3 | bike_AA_Dir[[i]] == 0
  
  
  
  scoreRTL.temp[RTL_Conf_DE_S & RTL_Length_any & RTL_Appro_Any] <- 4
  scoreRTL.temp[RTL_Conf_S & RTL_Length_great150 & RTL_Appro_Str] <- 3
  scoreRTL.temp[RTL_Conf_S & RTL_Length_any & RTL_Appro_Lef] <- 3
  scoreRTL.temp[RTL_Conf_S & RTL_Length_less150 & RTL_Appro_Str] <- 2
  scoreRTL <- stack(scoreRTL, scoreRTL.temp)
  scoreRTL <- overlay(scoreRTL, fun=max)
}

#Overlay the Score w/o intersection and with RTL criteria, assign null value to zero and select the maximum from the two
#scoreComb_5 <- scoreComb == 5
#scoreRTL_5 <- scoreRTL == 5

scoreComb[scoreComb == 5] <- 0
scoreRTL[scoreRTL== 5] <- 0
Comb_RTL <- stack(scoreComb, scoreRTL)
scoreCombRTL <- overlay(Comb_RTL, fun = max)

#Write the hard value of off road bike route to the score
scoreCombRTL[osft1 | osft2 | osft3 | osft4 | osft5] <- 1


#####################################################################################################################
#Left Turn Lane Criteria (Section E)
#rasterize Criteria for Left Turn Lane (Section E1)
#Lane Cross
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.LTL_lanesc <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_lanesc.tif <- writeRaster(r.LTL_lanesc, filename = "LTL_lanesc", format="GTiff", overwrite=TRUE)
LTL_lanesc.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lanesc.tif", a="LTL_lanesc",at=TRUE,output_Raster = TRUE)


r.LTL_lane_1 <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_lane_1.tif <- writeRaster(r.LTL_lane_1, filename = "LTL_lane_1", format="GTiff", overwrite=TRUE)
LTL_lane_1.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_1.tif", a="LTL_lane_1",at=TRUE,output_Raster = TRUE)


r.LTL_lane_2 <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_lane_2.tif <- writeRaster(r.LTL_lane_2, filename = "LTL_lane_2", format="GTiff", overwrite=TRUE)
LTL_lane_2.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_2.tif", a="LTL_lane_2",at=TRUE,output_Raster = TRUE)


r.LTL_lane_3 <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_lane_3.tif <- writeRaster(r.LTL_lane_3, filename = "LTL_lane_3", format="GTiff", overwrite=TRUE)
LTL_lane_3.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_3.tif", a="LTL_lane_3",at=TRUE,output_Raster = TRUE)

#####################################################################################################################
#Intersection Configuation
r.LTL_Conf_N <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_Conf_N.tif <- writeRaster(r.LTL_Conf_N, filename = "LTL_Conf_N", format="GTiff", overwrite=TRUE)
LTL_Conf_N.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_N.tif", a="LTL_Conf_N",at=TRUE,output_Raster = TRUE)


r.LTL_Conf_S <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_Conf_S.tif <- writeRaster(r.LTL_Conf_S, filename = "LTL_Conf_S", format="GTiff", overwrite=TRUE)
LTL_Conf_S.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_S.tif", a="LTL_Conf_S",at=TRUE,output_Raster = TRUE)


r.LTL_Conf_E <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_Conf_E.tif <- writeRaster(r.LTL_Conf_E, filename = "LTL_Conf_E", format="GTiff", overwrite=TRUE)
LTL_Conf_E.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_E.tif", a="LTL_Conf_E",at=TRUE,output_Raster = TRUE)


r.LTL_Conf_W <- raster(ext=studyExtent, resolution = resolution, crs = crs)
LTL_Conf_W.tif <- writeRaster(r.LTL_Conf_W, filename = "LTL_Conf_W", format="GTiff", overwrite=TRUE)
LTL_Conf_W.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_W.tif", a="LTL_Conf_W",at=TRUE,output_Raster = TRUE)

#####################################################################################################################
#Create empty raster to store the score for LTL (Section E2)
scoreLTL <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreLTL[] <- 0

scoreLTL.temp <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreLTL.temp[] <- 0

#Create Stack for LTL Criteria
LTL_Conf_Dir <- stack(LTL_Conf_N.raster, LTL_Conf_S.raster,LTL_Conf_E.raster,LTL_Conf_W.raster)
LTL_LC_Dir <- stack(LTL_lanesc.raster, LTL_lane_1.raster, LTL_lane_2.raster, LTL_lane_3.raster)

#Create evaluation layer for lane crossed in one intersection
for(i in 1:nlayers(LTL_LC_Dir)) {
  scoreLTL.temp[] <- 0
  #Setting criteria for evaluation
  laneCrossed_0 <- LTL_LC_Dir[[i]] == 0
  laneCrossed_1 <- LTL_LC_Dir[[i]] == 1
  laneCrossed_2 <- LTL_LC_Dir[[i]] >= 2
  laneCrossed_DE <- LTL_Conf_Dir[[i]] != 0
  
  #Scoring based on Exhibit 14-8 Left Turn Lane Criteria
  scoreLTL.temp[sp25 & laneCrossed_0] <- 2
  scoreLTL.temp[sp25 & laneCrossed_1] <- 2
  scoreLTL.temp[sp25 & laneCrossed_2] <- 3
  scoreLTL.temp[sp25 & laneCrossed_DE] <- 4
  
  scoreLTL.temp[sp30 & laneCrossed_0] <- 2
  scoreLTL.temp[sp30 & laneCrossed_1] <- 3
  scoreLTL.temp[sp30 & laneCrossed_2] <- 4
  scoreLTL.temp[sp30 & laneCrossed_DE] <- 4
  
  scoreLTL.temp[spgreat35 & laneCrossed_0] <- 3
  scoreLTL.temp[spgreat35 & laneCrossed_1] <- 4
  scoreLTL.temp[spgreat35 & laneCrossed_2] <- 4
  scoreLTL.temp[spgreat35 & laneCrossed_DE] <- 4
  
  scoreLTL <- stack(scoreLTL, scoreLTL.temp)
  scoreLTL <- overlay(scoreLTL, fun=max)
}
#####################################################################################################################


#Combinging the Score with Mixed Used, Bike Lane, RLT and LTL (Section E4)
score.Comb.RLT.LTL <- raster(ext=studyExtent, resolution = resolution, crs = crs)
score.Comb.RLT.LTL[] <- 0
score.Comb.RLT.LTL <- stack(scoreComb, scoreLTL)
score.Comb.RLT.LTL <- overlay(score.Comb.RLT.LTL, fun = max)

#Write the hard value of off road bike route to the score
score.Comb.RLT.LTL[osft1 | osft2 | osft3 | osft4 | osft5] <- 1
#####################################################################################################################

#Median Criteria (Section F)

#rasterize intersections total lanecrossed
src_datasource <- paste(shape.path,Int.name, sep = "")
r.totallanes_ns <- raster(ext=studyExtent, resolution = resolution, crs = crs)
totallanes_ns.tif <- writeRaster(r.totallanes_ns, filename = "totallanes_ns", format="GTiff", overwrite=TRUE)
totallanes_ns.raster <- gdal_rasterize(src_datasource, dst_filename = "totallanes_ns.tif", a="TotalLanes",at=TRUE,output_Raster = TRUE)


r.totallanes_ew <- raster(ext=studyExtent, resolution = resolution, crs = crs)
totallanes_ew.tif <- writeRaster(r.totallanes_ew, filename = "totallanes_ew", format="GTiff", overwrite=TRUE)
totallanes_ew.raster <- gdal_rasterize(src_datasource, dst_filename = "totallanes_ew.tif", a="TotalLan_1",at=TRUE,output_Raster = TRUE)


#rasterize median (Y/N)
r.median <- raster(ext=studyExtent, resolution = resolution, crs = crs)
median.tif <- writeRaster(r.median, filename = "median.tif", format="GTiff", overwrite=TRUE)
median.raster <- gdal_rasterize(src_datasource, dst_filename = "median.tif", a="med_ref_al",at=TRUE,output_Raster = TRUE)

#raster signalized intersection (Y/N)
r.signal <- raster(ext=studyExtent, resolution = resolution, crs = crs)
signal.tif <- writeRaster(r.signal, filename = "signal.tif", format="GTiff", overwrite=TRUE)
signal.raster <- gdal_rasterize(src_datasource, dst_filename = "signal.tif", a="signal",at=TRUE,output_Raster = TRUE)


#####################################################################################################################

#create an empty score layer for Median criteria (Section F3)
scoreMed <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreMed[] <- 0

scoreMed.temp <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scoreMed.temp[] <- 0

#Criterias for Median
median.true <- median.raster == 1
median.false <- median.raster == 0

#mask for speed
sp25 <- maxsp.raster <= 25
sp30 <- maxsp.raster == 30
sp35 <- maxsp.raster == 35
sp40 <- maxsp.raster >= 40

#mask for unsignalized intersection
unsignal <- signal.raster == 0

#stack the total lane ns and ew together
tl_stack <- stack(totallanes_ns.raster, totallanes_ew.raster)

#for loop for intersection that has median
for (i in 1:nlayers(tl_stack)) {
  scoreMed.temp[] <- 0
  tlc3 <- tl_stack[[i]] <= 3
  tlc45 <- tl_stack[[i]] == 4 | tl_stack[[i]] == 5
  tlc6 <- tl_stack[[i]] >= 6
  
  scoreMed.temp[unsignal & median.true & sp25 & tlc3] <- 1
  scoreMed.temp[unsignal & median.true & sp25 & tlc45] <- 2
  scoreMed.temp[unsignal & median.true & sp25 & tlc6] <- 4
  
  scoreMed.temp[unsignal & median.true & sp30 & tlc3] <- 1
  scoreMed.temp[unsignal & median.true & sp30 & tlc45] <- 2
  scoreMed.temp[unsignal & median.true & sp30 & tlc6] <- 4
  
  scoreMed.temp[unsignal & median.true & sp35 & tlc3] <- 2
  scoreMed.temp[unsignal & median.true & sp35 & tlc45] <- 3
  scoreMed.temp[unsignal & median.true & sp35 & tlc6] <- 4
  
  scoreMed.temp[unsignal & median.true & sp40 & tlc3] <- 3
  scoreMed.temp[unsignal & median.true & sp40 & tlc45] <- 4
  scoreMed.temp[unsignal & median.true & sp40 & tlc6] <- 4
  
  scoreMed <- stack(scoreMed, scoreMed.temp)
  scoreMed <- overlay(scoreMed, fun=max)
}

#####################################################################################################################
#for loop for intersection that does not has median (Section F4)
for (i in nlayers(tl_stack)) {
  scoreMed.temp[] <- 0
  tlc12 <- tl_stack[[i]] == 1 | tl_stack[[i]] == 2
  tlcGreat4 <- tl_stack[[i]] >= 4
  
  scoreMed.temp[unsignal & median.false & sp25 & tlc12] <- 1
  scoreMed.temp[unsignal & median.false & sp25 & tlc3] <- 1
  scoreMed.temp[unsignal & median.false & sp25 & tlcGreat4] <- 2
  
  scoreMed.temp[unsignal & median.false & sp30 & tlc12] <- 1
  scoreMed.temp[unsignal & median.false & sp30 & tlc3] <- 2
  scoreMed.temp[unsignal & median.false & sp30 & tlcGreat4] <- 3
  
  scoreMed.temp[unsignal & median.false & sp35 & tlc12] <- 2
  scoreMed.temp[unsignal & median.false & sp35 & tlc3] <- 3
  scoreMed.temp[unsignal & median.false & sp35 & tlcGreat4] <- 4
  
  scoreMed.temp[unsignal & median.false & sp40 & tlc12] <- 3
  scoreMed.temp[unsignal & median.false & sp40 & tlc3] <- 4
  scoreMed.temp[unsignal & median.false & sp40 & tlcGreat4] <- 4
  
  scoreMed <- stack(scoreMed, scoreMed.temp)
  scoreMed <- overlay(scoreMed, fun=max)
}

scoreALL <- stack(score.Comb.RLT.LTL, scoreMed)
scoreALL <- overlay(scoreALL, fun=max)

scoreRTL_Med <- stack(scoreCombRTL, scoreMed)
scoreRTL_Med <- overlay(scoreRTL_Med, fun=max)
#####################################################################################################################
#Writing Result
setwd(resultDir)
###Export score as a GeoTiff
filename <- paste("scoreMix", resolution, sep="")
writeRaster(scoreComb, filename, format = "GTiff", overwrite=TRUE)

#Write Score for RTL Only 
filename <- paste("scoreRTL", resolution, sep="")
writeRaster(scoreRTL, filename, format = "GTiff", overwrite = TRUE)

###RTL with Mix
filename <- paste("scoreCombRTL", resolution, sep="")
writeRaster(scoreCombRTL, filename, format = "GTiff", overwrite=TRUE)

#Write Raster containing only LTL score
filename <- paste("scoreLTL", resolution, sep="")
writeRaster(scoreLTL, filename, format = "GTiff", overwrite=TRUE)

#Mix RTL LTL without Median
filename <- paste("scoreComb", resolution, sep="")
writeRaster(score.Comb.RLT.LTL, filename, format = "GTiff", overwrite=TRUE)

#Mix RTL with Median
filename <- paste("scoreRTL_Med", resolution, sep="")
writeRaster(scoreRTL_Med, filename, format = "GTiff", overwrite=TRUE)

#Write score for everything
filename <- paste("scoreALL", resolution, sep="")
writeRaster(scoreALL, filename, format = "GTiff", overwrite=TRUE)


#####################################################################################################################
#plotting (Section G)
#Plot only biking facilities
#pdf("BLTS Score.pdf")
scorePlot <- raster(ext=studyExtent, resolution = resolution, crs = crs)
scorePlot[] <- 0

breakpoints <- c(0,1,2,3,4)
colors <- c("blue","green","orange","red")
scorePlot <- scoreBike
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Score with only biking faciliities - Res:", resolution)
plot(scorePlot,breaks=breakpoints,col=colors, main =title)

#Plot Mix traffic only
scorePlot <- scoreMix
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Score with Mix Traffic Only - Res:", resolution)
plot(scorePlot,breaks=breakpoints,col=colors, main =title)

#Sharrow Present
plot(sharrow, main="Sharrow Present", col=c("green","white"))

#Plot Mix traffic + Bike w/o Int
scorePlot <- scoreComb
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Mixed Traffic + Bicycle Facility w/o Intersection - Res:", resolution)
plot(scorePlot,breaks=breakpoints,col=colors, main =title)

#Plot RTL Only
title <- paste("RTL Only - Res:", resolution)
scorePlot <- scoreRTL
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
plot(scorePlot, breaks=breakpoints,col=colors, main =title)

#Plot w/ RTL with Mix Traffic and Bike
scorePlot <- scoreCombRTL
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Combine Score with RTL Criteria - Res:", resolution)
plot(scorePlot,breaks=breakpoints,col=colors, main =title)

#Plot only LTL
scorePlot <- scoreLTL
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Score LTL only - Res:", resolution)
plot(scorePlot, breaks=breakpoints,col=colors, main=title)

#Plot Comb of all w/o int
scorePlot <- score.Comb.RLT.LTL
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Score with RTL and LTL Criteria - Res:", resolution)
plot(scorePlot, breaks=breakpoints,col=colors,main=title)

#Plot Intersection Score
scorePlot <- scoreMed
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("Score w/ un-signalized intersection crossing - Res:", resolution)
plot(scorePlot, breaks=breakpoints,col=colors, main=title)

#Plot ALL
scorePlot <- scoreALL
scorePlot[scorePlot== 5 | scorePlot == 0] <- NA
title <- paste("score ALL - Res: ", resolution)
plot(scorePlot, breaks=breakpoints,col=colors, main=title)
#dev.off()
#####################################################################################################################
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

keep(maxsp.raster, lanePerDir.raster, sure=TRUE)

