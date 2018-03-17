aggregate_pixels <- function(){
  library(raster)
  library(tidyverse)
  
  # 1. Load Rdata with points in spdf
  layer <-list.files("../data/active_unit")
  load(paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))
  
  ## Ignore pixels with no starting biomass
  #summary(subset(spdf, is.na(spdf@data$BPH_abs))@data$D_BM_kg)
  spdf <- subset(spdf, !is.na(spdf@data$BPH_GE_25_CRM))
  spdf@data$BM_live_2012_kg <- spdf@data$BPH_GE_25_CRM*.09
  
  # 2. Convert to a raster
  xyz <- spdf@data %>% 
    dplyr::select(x, y, BM_live_2012_kg, D_BM_kg, relNO_tot, NO_TREES_PX)
    
  raster <- rasterFromXYZ(xyz, crs= crs(spdf))
  
  
  # 3. Use function aggregate to make it a coarser raster
  ag <- aggregate(raster, fact = 33.33333333333333333, fun = sum)
  plot(ag)
  
  # 4. Transform into a table
  df <- as.data.frame(ag, xy = T)
  
  # 5. Save as rasters and .csv
  write.csv(df, file = paste("../results/", layer, "_aggregated", ".csv", sep = ""), row.names = F)
  setwd("../results/rasters_aggregated/")
  
  for(i in 1:4){
    writeRaster(ag[[i]], paste(layer, "_",names(ag)[i],".tif",sep=""), driver = "ESRI Shapefile", overwrite = T)
  }
  
}
  
  
