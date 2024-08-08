library("httr2")
library("jsonlite")
library("getopt")

cat("start generic wrapper service \n")

getParameters <- function(){
    con <- file("inputs.json", "r")
    lines <- readLines(con)
    close(con)

    json_string <- paste(lines, collapse = "\n")
    json_data <- fromJSON(json_string)
    return(json_data$conditional_process)
}

parseResponseBody <- function(body) {
  hex <- c(body)
  intValues <- as.integer(hex)
  rawVector <- as.raw(intValues)
  readableOutput <- rawToChar(rawVector)
  jsonObject <- jsonlite::fromJSON(readableOutput)
  return(jsonObject)
}

getOutputs <- function(inputs, output, server) {
    url <- paste(paste(server, "/processes/", sep = ""), inputs$select_process, sep = "")
    request <- request(url)
    response <- req_perform(request)
    responseBody <- parseResponseBody(response$body)
    outputs <- list()

    for (x in 1:length(responseBody$outputs)) {
        outputformatName <- paste(names(responseBody$outputs[x]), "_outformat", sep="")
        output_item <- list()

        for (p in names(inputs)) {
            if(p == outputformatName){
                format <- list("mediaType" = inputs[[outputformatName]])
                output_item$format <- format
            }
        }
        output_item$transmissionMode <- "reference"
        outputs[[x]] <- output_item
    }

    names(outputs) <- names(responseBody$outputs)
    return(outputs)
}


#curl --location 'http://localhost:5000/processes/mean-by-group/execution' \
#--header 'Content-Type: application/json' \
#--data '{ 
#    "inputs": {
#        "input_data": "data_out_peri_conv.csv"
#    } 
#}'


executeProcess <- function(url, process, requestBodyData) {
    url <- paste(paste(paste(url, "processes/", sep = ""), process, sep = ""), "/execution", sep = "")
    requestBodyData$inputs$select_process <- NULL

    body <- list()
    body$inputs <- requestBodyData$inputs #galaxy
    #body <- requestBodyData$inputs #local
    
    print(url)
    print(body)
    
    response <- request(url) %>%
      req_headers(
        "accept" = "/*",
        "Prefer" = "respond-async;return=representation",
        "Content-Type" = "application/json"
      ) %>%
      req_body_json(body) %>%
      req_perform()

    cat("\n Process executed")
    cat("\n status: ", response$status_code)
    cat("\n jobID: ", parseResponseBody(response$body)$jobID, "\n")
    #print(parseResponseBody(response$body))

    #jobID <- parseResponseBody(response$body)$jobID
    fileUrl <- parseResponseBody(response$body)$outputs$first_result$href
    print(fileUrl)
    return(fileUrl)
}

checkJobStatus <- function(server, process, jobID, cookie) {
  url <- paste0(server, "processes/", process, "/jobs/", jobID)
  response <- request(url) %>%
    req_headers(
      "Cookie" = cookie
    ) %>%
    req_perform()
  jobStatus <- parseResponseBody(response$body)$status
  jobProgress <- parseResponseBody(response$body)$progress
  return(jobStatus)
}

getStatusCode <- function(server, process, jobID, cookie) {
  url <- paste0(server, "processes/", process, "/jobs/", jobID)
  print(url)
  response <- request(url) %>%
    req_headers(
      "Cookie" = cookie
    ) %>%
    req_perform()
  status_code <- response$status_code
  return(status_code)
}

getResult <- function (server, process, jobID, cookie) {
  response <- request(paste0(server, "processes/", process, "/jobs/", jobID, "/results")) %>%
    req_headers(
      "Cookie" = cookie
    ) %>%
    req_perform()
  return(response)
}

