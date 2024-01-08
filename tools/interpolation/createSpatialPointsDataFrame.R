library("getopt")
library("sf")
library("sp")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'dataPoints', 'i1', 1, 'character',
  'latitudeColumnName', 'i2', 1, 'character',
  'longitudeColumnName', 'i3', 1, 'character',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n dataPoints", options$dataPoints)
cat("\n dataPoints", options$latitudeColumnName)
cat("\n dataPoints", options$longitudeColumnName)
cat("\n outputData: ", options$outputData)

input_data <- read.csv(file=options$dataPoints, sep = ',', header = TRUE)
coordinates(input_data) <- c(options$latitudeColumnName, options$longitudeColumnName)
sf_input_data <- st_as_sf(input_data)
st_write(sf_input_data, options$outputData, driver = "geojson", delete_dsn = TRUE)