setwd("~/drought_tree_carbon/")

source("code/functions/biomass_calc.R")
source("code/functions/setwd.R")
source("code/functions/transform_active.R")

setwd_drought()
transform()
biomass_calc()

