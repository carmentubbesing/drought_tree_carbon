aggregate_pixels <- function(){
  library(raster)
  library(tidyverse)
  
  # 1. Load Rdata with points in spdf
  layer <-list.files("../data/active_unit")
  load(paste("../results/Results_Spatial_", layer, ".Rdata", sep = ""))
  
  ## Ignore pixels with no starting biomass
  spdf <- subset(spdf, !is.na(spdf@data$BPH_GE_25_CRM))
  spdf@data$BM_live_2012_kg <- spdf@data$BPH_GE_25_CRM*.09
  
  # before converting to data frame xyz, crop into 2-3 equally sized spatial data frames, which I'll join back together later
  
  # 2. Convert to a raster
  xyz <- spdf@data %>% 
    dplyr::select(x, y, BM_live_2012_kg, D_BM_kg, relNO_tot, NO_TREES_PX)
  nrow(xyz)
  # Split in half if it's too large
  if(nrow(xyz) > 10000000){
    print("number of rows > 10000000")
    next
    n <- nrow(xyz)/3
    nr <- nrow(xyz)
    xyz_split <- split(xyz, rep(1:ceiling(nr/n), each=n, length.out=nr))
    
    xyz1 <- xyz_split$`1`
    xyz2 <- xyz_split$`2`
    xyz3 <- xyz_split$`3`
    sum(na.omit(xyz1$BM_live_2012_kg)) + sum(na.omit(xyz2$BM_live_2012_kg)) + sum(na.omit(xyz3$BM_live_2012_kg)) == sum(spdf$BM_live_2012_kg)
    raster1 <- rasterFromXYZ(xyz1, crs= crs(spdf))
    raster2 <- rasterFromXYZ(xyz2, crs= crs(spdf))
    raster3 <- rasterFromXYZ(xyz3, crs= crs(spdf))
    # Check lengths
    length(raster1[[1]][!is.na(raster1[[1]])]) + length(raster2[[1]][!is.na(raster2[[1]])])+ length(raster3[[1]][!is.na(raster3[[1]])]) == nrow(xyz)
    # Use function aggregate to make it a coarser raster
    ag1 <- aggregate(raster1, fact = 33, fun = sum)
    ag2 <- aggregate(raster2, fact = 33, fun = sum)
    ag3 <- aggregate(raster3, fact = 33, fun = sum)
    layer_names <- c("BM_live_2012_kg", "D_BM_kg", "relNO_tot", "NO_TREES_PX")
    df_full <- data.frame()
    for(i in 1:4){
      bricklayer <- mosaic(ag1[[i]], fun = sum, ag2[[i]], tolerance = 0.3, no.omit = T)
      bricklayer <- mosaic(bricklayer, fun = sum, ag3[[i]], tolerance = 0.2, na.omit = T)
      setwd("~/drought_tree_carbon/drought_tree_carbon/results/rasters_aggregated/")
      writeRaster(bricklayer, paste(layer, "_",layer_names[i],".tif",sep=""), driver = "ESRI Shapefile", overwrite = T)
      df <- as.data.frame(bricklayer, xy = T) %>% 
        setNames(c("x", "y",layer_names[i]))
      if(nrow(df_full) == 0){
        df_full <- df
        } else{
          df_full <- full_join(df_full, df)
        }
      assign(layer_names[i], bricklayer)
    }
    setwd("~/drought_tree_carbon/drought_tree_carbon/code/")
    write.csv(df_full, file = paste("../results/", layer, "_aggregated", ".csv", sep = ""), row.names = F)

  } else{
    raster <- rasterFromXYZ(xyz, crs= crs(spdf))
    # Use function aggregate to make it a coarser raster
    ag <- aggregate(raster, fact = 33, fun = sum)
    df <- as.data.frame(ag)
    # Save as rasters and .csv
    setwd("~/drought_tree_carbon/drought_tree_carbon/results/")
    write.csv(df, file = paste("../results/", layer, "_aggregated", ".csv", sep = ""), row.names = F)
    setwd("../results/rasters_aggregated/Mar26")
    plot(ag)
    for(i in 1:4){
      name <- paste(layer, "_",names(ag)[i],".tif",sep="")
      writeRaster(ag[[i]], filename = name, driver = "ESRI Shapefile", overwrite = T)
    }
  }
}
  
  
