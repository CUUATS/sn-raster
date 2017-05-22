#Project: Sustainable Neighborhood Toolkit - BLTS Analysis
#Description: This script reads shapefiles containing target attributes.  Rasterizing the vector files into
#raster files using gdalUtils.  Perform BLTS analysis based on the documentation ODOT report
#Author: Edmond Lai - CUUATS
#Last Work on by: Edmond Lai
#Date Last Worked on: 5/19/2017
#Last Worked on: 
#Finished RTL Criteria

#Need to complete:
#LTL Criteria

#USER INPUT
#*************************************************************************************************************************#
#set path to the file geodatabase containing feature classes for analysis
path.fgdb <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"

#set working Directory
wd <- "L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood"

#Set resolution for raster cell size, this can be changed by the user to fine tune the scale of cell size
resolution <- 100

#set path to the study area geodatabase
boundary.fgdb <- "G:/Resources/Data/Boundary.gdb"

#set path where shapefiles are stored
shape.path <- "L:/Sustainable Neighborhoods Toolkit/TIFF/"

#set name for the bike shapefile
bike.name <- "bikeLane.shp"

#set name for total lane shapefile
totalLane.name <- "TotalLane.shp"

#set name for St CL shapefile
StreetCL.name <- "StreetCL.shp"

#projection system
crs <- "+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"

#set no path value
npv <- 5

#*************************************************************************************************************************#

#LIBRARY NEEDED FOR ANALYSIS
#####################################################################################################################
start.time <- Sys.time()

library(raster)
library(rgdal)
library(gdalUtils)

#valid install gdalUtils?
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
valid_install

#set wd
setwd(wd)


#READING FEATURE CLASS LINE FILES FROM ESRI GEODATABASE
#####################################################################################################################

# List all feature classes in a file geodatabase
#subset(ogrDrivers(), grepl("GDB", name ))
#fc_list <- ogrListLayers(path.fgdb)
#fc_list

#Read feature class files that contain attribute for analysis
#Street <- readOGR(dsn=path.fgdb, layer = "Street_w_Int_Clip")
#TL <- readOGR(dsn=path.fgdb, layer = "Total_Lanes")
#BikePed <- readOGR(dsn=path.fgdb, layer ="BicyclePedestrianPath_Clip")
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")

#Set Extent for Test Area
extent<-extent(UA)

####CREATE A RASTER LAYER OBJECT (In Progress)####
#########################################################################################################################
###Create a bikelane raster###

#Set path to Bike Lane shapefile
src_datasource <- paste(shape.path,bike.name, sep = "")

#Rasterize Path Type
r.bikelane <- raster(extent(UA), resolution = resolution)
crs(r.bikelane) <- crs
bikelane.tif <- writeRaster(r.bikelane, filename = "bikelane.tif", format="GTiff", overwrite=TRUE)
facility.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikelane.tif", a="PathType", at=TRUE, output_Raster = TRUE)
crs(facility.raster) <- crs

#Rasterize Bike Path Width
r.rdWidth <- raster(extent(UA), resolution=resolution)
crs(r.rdWidth) <- crs
roadWidth.tif <- writeRaster(r.rdWidth, filename = "roadWidth.tif", format = "GTiff", overwrite = TRUE)
roadWidth.raster <- gdal_rasterize(src_datasource, dst_filename = "roadWidth.tif", a="Width",at=TRUE,output_Raster = TRUE)
crs(roadWidth.raster) <- crs

###Rasterize Parking Lane Width
r.pkWidth <- raster(extent(UA), resolution = resolution)
crs(r.pkWidth) <- crs
pkWidth.tif <- writeRaster(r.pkWidth, filename = "parkingWidth.tif", format="GTiff", overwrite=TRUE)
parkingWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "parkingWidth.tif", a="pkLaneWidt",at=TRUE,output_Raster = TRUE)
crs(parkingWidth.raster) <- crs

###Create Combined Parking and Bike Lane Width
r.bikeParkWidth <- raster(extent(UA), resolution = resolution)
crs(r.bikeParkWidth) <- crs
bikeParkWidth.tif <- writeRaster(r.bikeParkWidth, filename = "bikeParkWidth.tif", format="GTiff", overwrite=TRUE)
bikeParkWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeParkWidth.tif", a="Comb_ParkB",at=TRUE,output_Raster = TRUE)
crs(bikeParkWidth.raster) <- crs

