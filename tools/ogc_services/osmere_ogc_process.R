library("httr2")
library("jsonlite")
library("getopt")

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
  'dataset', 'i1', 1, 'character',
  'preference', 'i2', 1, 'character',
  'mode', 'i3', 1, 'character',
  'startingPointLat', 'i4', 1, 'double',
  'startingPointLon', 'i5', 1, 'double',
  'endPointLat', 'i6', 1, 'double',
  'endPointLon', 'i7', 1, 'double',
  'output', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n dataset:::: ", options$dataset)
cat("\n preference: ", options$preference)
cat("\n mode: ", options$mode)
cat("\n startingPointLat: ", options$startingPointLat)
cat("\n startingPointLon: ", options$startingPointLon)
cat("\n endPointLat: ", options$endPointLat)
cat("\n endPointLon: ", options$endPointLon)
cat("\n output: ", options$output)

req <- request("https://maps.gnosis.earth/ogcapi/processes/OSMERE/execution")
req %>% req_headers(
  'accept' = 'application/json',
  'Content-Type' = 'application/json'
)

resp <- req %>% req_body_json(
  list(
    inputs=list(
      dataset = options$dataset, 
      preference = options$preference,
      mode = options$mode,
      waypoints = list(
        value= list(
          type= "MultiPoint",
          coordinates = list(
            c(options$startingPointLon, options$startingPointLat),
            c(options$endPointLon, options$endPointLat)
          )  
        )
      )
    )
  )
) %>%
  req_perform() 
res <- resp %>% resp_body_json(simplifyVector = T, check_type = T)
write_json(res, options$output)
cat("\n Done!")