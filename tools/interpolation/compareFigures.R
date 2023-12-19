library("getopt")
library("imager")
library("magrittr")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'figure1', 'i1', 1, 'character',
    'figure2', 'i2', 1, 'character',
    'output', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n figure1", options$figure1)
cat("\n figure2", options$figure2)
#cat("\n output: ", options$output)
compareImages <- function(image1_path, image2_path, output_path) {
  img1 <- load.image(image1_path)
  img2 <- load.image(image2_path)
  
  if (any(dim(img1) != dim(img2))) {
    stop("Both images must have the same dimensions.")
  }
  
  diff_img <- abs(img1 - img2)
  
  save.image(diff_img, output_path)
  
  par(mfrow = c(1, 3))
  plot(img1, main = "Image 1")
  plot(img2, main = "Image 2")
  plot(diff_img, main = "Difference Image")
  
  par(mfrow = c(1, 1))
}

image1_path <- options$figure1
image2_path <- options$figure2
output_path <- options$output

compareImages(image1_path, image2_path, output_path)