###Create Bike Lane with Adjacent Parking Lane Criteria
r.bikeCrit <- raster(extent(UA), resolution = resolution)
crs(r.bikeCrit) <- crs
bikeCrit.tif <- writeRaster(r.bikeCrit, filename = "bikeCrit.tif", format="GTiff", overwrite=TRUE)
bikeCrit.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeParkWidth.tif", a="hasParki_1",at=TRUE,output_Raster = TRUE)
crs(bikeCrit.raster) <- crs

#########################################################################################################################
###Create a total lane raster###

#Set Path to Total Lane Shapefile
src_datasource <- paste(shape.path,totalLane.name, sep = "")

#Rasterize Total Lane
r.lanePerDir <- raster(extent(UA), resolution = resolution)
crs(r.lanePerDir) <- crs
lanePerDir.tif <- writeRaster(r.lanePerDir, filename = "lanePerDir.tif", format="GTiff", overwrite=TRUE)
lanePerDir.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "totalLane.tif", a="lanePerDir",at=TRUE,output_Raster = TRUE)
crs(lanePerDir.raster) <- crs


#########################################################################################################################
#StreetCL layer
#Set path to Street CL shapefile
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.speed <- raster(extent(UA), resolution = resolution)
crs(r.speed) <- crs
speed.tif <- writeRaster(r.speed, filename = "speed.tif", format="GTiff", overwrite=TRUE)
speed.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "speed.tif", a="SPEED",at=TRUE,output_Raster = TRUE)
crs(speed.raster) <- crs

#########################################################################################################################
###Create an BLTS Layer that will contain the score from BLTS analysis
#blts <- raster()
#extent(blts) = extent(Street)
#res(blts) = resolution
#`values<-`(blts,0)


#FUNCTIONS TO BE USED IN THE BLTS SCORE ANALYSIS (In Progress)
#####################################################################################################################
#Assign score of Off Street Biking to a score of 1

#Physically Seperated Bike Lane 
#Input is in BikePed Layer, all the off street facilities are assigned a score of 1, all other type of biking facilities
#are removed from this layer.  Result is the all off road biking facilities and a GeoTiff is exported for later analysis.

scoreOffStreet <- raster(extent(UA), resolution=resolution)
crs(scoreOffStreet) <- crs
scoreOffStreet[] <- npv

osft1 <- facility.raster == 1
osft2 <- facility.raster == 2
osft3 <- facility.raster == 3
osft4 <- facility.raster == 4
osft5 <- facility.raster == 5
osft10 <- facility.raster == 10

scoreOffStreet[osft1 | osft2 | osft3 | osft4 | osft5 | osft10] <- 1


#writeRaster(offStreetBikeScore.ras, "offStreetBikeScore.tif", format = "GTiff", overwrite=TRUE)
#####################################################################################################################
#Assign on street biking facilities based on number of lane per direction, prevailing speed, and width of street
#Calculate a new raster containing lane per direction
#lanePerDirectionFun <- function(x) {
#  x%/%2;
#}

#lanePerDirection.raster <- calc(totalLane.raster, lanePerDirectionFun)
#crs(lanePerDirection.raster) <- crs
#####################################################################################################################
####Create new layer for each criteria#


#Bike Criteria (Does the bike lane has adj parkign? 1 - yes, 0 - no)
ly <- bikeCrit.raster == 1
ln <- bikeCrit.raster == 0 


#Lane per direction (for Biking facilities)
lpd1 <- lanePerDir.raster == 1 | lanePerDir.raster == 0
lpd2 <- lanePerDir.raster >= 2

#Prevailing Speed or Posted Speed
sp25 <- speed.raster <=25
sp30 <- speed.raster ==30
sp35 <- speed.raster ==35
sp40 <- speed.raster >=40
spless30 <- speed.raster <= 30
spgreat35 <- speed.raster >= 35

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

#No bike Lane but has sharrow
sharrow <- facility.raster == 8


#####################################################################################################################
###Exhibit 14-3 Bike Lane with Adjaent Parking Lane Criteria
#Create a Score Layer
#Create all bike facilities
allBike <- is.na(facility.raster) == FALSE

#Bike Lane with Adjacent Parking Lane Criteria
#Bike Path Type
bikelane <- facility.raster == 6 | facility.raster == 9


scoreBike <- raster(extent(UA), resolution=resolution)
crs(scoreBike) <- crs
scoreBike[] <- npv

#Set the default score for all biking facilities
scoreBike[allBike] <- 2

scoreBLwP <- raster(extent(UA), resolution=resolution)
crs(scoreBLwP) <- crs
scoreBLwP[] <- npv

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
scoreBLwoP <- raster(extent(UA), resolution=resolution)
crs(scoreBLwoP) <- crs
scoreBLwoP[] <- npv

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
### Exhibit 14-5 Urban/Suburban Mixed used with Biking Facilities

