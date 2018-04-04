aggregate_pixels <- function(){
  strt_join <- Sys.time()
  print("aggregating to 1-km resolution")
  library(raster)
  library(tidyverse)
  
  # 1. Load Rdata with points in spdf
  layer <-list.files("~/drought_tree_carbon/drought_tree_carbon/data/active_unit/")
  load(paste("../results/Counties/Results_Spatial_", layer, ".Rdata", sep = ""))
  
    ## Ignore pixels with no starting biomass
  spdf <- subset(spdf, !is.na(spdf@data$BPH_GE_25_CRM))
  spdf@data$BM_live_2012_kg <- spdf@data$BPH_GE_25_CRM*.09
  
  # before converting to data frame xyz, crop into 2-3 equally sized spatial data frames, which I'll join back together later
  
  # 2. Convert to a raster
  xyz <- spdf@data %>% 
    dplyr::select(x, y, Percent_Mortality_Biomass)
  nrow(xyz)
  # Split in half if it's too large
  if(nrow(xyz) > 10000000){
    print("number of rows > 10000000")
    next
  } else{
    raster <- rasterFromXYZ(xyz, crs= crs(spdf))
    # Use function aggregate to make it a coarser raster
    ag <- aggregate(raster, fact = 10, fun = mean)
    df <- as.data.frame(ag, xy = T)
    # Save as rasters and .csv
    setwd("~/drought_tree_carbon/drought_tree_carbon/results/tables_aggregated")
    write.csv(df, file = paste(layer, "_aggregated_PercBM", ".csv", sep = ""), row.names = F)
    setwd("~/drought_tree_carbon/drought_tree_carbon/results/rasters_aggregated/Sierra")
    name <- paste(layer, "_","PercBM",".tif",sep="")
    writeRaster(ag, filename = name, driver = "ESRI Shapefile", overwrite = T)
  }
  print(paste("Aggregating took:"))
  print(Sys.time() - strt_join)
}
  
  
