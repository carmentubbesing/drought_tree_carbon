library("rgdal")
library(rgeos)
setwd("~/drought_tree_carbon/southern_sierra_region/")
region <- readOGR(dsn = "subregion_S_Sierra", layer = "subregion_S_Sierra")
plot(region)
plot(region[1,])
for(i in 1:length(region)){
  county <- region[i,]
  name <- as.character(unlist(region@data$NAME_PCASE[i]))
  assign(name, county)
}


writeOGR(Calaveras, dsn = "counties/Calaveras", layer = "Calaveras", driver = "ESRI Shapefile")
writeOGR(Fresno, dsn = "counties/Fresno", layer = "Fresno", driver = "ESRI Shapefile")
writeOGR(Kern, dsn = "counties/Kern", layer = "Kern", driver = "ESRI Shapefile")
writeOGR(Madera, dsn = "counties/Madera", layer = "Madera", driver = "ESRI Shapefile")
writeOGR(Mariposa, dsn = "counties/Mariposa", layer = "Mariposa", driver = "ESRI Shapefile")
writeOGR(Tulare, dsn = "counties/Tulare", layer = "Tulare", driver = "ESRI Shapefile")
writeOGR(Tuolumne, dsn = "counties/Tuolumne", layer = "Tuolumne", driver = "ESRI Shapefile")

library("rgdal")
library(rgeos)
setwd("~/drought_tree_carbon/sierra_regions/data")
region <- readOGR(dsn = "sierra_regions", layer = "subregion_SE_Sierra")
plot(region)
plot(region[1,])
for(i in 1:length(region)){
  county <- region[i,]
  name <- as.character(unlist(region@data$NAME_PCASE[i]))
  assign(name, county)
}


writeOGR(Mono, dsn = "counties/Mono", layer = "Mono", driver = "ESRI Shapefile")
writeOGR(Inyo, dsn = "counties/Inyo", layer = "Inyo", driver = "ESRI Shapefile")