#####################################################################################################################
### Exhibit 14-5 Urban/Suburban Mixed Traffic Criteria
scoreMix <- raster(extent(UA), resolution=resolution)
crs(scoreMix) <- crs
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

#####################################################################################################################
###plot score of Bike
plot(scoreBike, main = "Score for all biking facilities")

##plot score comb
scoreComb <- raster(extent(UA), resolution=resolution)
crs(scoreComb) <- crs
scoreComb[] <- npv

stk <- stack(scoreMix,scoreBike)
scoreComb <- overlay(stk, fun=min)

###Export score as a GeoTiff
writeRaster(scoreComb, "scoreComb.tif", format = "GTiff", overwrite=TRUE)


#####################################################################################################################
#####INTERSECTION APPROACH #####
#Rasterizing Attributes needed for the Intersection Approach

#Rasterize Right Turn Lane Config
#####################################################################################################################
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.RTL_Conf_N <- raster(extent(UA), resolution = resolution)
crs(r.RTL_Conf_N) <- crs
RTL_Conf_N.tif <- writeRaster(r.RTL_Conf_N, filename = "RTL_Conf_N", format="GTiff", overwrite=TRUE)
RTL_Conf_N.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_N.tif", a="RTL_Conf_N",at=TRUE,output_Raster = TRUE)
crs(RTL_Conf_N.raster) <- crs

r.RTL_Conf_S <- raster(extent(UA), resolution = resolution)
crs(r.RTL_Conf_S) <- crs
RTL_Conf_S.tif <- writeRaster(r.RTL_Conf_S, filename = "RTL_Conf_S", format="GTiff", overwrite=TRUE)
RTL_Conf_S.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_S.tif", a="RTL_Conf_S",at=TRUE,output_Raster = TRUE)
crs(RTL_Conf_S.raster) <- crs

r.RTL_Conf_E <- raster(extent(UA), resolution = resolution)
crs(r.RTL_Conf_E) <- crs
RTL_Conf_E.tif <- writeRaster(r.RTL_Conf_E, filename = "RTL_Conf_E", format="GTiff", overwrite=TRUE)
RTL_Conf_E.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_E.tif", a="RTL_Conf_E",at=TRUE,output_Raster = TRUE)
crs(RTL_Conf_E.raster) <- crs

r.RTL_Conf_W <- raster(extent(UA), resolution = resolution)
crs(r.RTL_Conf_W) <- crs
RTL_Conf_W.tif <- writeRaster(r.RTL_Conf_W, filename = "RTL_Conf_W", format="GTiff", overwrite=TRUE)
RTL_Conf_W.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Conf_W.tif", a="RTL_Conf_W",at=TRUE,output_Raster = TRUE)
crs(RTL_Conf_W.raster) <- crs
#####################################################################################################################
#Rasterize Bike Lane Approach
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.BL_Appr_Al <- raster(extent(UA), resolution = resolution)
crs(r.BL_Appr_Al) <- crs
BL_Appr_Al.tif <- writeRaster(r.BL_Appr_Al, filename = "BL_Appr_Al", format="GTiff", overwrite=TRUE)
BL_Appr_Al.raster <- gdal_rasterize(src_datasource, dst_filename = "BL_Appr_Al.tif", a="BL_Appr_Al",at=TRUE,output_Raster = TRUE)
crs(BL_Appr_Al.raster) <- crs

#Rasterize Right Turn Lane Length
r.RTL_Length <- raster(extent(UA), resolution = resolution)
crs(r.RTL_Length) <- crs
RTL_Length.tif <- writeRaster(r.RTL_Length, filename = "RTL_Length", format="GTiff", overwrite=TRUE)
RTL_Length.raster <- gdal_rasterize(src_datasource, dst_filename = "RTL_Length.tif", a="RTL_Length",at=TRUE,output_Raster = TRUE)
crs(RTL_Length.raster) <- crs



#####################################################################################################################
#Right Turn Lane Criteria Exhibit 14-7 
#Create empty raster to store the score
scoreRTL <- raster(extent(UA), resolution=resolution)
crs(scoreRTL) <- crs
scoreRTL[] <- 0

scoreRTL.temp <- raster(extent(UA), resolution=resolution)
crs(scoreRTL.temp) <- crs
scoreRTL.temp[] <- 0
#####################################################################################################################
#create T/F layer for the Right-turn lane configuration
RTL_Length_less150 <-  RTL_Length.raster <= 150 & RTL_Length.raster > 0
RTL_Length_great150 <- RTL_Length.raster > 150
RTL_Length_any <- RTL_Length.raster > 0
RTL_Appro_Str <- BL_Appr_Al.raster == 1
RTL_Appro_Lef <- BL_Appr_Al.raster == 2 | BL_Appr_Al.raster == 3
RTL_Appro_Any <- BL_Appr_Al.raster == 1 | BL_Appr_Al.raster == 2 | BL_Appr_Al.raster == 3 | BL_Appr_Al.raster == 0

