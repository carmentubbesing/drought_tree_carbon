source("transform_active.R")
source("biomass_calc.R")
source("map_new_unit.R")

transform()

biomass_calc()

layer <-list.files("../data/active_unit")
jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
map()
dev.off()

