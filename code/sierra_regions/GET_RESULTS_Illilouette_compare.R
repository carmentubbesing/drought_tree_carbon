source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")

areas <- list.dirs("~/drought_tree_carbon/other_shapefiles/Illilouette_compare/", recursive = F)
to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

# Calculations, without mapping
for(i in 1:length(areas)){
  # Remove county from folder
  active_county <- list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F)
  unlink(active_county, recursive = T)
  
  from <- areas[i]
  system(paste("cp -r", from, to)) 
  print(list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F))
  
  transform()
  
  biomass_calc()
}

# Just mapping
for(i in 1:length(areas)){
  # Remove county from folder
  active_county <- list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F)
  unlink(active_county, recursive = T)
  
  from <- areas[i]
  system(paste("cp -r", from, to)) 
  print(list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F))
  
  transform()
  
  #map_yearly()
  map()
}