#Loop through the RTL Configuration for N, S, E, W and assign score for each direction of the intersection
#Combine the 
int_Dir <- stack(RTL_Conf_N.raster, RTL_Conf_S.raster,RTL_Conf_E.raster,RTL_Conf_W.raster)
names(int_Dir) <- c("North", "South", "East", "West")

for (i in 1:nlayers(int_Dir)) {
  RTL_Conf_S <- int_Dir[[i]] == 1
  RTL_Conf_DE_S <- int_Dir[[i]] == 2 | int_Dir[[i]] == 1
  title = names(int_Dir[[i]])
  scoreRTL.temp[RTL_Conf_DE_S & RTL_Length_any & RTL_Appro_Any] <- 4
  scoreRTL.temp[RTL_Conf_S & RTL_Length_great150 & RTL_Appro_Str] <- 3
  scoreRTL.temp[RTL_Conf_S & RTL_Length_any & RTL_Appro_Lef] <- 3
  scoreRTL.temp[RTL_Conf_S & RTL_Length_less150 & RTL_Appro_Str] <- 2
  scoreRTL <- stack(scoreRTL, scoreRTL.temp)
  scoreRTL <- overlay(scoreRTL, fun=max)
}

#Overlay the Score w/o intersection and with RTL criteria, assign null value to zero and select the maximum from the two
scoreComb_5 <- scoreComb ==5
scoreRTL_5 <- scoreRTL == 5

scoreComb[scoreComb_5] <- 0
scoreRTL[scoreRTL_5] <- 0
Comb_RTL <- stack(scoreComb, scoreRTL)
scoreCombRTL <- overlay(Comb_RTL, fun = max)

#Plot scores for Comb and with RTL criteria
#plot(scoreCombRTL, main="Score with RTL")
#scoreCombRTL[scoreCombRTL == 0] <- NA


###Export score as a GeoTiff
writeRaster(scoreCombRTL, "scoreCombRTL.tif", format = "GTiff", overwrite=TRUE)

#####################################################################################################################
#Left Turn Lane Criteria

#rasterize Criteria for Left Turn Lane
#Lane Cross
src_datasource <- paste(shape.path,StreetCL.name, sep = "")
r.LTL_lanesc <- raster(extent(UA), resolution = resolution)
crs(r.LTL_lanesc) <- crs
LTL_lanesc.tif <- writeRaster(r.LTL_lanesc, filename = "LTL_lanesc", format="GTiff", overwrite=TRUE)
LTL_lanesc.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lanesc.tif", a="LTL_lanesc",at=TRUE,output_Raster = TRUE)
crs(LTL_lanesc.raster) <- crs

r.LTL_lane_1 <- raster(extent(UA), resolution = resolution)
crs(r.LTL_lane_1) <- crs
LTL_lane_1.tif <- writeRaster(r.LTL_lane_1, filename = "LTL_lane_1", format="GTiff", overwrite=TRUE)
LTL_lane_1.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_1.tif", a="LTL_lane_1",at=TRUE,output_Raster = TRUE)
crs(LTL_lane_1.raster) <- crs

r.LTL_lane_2 <- raster(extent(UA), resolution = resolution)
crs(r.LTL_lane_2) <- crs
LTL_lane_2.tif <- writeRaster(r.LTL_lane_2, filename = "LTL_lane_2", format="GTiff", overwrite=TRUE)
LTL_lane_2.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_2.tif", a="LTL_lane_2",at=TRUE,output_Raster = TRUE)
crs(LTL_lane_2.raster) <- crs

r.LTL_lane_3 <- raster(extent(UA), resolution = resolution)
crs(r.LTL_lane_3) <- crs
LTL_lane_3.tif <- writeRaster(r.LTL_lane_3, filename = "LTL_lane_3", format="GTiff", overwrite=TRUE)
LTL_lane_3.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_lane_3.tif", a="LTL_lane_3",at=TRUE,output_Raster = TRUE)
crs(LTL_lane_3.raster) <- crs
#####################################################################################################################
#Intersection Configuation
r.LTL_Conf_N <- raster(extent(UA), resolution = resolution)
crs(r.LTL_Conf_N) <- crs
LTL_Conf_N.tif <- writeRaster(r.LTL_Conf_N, filename = "LTL_Conf_N", format="GTiff", overwrite=TRUE)
LTL_Conf_N.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_N.tif", a="LTL_Conf_N",at=TRUE,output_Raster = TRUE)
crs(LTL_Conf_N.raster) <- crs

