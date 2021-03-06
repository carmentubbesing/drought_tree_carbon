aggregate_pixels <- function(){
  strt_join <- Sys.time()
  print("aggregating to 1-km resolution")
  library(raster)
  library(tidyverse)
  
  # 1. Load Rdata with points in spdf
  layer <-list.files("../data/active_unit/")
  load(paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))
  
    ## Ignore pixels with no starting biomass
  spdf <- subset(spdf, !is.na(spdf@data$BPH_GE_25_CRM))
  spdf@data$BM_live_2012_kg <- spdf@data$BPH_GE_25_CRM*.09
  
  # before converting to data frame xyz, crop into 2-3 equally sized spatial data frames, which I'll join back together later
  
  # 2. Convert to a raster
  xyz <- spdf@data %>% 
    dplyr::select(x, y, BM_live_2012_kg, D_BM_kg, NO_TREES_DEAD, NO_TREES_PX, Percent_Mortality_Biomass)
  nrow(xyz)
  # Split in half if it's too large
  if(nrow(xyz) > 10000000){
    print("number of rows > 10000000")
    next
  } else{
    raster <- rasterFromXYZ(xyz, crs= crs(spdf))
    # Use function aggregate to make it a coarser raster
    ag <- aggregate(raster, fact = 33, fun = sum)
    df <- as.data.frame(ag, xy = T)
    # Save as rasters and .csv
    setwd("../results")
    write.csv(df, file = paste(layer, "_aggregated", ".csv", sep = ""), row.names = F)
    plot(ag)
    for(i in 5){
      name <- paste(layer, "_",names(ag)[i],".tif",sep="")
      writeRaster(ag[[i]], filename = name, driver = "ESRI Shapefile", overwrite = T)
    }
  }
  print(paste("Aggregating took:"))
  print(Sys.time() - strt_join)
}
  
  
