setwd("~/drought_tree_carbon/drought_tree_carbon/code/")
library(rgeos)
library(rgdal)
source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")
source("aggregate_pixels_percBM.R")

load(file = "../data/CA_counties.Rdata")

to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

counties@data$NAME

# Load Sierra counties
setwd("../../sierra_regions/data/sierra_regions/")
sierra_counties <- readOGR(dsn = "counties_Sierra", layer = "counties_Sierra")
plot(sierra_counties)

to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

counties@data$NAME
counties <- subset(counties, counties@data$NAME %in% sierra_counties@data$NAME_PCASE & !(counties@data$NAME %in% c("Los Angeles", "San Bernardino")))
counties@data$NAME
plot(counties)


for(i in 1:length(counties)){
  print(i)
  # Remove county from folder
  active_county <- list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F)
  unlink(active_county, recursive = T)
  
  # Save new county to folder named that county
  county <- counties[i,]
  setwd("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/")
  lay <- as.character(county@data$NAME)
  dir.create(lay)
  print(lay)
  writeOGR(obj = county, dsn = lay, layer = lay, driver = "ESRI Shapefile")
  setwd("~/drought_tree_carbon/drought_tree_carbon/code/")
  transform()
  
  aggregate_pixels()
}
