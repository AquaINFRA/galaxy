library("getopt")
library("sf")
library("tmap")
library("RColorBrewer")
library("raster")
library("gstat")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'observationsCsv', 'i1', 1, 'character',
    'studyArea', 'i2', 1, 'character',
    'idwPower', 'i3', 1, 'double',
    'samplePoints', 'i4', 1, 'double',
    'sampleType', 'i5', 1, 'character',
    'legendLabel', 'i6', 1, 'character',
    'legendPosition', 'i7', 1, 'character',
    'dotSize', 'i9', 1, 'double',
    'colorType', 'i10', 1, 'character',
    'testCase', 'i8', 1, 'character',
    'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n observationsCsv", options$observationsCsv)
cat("\n studyArea", options$studyArea)
cat("\n idwPower", options$idwPower)
cat("\n samplePoints", options$samplePoints)
cat("\n sampleType", options$sampleType)
cat("\n legendLabel", options$legendLabel)
cat("\n legendposition", options$legendPosition)
cat("\n dotSize", options$dotSize)
cat("\n colorType", options$colorType)
cat("\n testCase", options$testCase)
cat("\n outputData: ", options$outputData)

obsData <- read.csv(file=options$observationsCsv, sep = ',', header = TRUE)
studyArea <- options$studyArea
idwPower <- options$idwPower
samplePoints <- options$samplePoints
sampleType <- options$sampleType
legendLabel <- options$legendLabel
legendPosition <- options$legendPosition
dotSize <- options$dotSize
colorType <- options$colorType
testCase <- options$testCase

coordinates(obsData) <- c("longitude", "latitude")
sf_obsData <- as_Spatial(st_as_sf(obsData))

polygon <- as_Spatial(st_read(studyArea))
sf_obsData@bbox<-polygon@bbox

runInterpolation <- function(points, values, interpolation_power, sample_points, sample_type){
  if (testCase == "true") {
    cat("\n set seed!")
    set.seed(123)
  }
  grd              <- as.data.frame(spsample(points, sample_type, n=sample_points))
  names(grd)       <- c("X", "Y")
  coordinates(grd) <- c("X", "Y")
  gridded(grd)     <- TRUE
  fullgrid(grd)    <- TRUE
  
  proj4string(points) <- proj4string(points)
  proj4string(grd) <- proj4string(points)
  return(gstat::idw(values ~ 1, points, newdata=grd, idp=interpolation_power))
}

plotInterpolationMap <- function(raster, points, legend_label){
  plot <- tm_shape(raster) + 
    tm_raster(n=10,palette = rev(brewer.pal(7, colorType)), auto.palette.mapping = FALSE,
              title=legend_label) +
    tm_shape(points) + tm_dots(size=dotSize) +
    tm_legend(legend.outside=legendPosition)
  return(plot)
}

sf_obsData.idw <- runInterpolation(sf_obsData, obsData$measurement, idwPower, samplePoints, sampleType)

raster_object       <- raster(sf_obsData.idw)
raster_object.mask  <- mask(raster_object, polygon)

idw <- plotInterpolationMap(raster_object.mask, sf_obsData, legendLabel)
idw

png(options$outputData)
idw
dev.off()