r.LTL_Conf_S <- raster(extent(UA), resolution = resolution)
crs(r.LTL_Conf_S) <- crs
LTL_Conf_S.tif <- writeRaster(r.LTL_Conf_S, filename = "LTL_Conf_S", format="GTiff", overwrite=TRUE)
LTL_Conf_S.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_S.tif", a="LTL_Conf_S",at=TRUE,output_Raster = TRUE)
crs(LTL_Conf_S.raster) <- crs

r.LTL_Conf_E <- raster(extent(UA), resolution = resolution)
crs(r.LTL_Conf_E) <- crs
LTL_Conf_E.tif <- writeRaster(r.LTL_Conf_E, filename = "LTL_Conf_E", format="GTiff", overwrite=TRUE)
LTL_Conf_E.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_E.tif", a="LTL_Conf_E",at=TRUE,output_Raster = TRUE)
crs(LTL_Conf_E.raster) <- crs

r.LTL_Conf_W <- raster(extent(UA), resolution = resolution)
crs(r.LTL_Conf_W) <- crs
LTL_Conf_W.tif <- writeRaster(r.LTL_Conf_W, filename = "LTL_Conf_W", format="GTiff", overwrite=TRUE)
LTL_Conf_W.raster <- gdal_rasterize(src_datasource, dst_filename = "LTL_Conf_W.tif", a="LTL_Conf_W",at=TRUE,output_Raster = TRUE)
crs(LTL_Conf_W.raster) <- crs
#####################################################################################################################
#Create Stack for LTL Criteria
#LTL_Conf_Dir <- stack(LTL_Conf_N.raster, LTL_Conf_S.raster,LTL_Conf_E.raster,LTL_Conf_W.raster)
LTL_LC_Dir <- stack(LTL_lanesc.raster, LTL_lane_1.raster, LTL_lane_2.raster, LTL_lane_3.raster)

#Create empty raster to store the score for LTL
scoreLTL <- raster(extent(UA), resolution=resolution)
crs(scoreLTL) <- crs
scoreLTL[] <- 0

scoreLTL.temp <- raster(extent(UA), resolution=resolution)
crs(scoreLTL.temp) <- crs
scoreLTL.temp[] <- 0

#creating criteria

#Create evaluation layer for lane crossed in one intersection
for(i in 1:nlayers(LTL_LC_Dir)) {
  #Setting criteria for evaluation
  laneCrossed_0 <- LTL_LC_Dir[[i]] == 0
  laneCrossed_1 <- LTL_LC_Dir[[i]] == 1
  laneCrossed_2 <- LTL_LC_Dir[[i]] >= 2
  laneCrossed_DE <- LTL_LC_Dir[[i]] != 0

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

#Write Raster containing only LTL score
writeRaster(scoreLTL, "scoreLTL.tif", format = "GTiff", overwrite=TRUE)

#Combinging the Score with Mixed Used, Bike Lane, RLT and LTL
score.Comb.RLT.LTL <- raster(extent(UA), resolution=resolution)
crs(score.Comb.RLT.LTL) <- crs
score.Comb.RLT.LTL[] <- 0
score.Comb.RLT.LTL <- stack(scoreComb, scoreLTL)
score.Comb.RLT.LTL <- overlay(score.Comb.RLT.LTL, fun = max)

#plotting
#Plot w/o Int
breakpoints <- c(0,1,2,3,4)
colors <- c("blue","green","orange","red")
scoreComb[scoreComb == 0] <- NA
plot(scoreComb,breaks=breakpoints,col=colors, main ="Combine Score w/o Intersection")

#Plot w/ RTL
breakpoints <- c(0,1,2,3,4)
colors <- c("blue","green","orange","red")
scoreCombRTL[scoreCombRTL == 0] <- NA
plot(scoreCombRTL,breaks=breakpoints,col=colors, main ="Combine Score with RTL Criteria")

#Plot only LTL
scoreLTL[scoreLTL == 0] <- NA
plot(scoreLTL, breaks=breakpoints,col=colors, main="Score LTL only")

#Plot Comb of all
score.Comb.RLT.LTL[score.Comb.RLT.LTL == 0] <- NA
plot(score.Comb.RLT.LTL, breaks=breakpoints,col=colors,main="Combination of All")



#Write Raster Containin the Score for everything
writeRaster(score.Comb.RLT.LTL, "scoreAll.tif", format = "GTiff", overwrite=TRUE)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
