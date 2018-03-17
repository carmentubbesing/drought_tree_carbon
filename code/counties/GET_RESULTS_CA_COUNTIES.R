source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")
source("aggregate_pixels.R")

load(file = "../data/CA_counties.Rdata")

# this section is for if you want to exclude counties in the Southern Sierra
# nrow(counties)
# SScounties <- list.dirs("~/drought_tree_carbon/sierra_regions/data/counties/", recursive = F, full.names = F)
# length(SScounties)
# counties <- subset(counties, !counties@data$NAME %in% as.character(SScounties))
# nrow(counties)

to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

for(i in 1:length(counties)){
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
  biomass_calc()
  map_yearly()
  map()
  aggregate_pixels()
}
