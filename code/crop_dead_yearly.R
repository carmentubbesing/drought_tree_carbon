crop_dead_yearly <- function(){
  
  layer <-list.files("../data/active_unit")
  YEARS_NAMES <- c("2012","2013", "2014", "2015", "2016", "2017")
  for(i in 1:length(YEARS_NAMES)){
    YEAR <- YEARS_NAMES[i]
    load(paste("../results/temp/", layer, YEAR, ".Rdata", sep = ""))
    df <- results_k
    # Create a key for each pixel (row)
    pixel_key <- seq(1, nrow(df))
    df$pixel_key <- pixel_key
    df <- df %>%
      ungroup() %>%
      dplyr::select(pixel_key, everything())
    
    # Convert to spatial
    xy <- df[,c("x","y")]
    spdf <- SpatialPointsDataFrame(coords=xy, data = df, proj4string =  CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0
                                                                            +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")  )
    
    
    # Crop to unit size and shape
    load("../data/transformed/transformed.Rdata")
    in_unit <- foreach(i=1:nrow(unit), .combine = rbind,.errorhandling="remove") %dopar% {
      in_unit <- over(unit[i,], spdf, returnList = T)[[1]]
      return(in_unit)
    }
    
    spdf_in_unit <- spdf[pixel_key %in% in_unit$pixel_key,]
    df <- df %>% 
      filter(pixel_key %in% in_unit$pixel_key)
    save(df, file = paste("../results/temp/", layer, "_", YEAR, "_mask",".Rdata",sep = ""))
    save(spdf_in_unit, file = paste("../results/temp/", layer, "_", YEAR, "_mask_spdf",".Rdata",sep = ""))
  }
}