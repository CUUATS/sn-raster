require(raster)

# Scoring function
scoreRaster <- function(x, ...) {
  dimensions <- list(...)
  if (length(x) != prod(lengths(dimensions))) stop('Length of x must match product of dimension lengths')
  scores <- array(x, lengths(dimensions))
  print(dimensions)
  print(scores)
}

# Input rasters
lanes <- raster(nrow=2, ncol=2, vals=c(2, 2, 3, 4))
speed <- raster(nrow=2, ncol=2, vals=c(25, 45, 50, 35))
aadt <- raster(nrow=2, ncol=2, vals=c(100, 400, 250, 450))

# Test scoring function
scoreRaster(
  c(1, 2, 3, 2, 2, 3, 1, 3, 4, 2, 6, 4),
  c(lanes <= 2, lanes > 2),
  c(speed <= 25, speed > 25 & speed <= 40, speed > 40),
  c(aadt <= 200, aadt > 200)
)
