setwd("~/drought_tree_carbon/drought_tree_carbon/code/")
library(rgeos)
library(rgdal)
source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")
source("aggregate_pixels.R")

load(file = "../data/CA_counties.Rdata")

to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

counties@data$NAME
plot(counties)
setwd("~/drought_tree_carbon/drought_tree_carbon/code/")


for(i in 19:length(counties)){
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
  
  biomass_calc_yearly()
  map_yearly()
  map()
  aggregate_pixels()
}
