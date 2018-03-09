source("transform_active.R")
source("biomass_calc_yearly.R")
source("map_yearly.R")

transform()

biomass_calc()

layer <-list.files("../data/active_unit")
jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
map_yearly()
dev.off()


