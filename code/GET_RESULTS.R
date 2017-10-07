source("transform_active.R")
source("load_data.R")
source("biomass_calc.R")
source("map_new_unit.R")

transform()

biomass_calc()

jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
map()
dev.off()

