install.packages(c("doParallel", "foreach", "dplyr", "tidyr", "rgdal", "raster", "maptools", "rgeos", "ggplot2", "RColorBrewer", "extrafont","ggsn"))

source("transform_active.R")
source("biomass_calc.R")
source("map_new_unit.R")

transform()
biomass_calc()

layer <-subset(list.files("../data/active_unit"),list.files("../data/active_unit")!="transformed")

jpeg(paste("../results/map_", layer,".jpeg", sep = ""))
map()
dev.off()

