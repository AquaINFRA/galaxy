library("httr2")
library("jsonlite")
library("getopt")

args <- commandArgs(trailingOnly = TRUE)
option_specification <- matrix(c(
  'url', 'i1', 1, 'character',
  'outputData', 'o', 2, 'character'
), byrow = TRUE, ncol = 4)
options <- getopt(option_specification)

url <- "https://testbed19.geolabs.fr:8717/ogc-api/processes/OTB.BandMath/execution"

json_data <- list(
  inputs = list(
    il = list(
      list(
        href = options$url
      )
    ),
    out = "float",
    exp = "im1b3,im1b2,im1b1",
    ram = 256
  ),
  outputs = list(
    out = list(
      format = list(
        mediaType = "image/jpeg"
      ),
      transmissionMode = "reference"
    )
  ),
  response = "raw"
)

tryCatch({
  resp <- request(url) %>%
    req_headers(
      'accept' = '/*',
      'Prefer' = 'return=representation',
      'Content-Type' = 'application/json'
    ) %>%
    req_body_json(json_data) %>%
    req_perform()

  if (resp$status_code == 200) {
    if (resp$body) {
      print("Request successful.")
      content <- resp$body
      writeBin(content, options$outputData)
    } else {
      print("Error: Request failed. No body received.")
    }
  } else {
    print(paste("HTTP", resp$status_code, "Error:", resp$status_message))
  }
}#, 
  #error = function(e) {
  #print("An unexpected error occurred.")
  #print(e)
#}
)
