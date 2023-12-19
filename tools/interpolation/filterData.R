library("getopt")
library("dplyr")

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'inputData', 'i1', 1, 'character',
  'qualityChecked', 'i2', 1, 'character',
  'processingStage', 'i3', 1, 'character',
  'dataAccuracy', 'i4', 1, 'double',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

input_data <- read.csv(file=options$inputData, sep = ',', header = TRUE)

if ( options$qualityChecked ) {
  input_data <- dplyr::filter(input_data, input_data$quality_level == "checked")
}

if (options$processingStage == "raw") {
  input_data <- dplyr::filter(input_data, input_data$data_processing == "raw")
}

input_data <- dplyr::filter(input_data, input_data$accuracy < options$dataAccuracy)

cat("\n inputData", options$inputData)
cat("\n qualityChecked: ", options$qualityChecked)
cat("\n dataAccuracy: ", options$dataAccuracy)
cat("\n processingStage: ", options$processingStage)
cat("\n outputData: ", options$outputData)

write.table(input_data, options$outputData, quote = FALSE, sep = ",", row.names=FALSE)