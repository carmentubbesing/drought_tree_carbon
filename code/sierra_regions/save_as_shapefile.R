setwd("C:/Users/Carmen/Documents/drought_tree_carbon/sierra_regions/results/N_Sierra")
load("Results_Spatial_Sierra_subregion_N.Rdata")
writeOGR(spdf, dsn = "Sierra_N_Shapefile", layer = "Sierra_N", driver = "ESRI Shapefile")
