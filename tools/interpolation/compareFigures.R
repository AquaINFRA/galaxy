library("getopt")
library("imager")
library("magrittr")
library("magick")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'figure1', 'i1', 1, 'character',
    'figure2', 'i2', 1, 'character',
    'output', 'o', 2, 'character'
), byrow=TRUE, ncol=4)
options = getopt(option_specification)

cat("\n figure1", options$figure1)
cat("\n figure2", options$figure2)

# Function to compare two images pixel-wise and output a difference image
compareImages <- function(image1_path, image2_path, output_path) {
  img1 <- image_read(image1_path)
  img2 <- image_read(image2_path)

  # Convert images to imager format for pixel-wise absolute difference
  img1_array <- as.array(img1)
  img2_array <- as.array(img2)

  img1_imager <- cimg(img1_array)
  img2_imager <- cimg(img2_array)

  if (any(dim(img1_imager) != dim(img2_imager))) {
    stop("Both images must have the same dimensions.")
  }

  # Compute pixel-wise absolute difference using imager
  diff_img_imager <- abs(img1_imager - img2_imager)

  # Save the difference image as a temporary file
  temp_file <- tempfile(fileext = ".png")
  save.image(diff_img_imager, temp_file)

  # Read the difference image using magick
  diff_img_magick <- image_read(temp_file)

  # Save the difference image
  image_write(diff_img_magick, output_path)

  # Display the images
  par(mfrow = c(1, 3))
  plot(img1, main = "Image 1")
  plot(img2, main = "Image 2")
  plot(diff_img_magick, main = "Difference Image")

  par(mfrow = c(1, 1))
}

image1_path <- options$figure1
image2_path <- options$figure2
output_path <- options$output

compareImages(image1_path, image2_path, output_path)
