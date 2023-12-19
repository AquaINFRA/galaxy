library("getopt")
library("sf")
library("tmap")
library("RColorBrewer")

args = commandArgs(trailingOnly=TRUE)
option_specification = matrix(c(
    'spatialPolygon', 'i1', 1, 'character',
    'spatialObservations', 'i2', 1, 'character',
    'outputData', 'o', 2, 'character'
), byrow=TRUE, ncol=4);
options = getopt(option_specification);

cat("\n spatialPolygon", options$spatialPolygon)
cat("\n spatialObservations", options$spatialObservations)
cat("\n outputData: ", options$outputData)

input_data1 <- as_Spatial(st_read(options$spatialPolygon))
input_data2 <- as_Spatial(st_read(options$spatialObservations))

plotStudyArea <- function(sp_polygon_df, sp_points_df){
  plot <- tm_shape(sp_polygon_df) + tm_polygons() +
    tm_shape(sp_points_df) +
    tm_dots(col="measurement", palette = rev(brewer.pal(7, "RdBu")),
            title="Temperature measurements (C°)", size=1) +
    tm_text("measurement", just="left", xmod=.5, size = 0.7) +
    tmap_options(check.and.fix = TRUE) +
    tm_legend(legend.outside=TRUE)
  return(plot)
}

studyarea <- plotStudyArea(input_data1, input_data2)

png(options$outputData)
studyarea
dev.off()