retrieveResults <- function(server, process, jobID, outputData, cookie) {
    status_code <- getStatusCode(server, process, jobID, cookie)
    if(status_code == 200){
        status <- "running"
        while(status == "running"){
            jobStatus <- checkJobStatus(server, process, jobID, cookie)
            print(jobStatus)
            if (jobStatus == "succeeded") {
                status <- jobStatus
                result <- getResult(server, process, jobID, cookie)
                if (result$status_code == 200) {
                  resultBody <- parseResponseBody(result$body)
                  urls <- unname(unlist(lapply(resultBody, function(x) x$href)))
                  urls_with_newline <- paste(urls, collapse = "\n")
                  con <- file(outputData, "w")
                  writeLines(urls_with_newline, con = con)
                  close(con)
                }
            } else if (jobStatus == "failed") {
              status <- jobStatus
            }
        Sys.sleep(3)
        }
        cat("\n done \n")
    } else if (status_code1 == 400) {
      print("A query parameter has an invalid value.")
    } else if (status_code1 == 404) {
      print("The requested URI was not found.")
    } else if (status_code1 == 500) {
      print("The requested URI was not found.")
    } else {
      print(paste("HTTP", status_code1, "Error:", resp1$status_message))
    }
}

storeInFile <- function(url, outputData) {
  con <- file(outputData, "w")
  writeLines(url, con = con)
  close(con)
}

is_url <- function(x) {
  grepl("^https?://", x)
}

server <- "http://localhost:5000/"

print("--> Retrieve parameters")
inputParameters <- getParameters()
print("--> Parameters retrieved")

args <- commandArgs(trailingOnly = TRUE)
outputLocation <- args[2]

print("--> Retrieve outputs")
outputs <- getOutputs(inputParameters, outputLocation, server)
print("--> Outputs retrieved")

print("--> Parse inputs")
convertedKeys <- c()
for (key in names(inputParameters)) {
  if (is.character(inputParameters[[key]]) && (endsWith(inputParameters[[key]], ".dat") || endsWith(inputParameters[[key]], ".txt"))) { 
    con <- file(inputParameters[[key]], "r")
    url_list <- list()
    #while (length(line <- readLines(con, n = 1)) > 0) {
    #  if (is_url(line)) {
    #    url_list <- c(url_list, list(list(href = trimws(line))))
    #  }
    #}
    con <- file(inputParameters[[key]], "r")
    lines <- readLines(con)
    close(con)
    json_string <- paste(lines, collapse = "\n")
    json_data <- json_string

    inputParameters[[key]] <- json_data
    convertedKeys <- append(convertedKeys, key)
  }
  else if (grepl("_Array_", key)) {
    keyParts <- strsplit(key, split = "_")[[1]]
    type <- keyParts[length(keyParts)]
    values <- inputParameters[[key]]
    value_list <- strsplit(values, split = ",")

    convertedValues <- c()

    for (value in value_list) {
      if(type == "integer") {
        value <- as.integer(value)
      } else if (type == "numeric") {
        value <- as.numeric(balue)
      } else if (type == "character") {
        value <- as.character(value)
      }
    convertedValues <- append(convertedValues, value)

    convertedKey <- ""
    for (part in keyParts) {
      if(part == "Array") {
        break
      }
      convertedKey <- paste(convertedKey, paste(part, "_", sep=""), sep="")
    }
    convertedKey <- substr(convertedKey, 1, nchar(convertedKey)-1)
}

    inputParameters[[key]] <- convertedValues
    convertedKeys <- append(convertedKeys, convertedKey)
  } else {
    convertedKeys <- append(convertedKeys, key)
  }
}

names(inputParameters) <- convertedKeys
print("--> Inputs parsed")

print("--> Prepare process execution")
jsonData <- list(
  "inputs" = inputParameters,
  "outputs" = outputs
)

print("--> Execute process")
jobID <- executeProcess(server, inputParameters$select_process, jsonData)
print("--> Process executed")

print("--> Retrieve results")
print(args[4])
#retrieveResults(server, inputParameters$select_process, jobID, outputLocation)
storeInFile(jobID, args[4])
print("--> Results retrieved")