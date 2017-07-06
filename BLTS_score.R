# SCORING CRITERIA

# Bike Lane with Adjacent Parking Lane Criteria
BikeLaneAdjParkingLane_Function <- function(stk) {
  ## Set up testing Criteria
  bikeLaneWAdjPL.score = raster(ext = studyExtent, crs = crs, res = res)
  bikeLaneWAdjPL.score[] <- 0

  ## Set up mask layer
  parking.raster = stk[[hasParking]]
  hasParking = parking.raster == 1
  
  lpd.raster = stk[[lpd]]
  one_lpd = lpd.raster == 1 | lpd.raster == 0
  two_lpd = lpd.raster >= 2
  
  speed.raster = stk[[speed]]
  less_25 = speed.raster <= 25
  equal_30 = speed.raster == 30
  equal_35 = speed.raster == 35
  great_40 = speed.raster >= 40
  
  bl_pl_width.raster = stk[[combPkWidth]]
  bl_pl_width_great15 = bl_pl_width.raster >= 15
  bl_pl_width_14_14.5 = bl_pl_width.raster > 13 & bl_pl_width.raster < 15
  bl_pl_width_less13 = bl_pl_width.raster <= 13
  bl_pl_width_less15 = bl_pl_width.raster < 15
  
  bikeLaneWAdjPL.score[hasParking & one_lpd & less_25 & bl_pl_width_great15] <- 1
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_30 & bl_pl_width_great15] <- 1
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_35 & bl_pl_width_great15] <- 2
  bikeLaneWAdjPL.score[hasParking & one_lpd & great_40 & bl_pl_width_great15] <- 2
  
  bikeLaneWAdjPL.score[hasParking & one_lpd & less_25 & bl_pl_width_14_14.5] <- 2
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_30 & bl_pl_width_14_14.5] <- 2
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_35 & bl_pl_width_14_14.5] <- 3
  bikeLaneWAdjPL.score[hasParking & one_lpd & great_40 & bl_pl_width_14_14.5] <- 4
  
  bikeLaneWAdjPL.score[hasParking & one_lpd & less_25 & bl_pl_width_less13] <- 3
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_30 & bl_pl_width_less13] <- 3
  bikeLaneWAdjPL.score[hasParking & one_lpd & equal_35 & bl_pl_width_less13] <- 3
  bikeLaneWAdjPL.score[hasParking & one_lpd & great_40 & bl_pl_width_less13] <- 4
  
  bikeLaneWAdjPL.score[hasParking & two_lpd & less_25 & bl_pl_width_great15] <- 2
  bikeLaneWAdjPL.score[hasParking & two_lpd & equal_30 & bl_pl_width_great15] <- 2
  bikeLaneWAdjPL.score[hasParking & two_lpd & equal_35 & bl_pl_width_great15] <- 3
  bikeLaneWAdjPL.score[hasParking & two_lpd & great_40 & bl_pl_width_great15] <- 3
  
  bikeLaneWAdjPL.score[hasParking & two_lpd & less_25 & bl_pl_width_less15] <- 3
  bikeLaneWAdjPL.score[hasParking & two_lpd & equal_30 & bl_pl_width_less15] <- 3
  bikeLaneWAdjPL.score[hasParking & two_lpd & equal_35 & bl_pl_width_less15] <- 3
  bikeLaneWAdjPL.score[hasParking & two_lpd & great_40 & bl_pl_width_less15] <- 4
  
  plot(bikeLaneWAdjPL.score, main="w")
  return(bikeLaneWAdjPL.score)
}


# Bike Lane without Adjacent Parking Lane Criteria
BikeLaneWOAdjParkingLane_Function <- function(stk) {
  bikeLaneWOAdjPL.score = raster(ext = studyExtent, crs = crs, res = res)
  bikeLaneWOAdjPL.score[] <- 0
  
  ## Set up masks
  parking.raster = stk[[hasParking]]
  noParking = parking.raster == 0
  
  lpd.raster = stk[[lpd]]
  one_lpd = lpd.raster == 1 | lpd.raster == 0
  two_lpd = lpd.raster >= 2
  
  speed.raster = stk[[speed]]
  less_30 = speed.raster <= 30
  equal_35 = speed.raster == 35
  great_40 = speed.raster >= 40
  
  bikeLane.raster = stk[[parkingLaneWidth]]
  bl_greater_7 = bikeLane.raster >= 7
  bl_5.5_7.5 = bikeLane.raster >= 5.5 & bikeLane.raster <= 7
  bl_less_5.5 = bikeLane.raster <= 5.5
  bl_less_7 = bikeLane.raster < 7
  
  bikeLaneWOAdjPL.score[noParking & one_lpd & less_30 & bl_greater_7] <- 1
  bikeLaneWOAdjPL.score[noParking & one_lpd & equal_35 & bl_greater_7] <- 2
  bikeLaneWOAdjPL.score[noParking & one_lpd & great_40 & bl_greater_7] <- 3
  
  bikeLaneWOAdjPL.score[noParking & one_lpd & less_30 & bl_5.5_7.5] <- 1
  bikeLaneWOAdjPL.score[noParking & one_lpd & equal_35 & bl_5.5_7.5] <- 3
  bikeLaneWOAdjPL.score[noParking & one_lpd & great_40 & bl_5.5_7.5] <- 4
  
  bikeLaneWOAdjPL.score[noParking & one_lpd & less_30 & bl_less_5.5] <- 2
  bikeLaneWOAdjPL.score[noParking & one_lpd & equal_35 & bl_less_5.5] <- 3
  bikeLaneWOAdjPL.score[noParking & one_lpd & great_40 & bl_less_5.5] <- 4
  
  bikeLaneWOAdjPL.score[noParking & two_lpd & less_30 & bl_greater_7] <- 1
  bikeLaneWOAdjPL.score[noParking & two_lpd & equal_35 & bl_greater_7] <- 2
  bikeLaneWOAdjPL.score[noParking & two_lpd & great_40 & bl_greater_7] <- 3
  
  bikeLaneWOAdjPL.score[noParking & two_lpd & less_30 & bl_less_7] <- 3
  bikeLaneWOAdjPL.score[noParking & two_lpd & equal_35 & bl_less_7] <- 3
  bikeLaneWOAdjPL.score[noParking & two_lpd & great_40 & bl_less_7] <- 4

  plot(bikeLaneWOAdjPL.score, main="wo")
  return(bikeLaneWOAdjPL.score)
}

# Urban/Suburban Mixed Traffic Criteria
MixCriteria_function <- function(stk) {
  mixTraffic.score = raster(ext = studyExtent, crs = crs, res = res)
  mixTraffic.score = 0
  
  ## Set up masks
  lpd.raster = stk[[lpd]]
  unmarked = lpd.raster == 0
  lpd_1 = lpd.raster == 1
  lpd_2 = lpd.raster == 2
  lpd_3plus = lpd.raster >= 3
  
  speed.raster = stk[[speed]]
  less_25 = speed.raster <= 25
  equal_30 = speed.raster == 30
  great_35 = speed.raster >= 35
  
  
  
}




