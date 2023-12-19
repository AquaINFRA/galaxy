library("getopt")
library("sf")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'spatialObject1', 'i1', 1, 'character',
    'spatialObject2', 'i2', 1, 'character',
    'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n spatialObject1", options$spatialObject1)
cat("\n spatialObject2", options$spatialObject2)
cat("\n outputData: ", options$outputData)

input_data1 <- as_Spatial(st_read(options$spatialObject1))
input_data2 <- as_Spatial(st_read(options$spatialObject2))
input_data1@bbox <- input_data2@bbox
sf_input_data1<-st_as_sf(input_data1)
st_write(sf_input_data1, options$outputData, driver = "geojson", delete_dsn = TRUE)