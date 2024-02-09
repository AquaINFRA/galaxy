library("httr2")
library("jsonlite")
library("getopt")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'url', 'i1', 2, 'character',
    'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

# Define the URL
url <- "https://testbed19.geolabs.fr:8717/ogc-api/processes/OTB.BandMath/execution"


# Define the JSON data
json_data <- list(
  inputs=list(
    il = list(
      list(
        href = options$url
      )
    ), 
    out = "float",
    exp = "im1b3,im1b2,im1b1",
    ram = 256
  ),
  outputs=list(
    out=list(
      format=list(
        mediaType = "image/jpeg"
      ),
      transmissionMode = "reference"
    )
  ),
  response = "raw"
)

# Make the POST request
resp <- request(url) %>%
  req_headers(
    'accept' = '/*',
    'Prefer' = 'return=representation',
    'Content-Type' = 'application/json'
  ) %>%
  req_body_json(json_data) %>%
  req_perform()

# Check the response
if (TRUE) {
  #res <- content(resp, as = "parsed")
  # Output the response
  content <- resp$body
  
  # Write the content to a JPEG file
  writeBin(content, options$outputData)
} else {
  print("Error: Request failed.")
}
