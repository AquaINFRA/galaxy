library("getopt")
library("dplyr")

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'inputData', 'i1', 1, 'character',
  'checked', 'i2', 1, 'character',
  'processing', 'i3', 1, 'character',
  'accuracy', 'i4', 1, 'double',
  'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

temperature_values <- read.csv(file=options$inputData, sep = ',', header = TRUE)

if ( options$checked ) {
  temperature_values <- dplyr::filter(temperature_values, temperature_values$quality_level == "checked")
}

if (options$processing == "raw") {
  temperature_values <- dplyr::filter(temperature_values, temperature_values$data_processing == "raw")
}

cat("\n inputData", options$inputData)
cat("\n checked: ", options$checked)
cat("\n accuracy: ", options$accuracy)
cat("\n outputData: ", options$outputData)
  
temperature_values <- dplyr::filter(temperature_values, temperature_values$accuracy < options$accuracy)
write.table(temperature_values, options$outputData, quote = FALSE, sep = ",", row.names=FALSE)