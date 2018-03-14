
source("summarize_yearly.R")

counties <- list.dirs("~/drought_tree_carbon/sierra_regions/data/counties/", recursive = F)
to <- "~/drought_tree_carbon/drought_tree_carbon/data/active_unit/"

for(i in 1:length(counties)){
  # Remove county from folder
  active_county <- list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F)
  unlink(active_county, recursive = T)
  
  from <- counties[i]
  system(paste("cp -r", from, to)) 
  print(list.dirs("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/", recursive = F))

  
  summarize_yearly()
}



