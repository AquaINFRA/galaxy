library("getopt")
library("sf")
library("tmap")
library("RColorBrewer")
library("raster")
library("gstat")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'dataObservations', 'i1', 1, 'character',
    'studyArea', 'i2', 1, 'character',
    'spatialData', 'i3', 1, 'character',
    'idwPower', 'i4', 1, 'double',
    'testCase', 'i5', 1, 'character',
    'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n test", options$testCase)
cat("\n data", options$dataObservations)
cat("\n polygon", options$studyArea)
cat("\n points", options$spatialData)
cat("\n idwPower", options$idwPower)
cat("\n outputData: ", options$outputData)

input_data <- read.csv(file=options$dataObservations, sep = ',', header = TRUE)
polygon <- as_Spatial(st_read(options$studyArea))
points <- as_Spatial(st_read(options$spatialData))
power <- options$idwPower

runInterpolation <- function(points, values, interPolationPower){
  if (options$testCase == "true") {
    cat("\n set seed!")
    set.seed(123)
  }
  grd              <- as.data.frame(spsample(points, "regular", n=50000))
  names(grd)       <- c("X", "Y")
  coordinates(grd) <- c("X", "Y")
  gridded(grd)     <- TRUE
  fullgrid(grd)    <- TRUE
  
  proj4string(points) <- proj4string(points)
  proj4string(grd) <- proj4string(points)
  return(gstat::idw(values ~ 1, points, newdata=grd, idp=interPolationPower))
}

plotInterpolationMap <- function(raster, points){
  plot <- tm_shape(raster) + 
    tm_raster(n=10,palette = rev(brewer.pal(7, "RdBu")), auto.palette.mapping = FALSE,
              title="Temperature measurements (C°)") +
    tm_shape(points) + tm_dots(size=0.2) +
    tm_legend(legend.outside=TRUE)
  return(plot)
}

points.idw <- runInterpolation(points, input_data$measurement, power)

raster_object       <- raster(points.idw)
raster_object.mask  <- mask(raster_object, polygon)

idw <- plotInterpolationMap(raster_object.mask, points)
idw

png(options$outputData)
idw
dev.off()