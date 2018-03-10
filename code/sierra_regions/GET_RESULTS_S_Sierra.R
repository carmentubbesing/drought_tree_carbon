source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")

counties <- list.dirs("~/drought_tree_carbon/sierra_regions/data/counties/", recursive = F)
to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

for(i in 7:length(counties)){
  # Remove county from folder
  active_county <- list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F)
  unlink(active_county, recursive = T)
  
  from <- counties[i]
  system(paste("cp -r", from, to)) 
  print(list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F))
  
  transform()
  
  biomass_calc()
  
  map_yearly()
  
  jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
  map()
  dev.off()
}

             
             
