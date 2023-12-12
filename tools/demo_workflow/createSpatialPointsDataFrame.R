library("getopt")
library("sf")
library("sp")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'inputData', 'i1', 1, 'character',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n inputData", options$inputData)
cat("\n outputData: ", options$outputData)

input_data <- read.csv(file=options$inputData, sep = ',', header = TRUE)
coordinates(input_data) <- c("longitude", "latitude")
sf_input_data <- st_as_sf(input_data)
st_write(sf_input_data, options$outputData, driver = "geojson", delete_dsn = TRUE)