library("getopt")
library("sp")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'inputData', 'i1', 1, 'character',
# lat/lon input necessary if users should select the column name.  
#  'latitude', 'i2', 1, 'integer',
#  'longitude', 'i3', 1, 'integer',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n inputData", options$inputData)
#cat("\n latitude: ", options$latitude)
#cat("\n longitude: ", options$longitude)
cat("\n outputData: ", options$outputData)

input_data <- read.csv(file=options$inputData, sep = ',', header = TRUE)

coord_ref_sys <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

createSpatialPointsDataFrame <- function(lon, lat, vals, crs) {
  sp_df = sp::SpatialPointsDataFrame(coords = cbind(lon, lat), 
                                         data = vals,
                                         proj4string = crs)
  return(sp_df)
}

points_spdf <- createSpatialPointsDataFrame(input_data$longitude, 
                                          input_data$latitude, 
                                          input_data, 
                                          coord_ref_sys)

write.table(points_spdf, options$outputData, quote = FALSE, sep = ",", row.names=FALSE)