library("getopt")
library("sf")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'polygonData', 'i1', 1, 'character',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n polygonData", options$polygonData)
cat("\n outputData: ", options$outputData)

input_data <- st_read(options$polygonData)
input_data_spolydf<-as_Spatial(input_data)
sf_input_data_spolydf<-st_as_sf(input_data_spolydf)
st_write(sf_input_data_spolydf, options$outputData, driver = "geojson", delete_dsn = TRUE)