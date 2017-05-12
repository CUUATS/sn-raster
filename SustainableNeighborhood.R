#Project: Sustainable Neighborhood Toolkit - BLTS Analysis
#Description: This script reads shapefiles containing target attributes.  Rasterizing the vector files into
#raster files using gdalUtils.  Perform BLTS analysis based on the documentation ODOT report
#Author: Edmond Lai - CUUATS
#Last Work on by: Edmond Lai
#Date Last Worked on: 5/12/2017
#Last Worked on: 
#Corrected lane per direction

#Need to complete:
#Intersection approach

#LIBRARY NEEDED FOR ANALYSIS
#####################################################################################################################
start.time <- Sys.time()

library(raster)
library(rgdal)
library(gdalUtils)

#valid install gdalUtils?
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
valid_install

#USER INPUT
#####################################################################################################################
#set path to the file geodatabase containing feature classes for analysis
path.fgdb <- "G:/CUUATS/Sustainable Neighborhoods Toolkit/Data/SustainableNeighborhoodsToolkit.gdb"


#set working Directory
wd <- "L:/Sustainable Neighborhoods Toolkit/scripts/SustainableNeighborhood"
setwd(wd)

#Set resolution for raster cell size, this can be changed by the user to fine tune the scale of cell size
resolution <- 100

#set path to the study area geodatabase
boundary.fgdb <- "G:/Resources/Data/Boundary.gdb"

#projection system
crs <- "+proj=tmerc +lat_0=36.66666666666666 +lon_0=-88.33333333333333 +k=0.9999749999999999 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"

#set no path value
npv <- 5


#READING FEATURE CLASS LINE FILES FROM ESRI GEODATABASE
#####################################################################################################################

# List all feature classes in a file geodatabase
#subset(ogrDrivers(), grepl("GDB", name ))
#fc_list <- ogrListLayers(path.fgdb)
#fc_list

#Read feature class files that contain attribute for analysis
Street <- readOGR(dsn=path.fgdb, layer = "Street_w_Int_Clip")
TL <- readOGR(dsn=path.fgdb, layer = "Total_Lanes")
BikePed <- readOGR(dsn=path.fgdb, layer ="BicyclePedestrianPath_Clip")
UA <- readOGR(dsn=boundary.fgdb, layer="UAB2013")
print("Finished Importing Files from Geodatabase")

#Set Extent for Test Area
extent<-extent(UA)

####CREATE A RASTER LAYER OBJECT (In Progress)####
#########################################################################################################################
###Create a bikelane raster###

#Set path to Bike Lane shapefile
src_datasource <- paste("L:/Sustainable Neighborhoods Toolkit/TIFF/","bikeLane.shp", sep = "")

#Rasterize Path Type
r.bikelane <- raster(extent(UA), resolution = resolution)
crs(r.bikelane) <- crs
bikelane.tif <- writeRaster(r.bikelane, filename = "bikelane.tif", format="GTiff", overwrite=TRUE)
facility.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikelane.tif", a="PathType", output_Raster = TRUE)
crs(facility.raster) <- crs

#Rasterize Bike Path Width
r.rdWidth <- raster(extent(UA), resolution=resolution)
crs(r.rdWidth) <- crs
roadWidth.tif <- writeRaster(r.rdWidth, filename = "roadWidth.tif", format = "GTiff", overwrite = TRUE)
roadWidth.raster <- gdal_rasterize(src_datasource, dst_filename = "roadWidth.tif", a="Width", output_Raster = TRUE)
crs(roadWidth.raster) <- crs

###Rasterize Parking Lane Width
r.pkWidth <- raster(extent(UA), resolution = resolution)
crs(r.pkWidth) <- crs
pkWidth.tif <- writeRaster(r.pkWidth, filename = "parkingWidth.tif", format="GTiff", overwrite=TRUE)
parkingWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "parkingWidth.tif", a="pkLaneWidt", output_Raster = TRUE)
crs(parkingWidth.raster) <- crs

###Create Combined Parking and Bike Lane Width
r.bikeParkWidth <- raster(extent(UA), resolution = resolution)
crs(r.bikeParkWidth) <- crs
bikeParkWidth.tif <- writeRaster(r.bikeParkWidth, filename = "bikeParkWidth.tif", format="GTiff", overwrite=TRUE)
bikeParkWidth.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeParkWidth.tif", a="Comb_ParkB", output_Raster = TRUE)
crs(bikeParkWidth.raster) <- crs

###Create Bike Lane with Adjacent Parking Lane Criteria
r.bikeCrit <- raster(extent(UA), resolution = resolution)
crs(r.bikeCrit) <- crs
bikeCrit.tif <- writeRaster(r.bikeCrit, filename = "bikeCrit.tif", format="GTiff", overwrite=TRUE)
bikeCrit.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "bikeParkWidth.tif", a="hasParki_1", output_Raster = TRUE)
crs(bikeCrit.raster) <- crs

#########################################################################################################################
###Create a total lane raster###

#Set Path to Total Lane Shapefile
src_datasource <- paste("L:/Sustainable Neighborhoods Toolkit/TIFF/","TotalLane.shp", sep = "")

#Rasterize Total Lane
r.lanePerDir <- raster(extent(UA), resolution = resolution)
crs(r.lanePerDir) <- crs
lanePerDir.tif <- writeRaster(r.lanePerDir, filename = "lanePerDir.tif", format="GTiff", overwrite=TRUE)
lanePerDir.raster <- gdal_rasterize(src_datasource = src_datasource, dst_filename = "totalLane.tif", a="lanePerDir", output_Raster = TRUE)
crs(lanePerDir.raster) <- crs


#########################################################################################################################
#StreetCL layer
#Set path to Street CL shapefile
src_datasource <- paste("L:/Sustainable Neighborhoods Toolkit/TIFF/","StreetCL.shp", sep = "")
r.speed <- raster(extent(UA), resolution = resolution)
crs(r.speed) <- crs
speed.tif <- writeRaster(r.speed, filename = "speed.tif", format="GTiff", overwrite=TRUE)
speed.raster <- gdal_rasterize(src_datasource, dst_filename = "speed.tif", a="SPEED", output_Raster = TRUE)
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
#offStreetBikeScoreFun <- function(x) {
#  x[x==1| x==2| x==3| x==4| x==5| x==10] <- 1; 
#  x[x!=1| x!=2| x!=3| x!=4| x!=5| x!=10] <- 10;
#  return(x)
#}
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
plot(scoreBike)

scoreBike[allBike] <- 1
plot(scoreBike)

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

plot(scoreBike)
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
plot(scoreBike)
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
#plot(scoreComb, main = "Combine Score w/o Intersection")


breakpoints <- c(0,1,2,3,4,5)
colors <- c("blue","green","orange","red","white")
plot(scoreComb,breaks=breakpoints,col=colors, main ="Combine Score w/o Intersection")

###Export score as a GeoTiff
#writeRaster(scoreComb, "scoreComb.tff", format = "GTiff", overwrite=TRUE)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

#####################################################################################################################
#####INTERSECTION APPROACH #####


