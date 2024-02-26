#Run with Rscript ./OTB_MeanShiftSmoothing.R --url http://geolabs.fr/dl/Landsat8Extract1.tif --outputType png --outputFormat download --outputData test.png

library("httr2")
library("jsonlite")
library("getopt")

args <- commandArgs(trailingOnly = TRUE)
option_specification <- matrix(c(
  #'url', 'i1', 1, 'character',
  'file', 'i1', 1, 'character',
  'outputType', 'i2', 2, 'character',
  'outputFormat', 'i3', 3, 'character',
  'outputData', 'o', 2, 'character'
), byrow = TRUE, ncol = 4)
options <- getopt(option_specification)

#url <- options$url
file <- options$file
#if (grepl("\\.txt$", url)) {
#  url_content <- readLines(url)
#  url <- url_content
#}

outputType <- paste0("image/", options$outputType)
outputFormat <- options$outputFormat
outputData <- options$outputData

#cat("url: ", url)
cat("\n file: ",file)
cat("\n outputType: ", outputType)
cat("\n outputFormat: ", outputFormat)

baseUrl <- "https://ospd.geolabs.fr:8300/ogc-api/"
execute <- "processes/OTB.MeanShiftSmoothing/execution"
getStatus <- "jobs/"
getResult <- "/results"

url <- readLines(file, warn = FALSE)

json_data <- list(
  "inputs" = list(
    "in" = list(
        "href" = url
    ),
    "fout" = "float",
    "foutpos" = "float",
    "ram" = "1024",
    "spatialr" = "5",
    "ranger" = "15",
    "thres" = "0.1",
    "maxiter" = "100",
    "rangeramp" = "0",
    "modesearch" = "False"
  ),
  "outputs" = list(
    "fout" = list(
      "format" = list(
        "mediaType" = outputType
      ),
      "transmissionMode" = "reference"
    ),
    "foutpos" = list(
      "format" = list(
        "mediaType" = "image/tiff"
      ),
      "transmissionMode"= "reference"
    )
  )
)

makeResponseBodyReadable <- function(body) {
  hex <- c(body)
  int_values <- as.integer(hex)
  raw_vector <- as.raw(int_values)
  readable_output <- rawToChar(raw_vector)
  json_object <- jsonlite::fromJSON(readable_output)
  return(json_object)
}

tryCatch({
  #Request 1
  resp1 <- request(paste0(baseUrl, execute)) %>%
    req_headers(
      'accept' = '/*',
      'Prefer' = 'respond-async;return=representation',
      'Content-Type' = 'application/json'
    ) %>%
    req_body_json(json_data) %>%
    req_perform()
  
  response <- makeResponseBodyReadable(resp1$body)
  status_code1 <- resp1$status_code
  
  if (status_code1 == 201) {
    status <- "running"
    attempt = 1
    while (status == "running") {
      #Request 2
      resp2 <- request(paste0(baseUrl,getStatus,response$jobID)) %>%
        req_headers(
          'accept' = 'application/json'
        ) %>%
        req_perform()
      status_code2 <- resp2$status_code
      if (status_code2 == 200) {
        response2 <- makeResponseBodyReadable(resp2$body)
        cat("\n", response2$status )
        if (response2$status=="successful") {
          status <- "successful"
          #Request 3
          resp3 <- request(paste0(baseUrl,getStatus, response2$jobID, getResult)) %>%
            req_headers(
              'accept' = 'application/json'
            ) %>%
            req_perform()
          status_code3 <- resp3$status_code
          if (status_code3 == 200) {
            response3 <- makeResponseBodyReadable(resp3$body)
            if (outputFormat == "download") {
              download.file(response3$fout$href, destfile = outputData, mode = "wb")              
            } else if (outputFormat == "getUrl") {
              writeLines(response3$fout$href, con = outputData)
            }
          } else if (status_code3 == 404) {
            print("The requested URI was not found.")
          } else if (status_code3 == 500) {
            print("A server error occurred.")
          } else {
            print(paste("HTTP", status_code3, "Error:", resp3$status_message))
          }
        } else {
          attempt <- attempt +1
          if (attempt == 200) {
            status <- "failed"          
          }
        }        
      } else {
        status <- "failed"
        print(paste("HTTP", status_code2, "Error:", resp2$status_message))
      }
      Sys.sleep(3)
    }
    print(status)
  } else if (status_code1 == 400) {
    print("A query parameter has an invalid value.")
  } else if (status_code1 == 404) {
    print("The requested URI was not found.")
  } else if (status_code1 == 500) {
    print("The requested URI was not found.")
  } else {
    print(paste("HTTP", status_code1, "Error:", resp1$status_message))
  }
})