source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")
source("map.R")

transform()

biomass_calc()

map_yearly()

layer <-list.files("../data/active_unit")
jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
map()
dev.off()
